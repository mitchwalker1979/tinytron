import serial, time

s = serial.Serial(port='/dev/ttyUSB0', baudrate=115200)

while True:
    for n in range(255):
        s.write(chr(n))
        print n, hex(n), bin(n)
        #time.sleep(0.05)
