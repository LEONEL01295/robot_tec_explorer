from machine import Pin
import bluetooth
import time
import gc

# ==================================
# PINES DEL DRIVER L298N
# ==================================

IN1 = Pin(13, Pin.OUT)
IN2 = Pin(12, Pin.OUT)
IN3 = Pin(14, Pin.OUT)
IN4 = Pin(27, Pin.OUT)

# ==================================
# MOVIMIENTO DE MOTORES
# ==================================

def detener():
    IN1.off()
    IN2.off()
    IN3.off()
    IN4.off()

def adelante():
    print(">>> ADELANTE")
    IN1.on()
    IN2.off()
    IN3.on()
    IN4.off()

def atras():
    print(">>> ATRAS")
    IN1.off()
    IN2.on()
    IN3.off()
    IN4.on()

def izquierda():
    print(">>> IZQUIERDA")
    IN1.off()
    IN2.on()
    IN3.on()
    IN4.off()

def derecha():
    print(">>> DERECHA")
    IN1.on()
    IN2.off()
    IN3.off()
    IN4.on()

detener()

# ==================================
# CONFIGURACIÓN BLE
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

# ==================================
# ADVERTISING (PUBLICIDAD BLE CON RESPUESTA UUID)
# ==================================

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

def start_advertising():
    try:
        adv = advertising_payload(DEVICE_NAME)
        resp = resp_payload([SERVICE_UUID])
        ble.gap_advertise(100000, adv_data=adv, resp_data=resp, connectable=True)
        print("================================")
        print("BLE PUBLICANDO ACTIVO CON UUID")
        print("NOMBRE:", DEVICE_NAME)
        print("SERVICE:", SERVICE_UUID)
        print("CHAR:", CHAR_UUID)
        print("================================")
    except Exception as e:
        print("Error en start_advertising:", e)

start_advertising()

# ==================================
# PROCESAMIENTO DE COMANDOS
# ==================================

def ejecutar_comando(cmd):
    if not cmd:
        return
    cmd = cmd.strip().lower()
    print("COMANDO RECIBIDO:", cmd)

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
        print("COMANDO DESCONOCIDO")
        detener()

# ==================================
# INTERRUPCIÓN BLE (IRQ)
# ==================================

def ble_irq(event, data):
    if event == _IRQ_CENTRAL_CONNECT:
        print("================================")
        print("DISPOSITIVO CONECTADO")
        print("================================")

    elif event == _IRQ_CENTRAL_DISCONNECT:
        print("================================")
        print("DISPOSITIVO DESCONECTADO -> Deteniendo motores")
        print("================================")
        detener()
        start_advertising()

    elif event == _IRQ_GATTS_WRITE:
        print("================================")
        print("WRITE DETECTADO")
        print("================================")
        conn_handle, value_handle = data
        try:
            raw = ble.gatts_read(value_handle)
            print("RAW:", raw)
            if raw:
                mensaje = raw.decode("utf-8").strip()
                print("MENSAJE:", mensaje)
                ejecutar_comando(mensaje)
        except Exception as e:
            print("ERROR BLE:", e)
            detener()

ble.irq(ble_irq)

# ==================================
# MAIN LOOP CON LIMPIEZA DE MEMORIA RAM
# ==================================

print("================================")
print("ROBOT TEC EXPLORER")
print("SISTEMA LISTO Y ESTABLE")
print("================================")

while True:
    gc.collect()  # Liberación de memoria RAM automática para evitar desconexiones por timeout
    time.sleep_ms(100)
