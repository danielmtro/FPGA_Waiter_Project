import socket
import time
from PIL import Image

# IP address and port of the Arduino Nano 33 IoT
SERVER_IP = '172.16.0.64'  # Replace with your Arduino's actual IP address
PORT = 80

def receive_image():

    image = []

    while True:
        print("foo")
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((SERVER_IP, PORT))
            print("Connected to Arduino server!")
            message = "SEND_DATA\n"

            s.sendall(message.encode('utf-8'))
            break
        except socket.error:
            print("Retrying connection...")
            time.sleep(1)  # Retry every second
    # data = b''
    while len(image) < 320 * 240 * 2:
        answer = input("would you like to send data")
        data = request_receive(s)
        print("raw data received: ", data)

        if data != None:
            image.append(data)
            data = None
        # data = None
        if len(image) > 0:
            print("latest image data received: ", image[-1], "\n")

        # data = s.recv(1024)
    s.close()
    print()
    return data


def reconstruct_image(pixel_data):
    img = Image.new('RGB', (320, 240))
    for i in range(320 * 240):
        pixel_value = (pixel_data[2 * i] << 8) | pixel_data[2 * i + 1]
        r = (pixel_value >> 8) & 0xF
        g = (pixel_value >> 4) & 0xF
        b = pixel_value & 0xF
        img.putpixel((i % 320, i // 320), (r << 4, g << 4, b << 4))
    img.show()


def request_receive(open_socket):
    message = "SEND_DATA\n"
    print("Requesting data from Arduino")
    open_socket.sendall(B"SEND_DATA\n")
    print("request sent")
    data = open_socket.recv(1024)
    print("data received, now to test quality")
    if data:
        data = data.decode('utf-8')
        if data == "NULL":
            print("null data received")
            return None
        else: 
            return data
    else:
        return None



if __name__ == '__main__':
    pixel_data = receive_image()
    reconstruct_image(pixel_data)
