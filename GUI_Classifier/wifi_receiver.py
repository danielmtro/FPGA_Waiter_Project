import socket
import select
import time
from PIL import Image

# IP address and port of the Arduino Nano 33 IoT
# Replace with  Arduino's actual IP address
SERVER_IP = '10.70.139.190'  
PORT = 80

#number of pixels to expect in image
IMAGE_WIDTH = 320
IMAGE_HEIGHT = 240
num_pixels = IMAGE_WIDTH * IMAGE_HEIGHT

"""
@brief this function receives an image from WiFi after a connection is made
"""
def receive_image():
    
    while True:
        try:
            #open a connection with the Arduino
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((SERVER_IP, PORT))
            s.setblocking(False)
            
            #announe connection and request arduino to clear 
            #it's buffer
            print("Connected to Arduino server!")
            message = "F\n"
            s.sendall(message.encode('utf-8'))
            break
        
        #try to connect again
        except socket.error:
            print("Retrying connection...")
            time.sleep(1)  # Retry every second
    
    #Binary type for image information to be stored in
    image = b''
    
    #loop to wait until a full image has been received
    while len(image) < num_pixels * 2:
        
        # collect one pixel from WiFi
        data= request_receive(s)

        #check if returned data is valid and append to image
        if data != None:
            image += data

        # if no data received, take note
        else:
            pass
    
    s.close()
    return image

"""
@brief this function 
"""
def reconstruct_image(pixel_data):
    print("building image")
    
    #declare image dimension
    # NOTE should be changed to the appropriate dimensions e.g. 10x10 or 320x240
    img = Image.new('RGB', (IMAGE_WIDTH, IMAGE_HEIGHT))
    for i in range(num_pixels):
        pixel_value = (pixel_data[2 * i] << 4) | pixel_data[2 * i + 1]

        # TODO Sanity check bitwise operations please
        r = (pixel_value >> 8) & 0xF
        g = (pixel_value >> 4) & 0xF
        b = pixel_value & 0xF

        # Place pixels in image
        # NOTE both these values should be the image width e.g. 10, or 320
        img.putpixel((i % IMAGE_WIDTH, i // IMAGE_WIDTH), (r << 4, g << 4, b << 4))
    img.show()


def request_receive(open_socket):

    #check if there is available data to read, then read one byte
    readable, writable, exceptional = select.select([open_socket], [open_socket], [], 0)
    if readable:

        # read 1 byte and check if it is good and valid
        data = open_socket.recv(10)
        if data:
            return data

    #if no available data, return None
    else:
        return None



if __name__ == '__main__':
    pixel_data = receive_image()
    reconstruct_image(pixel_data)