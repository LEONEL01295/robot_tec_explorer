from machine import Pin
import bluetooth
import time

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

# Estado inicial
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

def advertising_payload(name):
    payload = bytearray()
    payload += bytes([0x02, 0x01, 0x06])  # Flags
    payload += bytes([len(name) + 1, 0x09])  # Complete Local Name
    payload += name.encode()
    return payload

def iniciar_advertising():
    ble.gap_advertise(100000, advertising_payload(DEVICE_NAME))
    print("Publicando BLE como:", DEVICE_NAME)

iniciar_advertising()

# ==================================
# PROCESAMIENTO DE COMANDOS
# ==================================

def ejecutar_comando(cmd):
    cmd = cmd.strip().lower()
    print("CMD:", cmd)

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
        print("Dispositivo conectado exitosamente")

    elif event == _IRQ_CENTRAL_DISCONNECT:
        conn_handle, addr_type, addr = data
        print("Dispositivo desconectado -> Deteniendo motores")
        detener()
        # Volver a anunciar para permitir reconexiones sin reiniciar
        iniciar_advertising()

    elif event == _IRQ_GATTS_WRITE:
        conn_handle, value_handle = data
        try:
            raw = ble.gatts_read(value_handle)
            if raw:
                mensaje = raw.decode().strip()
                ejecutar_comando(mensaje)
        except Exception as e:
            print("ERROR BLE:", e)
            detener()

ble.irq(ble_irq)

# ==================================
# BUCLE PRINCIPAL
# ==================================

print("Bluetooth iniciado")
print("Nombre BLE:", DEVICE_NAME)

while True:
    time.sleep_ms(100)
