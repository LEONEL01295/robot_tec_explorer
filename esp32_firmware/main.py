from machine import Pin
import bluetooth
import time
import gc

# ==================================
# PINES DEL DRIVER L298N / ESP32
# ==================================

IN1 = Pin(13, Pin.OUT)
IN2 = Pin(12, Pin.OUT)
IN3 = Pin(14, Pin.OUT)
IN4 = Pin(27, Pin.OUT)

# ==================================
# CONTROL DE MOTORES
# ==================================

def detener():
    IN1.off()
    IN2.off()
    IN3.off()
    IN4.off()

def adelante():
    IN1.on()
    IN2.off()
    IN3.on()
    IN4.off()

def atras():
    IN1.off()
    IN2.on()
    IN3.off()
    IN4.on()

def izquierda():
    IN1.off()
    IN2.on()
    IN3.on()
    IN4.off()

def derecha():
    IN1.on()
    IN2.off()
    IN3.off()
    IN4.on()

# Estado inicial: Motores apagados
detener()

# ==================================
# BLUETOOTH BLE CONFIGURACIÓN
# ==================================

_IRQ_CENTRAL_CONNECT = 1
_IRQ_CENTRAL_DISCONNECT = 2
_IRQ_GATTS_WRITE = 3

ble = bluetooth.BLE()
ble.active(True)

SERVICE_UUID = bluetooth.UUID("12345678-1234-5678-1234-56789abcdef0")
CHAR_UUID = bluetooth.UUID("abcdef01-1234-5678-1234-56789abcdef0")

SERVICE = (
    SERVICE_UUID,
    (
        (
            CHAR_UUID,
            bluetooth.FLAG_WRITE | bluetooth.FLAG_WRITE_NO_RESPONSE
        ),
    ),
)

((char_handle,),) = ble.gatts_register_services((SERVICE,))

DEVICE_NAME = "TANQUE-ESP32"

def advertising_payload(name="TANQUE-ESP32"):
    payload = bytearray()
    payload += bytes([0x02, 0x01, 0x06])
    name_bytes = name.encode('utf-8')
    payload += bytes([len(name_bytes) + 1, 0x09]) + name_bytes
    return payload

def resp_payload(services=None):
    payload = bytearray()
    if services:
        for uuid in services:
            b = bytes(uuid)
            payload += bytes([len(b) + 1, 0x07]) + b
    return payload

def iniciar_advertising():
    try:
        adv = advertising_payload(DEVICE_NAME)
        resp = resp_payload([SERVICE_UUID])
        ble.gap_advertise(100000, adv_data=adv, resp_data=resp, connectable=True)
        print("✅ Publicando BLE activo con UUID como:", DEVICE_NAME)
    except Exception as e:
        print("❌ Error al iniciar advertising BLE:", e)

iniciar_advertising()

# ==================================
# PROCESAMIENTO DE COMANDOS
# ==================================

def ejecutar_comando(cmd):
    if not cmd:
        return
    cmd = cmd.strip().lower()
    print("▶ COMANDO RECIBIDO:", cmd)

    if cmd == "adelante":
        adelante()
    elif cmd == "atras":
        atras()
    elif cmd == "izquierda":
        izquierda()
    elif cmd == "derecha":
        derecha()
    elif cmd == "detener":
        detener()
    else:
        detener()

# ==================================
# INTERRUPCIÓN BLE (IRQ)
# ==================================

def ble_irq(event, data):
    if event == _IRQ_CENTRAL_CONNECT:
        conn_handle, addr_type, addr = data
        print("📡 Dispositivo conectado exitosamente")

    elif event == _IRQ_CENTRAL_DISCONNECT:
        conn_handle, addr_type, addr = data
        print("🔌 Dispositivo desconectado -> Deteniendo motores")
        detener()
        iniciar_advertising()

    elif event == _IRQ_GATTS_WRITE:
        conn_handle, value_handle = data
        try:
            raw = ble.gatts_read(value_handle)
            if raw:
                mensaje = raw.decode('utf-8').strip()
                ejecutar_comando(mensaje)
        except Exception as e:
            print("ERROR BLE AL LEER:", e)
            detener()

ble.irq(ble_irq)

# ==================================
# BUCLE PRINCIPAL CON LIMPIEZA RAM
# ==================================

print("================================")
print("ROBOT TEC EXPLORER BLE LISTO")
print("Nombre BLE:", DEVICE_NAME)
print("================================")

while True:
    gc.collect()  # Liberar memoria RAM de MicroPython automáticamente
    time.sleep_ms(100)
