from PIL import Image
import serial, time

s = serial.Serial(port='/dev/ttyUSB0', baudrate=115200)

img = Image.open(file('adroll.png'))

width, height = img.size

for y in range(0, height):
    for x in range(0, width):
        pixel = img.getpixel((x,y))
        r, g, b, _ = pixel
        c = 0
        if r > 0x80:
            c |= 0b100
        if g > 0x80:
            c |= 0b10
        if b > 0x80:
            c |= 0b1
        s.write(chr(c))
        time.sleep(0.02)
