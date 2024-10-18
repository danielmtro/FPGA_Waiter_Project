import socket
import select
import time
from PIL import Image

# IP address and port of the Arduino Nano 33 IoT
SERVER_IP = '10.70.139.190'  # Replace with your Arduino's actual IP address
PORT = 80

def receive_image():

    image = []

    while True:
        print("foo")
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((SERVER_IP, PORT))
            s.setblocking(False)
            
            print("Connected to Arduino server!")
            message = "F\n"

            s.sendall(message.encode('utf-8'))
            break
        except socket.error:
            print("Retrying connection...")
            time.sleep(1)  # Retry every second
    image = b''
    # input ("are you ready to receive?")
    #TODO find correct amount to wait
    reset_counter = 0
    while len(image) < 100 * 2:#320 * 240 * 2:# NOTE
        # answer = input("would you like to send data")
        data= request_receive(s)
        # print("raw data received: ", data)

        # if null_flag == 1:
        #     reset_counter += 1
        #     if reset_counter == 300:
        #         image = b''
        #         reset_counter = 0
        #         data = None

        if data != None:
            # image.append(data)
            image += data
            data = None
            reset_counter = 0
        else:
            reset_counter += 1

            if reset_counter >= 10000:
                image = b''
                reset_counter = 0
        # data = None

        if len(image) > 0:
            # print("latest image data received: ", image[-1], "\n")
            print(f"Image length: {len(image)}")
        # data = s.recv(1024)
    s.close()
    print()
    return image


def reconstruct_image(pixel_data):
    print("building image")
    img = Image.new('RGB', (320, 240))
    for i in range(100):
        pixel_value = (pixel_data[2 * i] << 8) | pixel_data[2 * i + 1]
        print(pixel_value)
        r = (pixel_value >> 8) & 0xF
        g = (pixel_value >> 4) & 0xF
        b = pixel_value & 0xF
        img.putpixel((i % 320, i // 320), (r << 4, g << 4, b << 4))
    img.show()


def request_receive(open_socket):
    message = "SEND_DATA\n"
    # print("Requesting data from Arduino")
    readable, writable, exceptional = select.select([open_socket], [open_socket], [], 0)
    if writable:
        open_socket.sendall(B"S\n")
    # print("request sent")

    #check if there is available data
    readable, writable, exceptional = select.select([open_socket], [open_socket], [], 0)
    if readable:
        data = open_socket.recv(1)
    # print("data received, now to test quality")
        if data:
            # try:
            #     data = data.decode('utf-8')
            #     if (data == "NULL") or data == b'\x33':
            #         print("null data received")
            #         return None
            #     else: 
            #         print("data received")
            #         return data.encode('utf-8')
            # except:
            # print("in except block: ", data)
            return data
            if data == b'\x00':
                return data, 1
            else:
                return data, 0
    #if no available data, return None
    else:
        return None



if __name__ == '__main__':
    pixel_data = receive_image()
    reconstruct_image(pixel_data)
