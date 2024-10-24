import socket
import select
import time
from PIL import Image

# IP address and port of the Arduino Nano 33 IoT
# Replace with  Arduino's actual IP address
SERVER_IP = '10.70.139.190'  
PORT = 80

#number of pixels to expect in image
num_pixels = 2500

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
    
    #a counter to count how many time the arduino has not received a pixel
    reset_counter = 0

    #loop to wait until a full image has been received
    while len(image) < num_pixels * 2:

        if (len(image) == 0):
            input ("are you ready to receive?")
            s.sendall(B"S\n")
            # wait 100ms
        
        # collect one pixel from WiFi
        data= request_receive(s)

        #check if returned data is valid and append to image
        if data != None:
            image += data
            data = None
            reset_counter = 0
        
        # if no data received, take note
        else:
            reset_counter += 1

            # reset image since no image data is being sent
            if reset_counter >= 100000:
                image = b''
                reset_counter = 0

        # track image size
        # NOTE it is double size because each pixel is represented by 2 bytes
        if len(image) > 0:
            print(f"Image length: {len(image)}")

    s.close()
    return image

"""
@brief this function 
"""
def reconstruct_image(pixel_data):
    print("building image")
    
    #declare image dimension
    # NOTE should be changed to the appropriate dimensions e.g. 10x10 or 320x240
    img = Image.new('RGB', (50, 50))
    for i in range(num_pixels):
        pixel_value = (pixel_data[2 * i] << 8) | pixel_data[2 * i + 1]

        # TODO Sanity check bitwise operations please
        r = (pixel_value >> 8) & 0xF
        g = (pixel_value >> 4) & 0xF
        b = pixel_value & 0xF

        # Place pixels in image
        # NOTE both these values should be the image width e.g. 10, or 320
        img.putpixel((i % 50, i // 50), (r << 4, g << 4, b << 4))
    img.show()


def request_receive(open_socket):

    # check if WiFi socket is clear and available to have a message sent over
    # request another pixel
    readable, writable, exceptional = select.select([open_socket], [open_socket], [], 0)
    if writable:
        open_socket.sendall(B"S\n")

    #check if there is available data to read, then read one byte
    readable, writable, exceptional = select.select([open_socket], [open_socket], [], 0)
    if readable:

        # read 1 byte and check if it is good and valid
        data = open_socket.recv(1)
        if data:
            return data

    #if no available data, return None
    else:
        return None



if __name__ == '__main__':
    pixel_data = receive_image()
    reconstruct_image(pixel_data)
