from PyQt5.QtCore import QTimer, QTime, Qt, QSize, QThread, pyqtSignal, QUrl
from PyQt5.QtGui import QPixmap, QFont, QImage
from PyQt5.QtWidgets import *
from PIL import Image
import socket
import select
import time
import sys
import cv2
import matplotlib.pyplot as plt
from deepface import DeepFace
import numpy as np
import pygame

# SERVER_IP = '10.70.139.190'  
SERVER_IP = '10.42.0.97'
PORT = 80
IMAGE_WIDTH = 320
IMAGE_HEIGHT = 240
num_pixels = IMAGE_WIDTH * IMAGE_HEIGHT

class ImageReceiverThread(QThread):
    image_received = pyqtSignal(Image.Image)  # Signal emitted when an image is ready

    def __init__(self):
        super().__init__()
        self.socket = None  # Initialize socket to None
        self.keep_receiving = True  # Flag to keep receiving images

    def run(self):
        # Keep trying to connect until successful
        self.socket = self.connect_to_arduino()
        
        while self.keep_receiving:
            if self.socket:  # Check if the socket is connected
                pixel_data = self.receive_image()
                if pixel_data:
                    img = self.reconstruct_image(pixel_data)
                    self.image_received.emit(img)  # Emit the image
                    self.clear_recv_buffer()
                else:
                    print("No data received, reconnecting...")
                    self.socket.close()
                    self.socket = self.connect_to_arduino()  # Reconnect if data is not received

    def receive_image(self):
        
        image = b''  # Binary type for image information to be stored in
        while len(image) < num_pixels * 2:
            data = self.request_receive(self.socket)
            if data:
                image += data
            else:
                # Reconnect if no data received within a certain timeframe
                time.sleep(0.05)  # Brief wait to allow data to arrive
        return image if len(image) == num_pixels * 2 else None  # Ensure full image size

    def clear_recv_buffer(self):
        """Clear out any remaining data in the receive buffer."""
        try:
            while True:
                data = self.socket.recv(4096)
                if not data:
                    break
        except BlockingIOError:
            pass  # No data left to clear

    def reconstruct_image(self, pixel_data):
        img = Image.new('RGB', (IMAGE_WIDTH, IMAGE_HEIGHT))
        for i in range(num_pixels):
            pixel_value = (pixel_data[2 * i] << 4) | pixel_data[2 * i + 1]
            r, g, b = (pixel_value >> 8) & 0xF, (pixel_value >> 4) & 0xF, pixel_value & 0xF
            img.putpixel((i % IMAGE_WIDTH, i // IMAGE_WIDTH), (r << 4, g << 4, b << 4))
        return img

    def request_receive(self, open_socket):
        readable, _, _ = select.select([open_socket], [], [], 0.1)  # Adjusted timeout for faster checking
        if readable:
            data = open_socket.recv(4096)  # Increased buffer size for quicker reads
            return data if data else None
        return None

    def connect_to_arduino(self):
        while True:
            try:
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.connect((SERVER_IP, PORT))
                s.setblocking(False)
                print("Connected to Arduino server!")
                message = "F\n"  # Send a reset message
                s.sendall(message.encode('utf-8'))
                return s
            except socket.error:
                print("Retrying connection...")
                time.sleep(1)
    
    def stop_receiving(self):
        self.keep_receiving = False  # Stop the while loop
        if self.socket:
            self.socket.close()  # Close the socket if it's open

    
class ClassifyFace(QThread):
    classification_done = pyqtSignal(dict)  # Signal to emit the classification result

    def __init__(self, img):
        super().__init__()
        self.img = img

    def run(self):
        color_img = cv2.cvtColor(self.img, cv2.COLOR_BGR2RGB)
        prediction = DeepFace.analyze(color_img, actions=['age', 'race', 'emotion'])[0]
        self.classification_done.emit(prediction)  # Emit the classification result


class mainWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.spiceLevel = -1
        self.minorAlert = -1
        self.emotion = -1
        self.display_image_flag = 0
        self.receive_image_flag = 0
        self.initUI()
        pygame.mixer.init()  # Initialize pygame mixer

        # Start the image receiver thread
        self.receiver_thread = ImageReceiverThread()
        self.receiver_thread.image_received.connect(self.updateImage)
        self.receiver_thread.start()

    def initUI(self):
        mainWindow = QVBoxLayout()
        menuBar = QGridLayout()
        graphicsArea = QGridLayout()

        # Setup QLabel widgets for displaying images
        self.spiceWidget = QFrame()
        self.spiceLayout = QVBoxLayout(self.spiceWidget)
        self.spiceImageLabel = QLabel(self.spiceWidget)
        self.spiceImageLabel.setScaledContents(True)
        self.spiceImageLabel.setAlignment(Qt.AlignCenter)
        self.spiceLayout.addWidget(self.spiceImageLabel)

        self.faceWidget = QFrame()
        self.faceLayout = QVBoxLayout(self.faceWidget)
        self.faceImageLabel = QLabel(self.faceWidget)
        self.faceImageLabel.setScaledContents(True)
        self.faceImageLabel.setAlignment(Qt.AlignCenter)
        self.faceLayout.addWidget(self.faceImageLabel)

        self.text_display = QTextEdit(self)  # Using QTextEdit instead of QLabel
        self.text_display.setStyleSheet("background-color: #D3D3D3; color: black; padding: 10px; border-radius: 5px;")  # White background and black text
        self.text_display.setReadOnly(True)  # Make it read-only

        self.orderButton = QPushButton("ORDER")
        self.orderButton.setFixedSize(400, 110)
        self.orderButton.clicked.connect(self.orderButtonClicked)  # Connect button click to the method
        menuBar.addWidget(self.orderButton, 0, 0, 1, 1, Qt.AlignHCenter)

        self.receiveButton = QPushButton("RECEIVE")
        self.receiveButton.setFixedSize(400, 110)
        self.receiveButton.clicked.connect(self.receiveButtonClicked)  # Connect button click to the method
        menuBar.addWidget(self.receiveButton, 0, 1, 1, 1, Qt.AlignHCenter)

        self.classifyButton = QPushButton("CLASSIFY")
        self.classifyButton.setFixedSize(400, 110)
        self.classifyButton.clicked.connect(self.classifyButtonClicked)  # Connect button click to the method
        menuBar.addWidget(self.classifyButton, 0, 2, 1, 2, Qt.AlignHCenter)

        graphicsArea.addWidget(self.faceWidget, 0, 0, 3, 4)
        graphicsArea.addWidget(self.spiceWidget, 0, 0, 3, 4)

        mainWindow.addLayout(graphicsArea)
        mainWindow.addWidget(self.text_display)
        mainWindow.addLayout(menuBar)
        self.setLayout(mainWindow)

        # Timer for display update
        timer = QTimer(self)
        timer.timeout.connect(self.updateDisplay)
        timer.start(250)

    def pil_to_qpixmap(self, image):
        image = image.convert("RGBA")
        data = image.tobytes("raw", "RGBA")
        qimage = QImage(data, image.width, image.height, QImage.Format_RGBA8888)
        return QPixmap.fromImage(qimage)

    def updateDisplay(self):
        # Update images based on the flags
        if self.display_image_flag == 1:
            image = Image.open("images/chad_small.jpg")
            pixmap = self.pil_to_qpixmap(image)
            self.faceImageLabel.setPixmap(pixmap)
            self.currentImage = image
        elif self.display_image_flag == 0:
            pixmap = QPixmap("images/init.png")
            self.faceImageLabel.setPixmap(pixmap)

        if self.spiceLevel == 0:
            self.spiceImageLabel.setPixmap(QPixmap("images/MildSpice.png"))
        elif self.spiceLevel == 1:
            self.spiceImageLabel.setPixmap(QPixmap("images/MedSpice.png"))
        elif self.spiceLevel == 2:
            self.spiceImageLabel.setPixmap(QPixmap("images/HotSpice.png"))
        elif self.spiceLevel == -1:
            self.spiceImageLabel.setPixmap(QPixmap("images/NoSpice.png"))

        if (self.spiceLevel == 0):
            self.text_display.setText("So are you almost ready? Allow me to recommend the bread for you!\n")
        elif (self.spiceLevel == 1):
            self.text_display.setText("So are you almost ready? We have a lovely Penang curry, and also a Jerk chicken special!\n")
        elif (self.spiceLevel == 2):
            self.text_display.setText("So are you almost ready? Our Sichuan hotpot is exceptional, and our we also have a Vindaloo special!\n")
        else:
            self.text_display.setText("")
        
        if (self.minorAlert == 0):
            self.text_display.append("Will you be having any alcohol today? Maybe cigarettes?\n")
        elif (self.minorAlert == 1):
            self.text_display.append("Oh my bad! You're underage - blurring your features now! Let's change the display!\n")

        if (self.emotion == 0):
            self.text_display.append("I love your smile by the way!")
        elif (self.emotion == 1):
            self.text_display.append("Sir, I'm going to have to you to leave - you're making some of our patrons uncomfortable.")
        elif (self.emotion == 2):
            self.text_display.append("Hey are you okay by the way? You seem really bummed out!")

    def updateImage(self, image):
        # Convert image
        pygame.mixer.music.load("Media/photoArrived.mp3")
        pygame.mixer.music.play()
        pixmap = self.pil_to_qpixmap(image)
        size = pixmap.size()
        width = size.width()  # Get width
        height = size.height()  # Get height
        self.receive_image_flag = 0
        # Display image if it is initial image or if it is second image and minor flag has been raise
        if (width == 320 and height == 240):
            self.faceImageLabel.setPixmap(pixmap)
            self.currentImage = image
            self.display_image_flag = 2
        elif (self.minorAlert == 1):
            self.faceImageLabel.setPixmap(pixmap)
            self.currentImage = image
            self.display_image_flag = 2

        # Classify if there is a member variable 'currentImage' and if it meets initial image size requirements
        if hasattr(self, 'currentImage'):
            if (width == 320 and height == 240):
                print('Start classifying')
                cv_image = cv2.cvtColor(np.array(self.currentImage), cv2.COLOR_RGB2BGR)

                # Start the classification thread
                self.classify_thread = ClassifyFace(cv_image)
                self.classify_thread.classification_done.connect(self.handleClassificationResult)
                self.classify_thread.start()
                print('Now classifying')


    def orderButtonClicked(self):
        self.display_image_flag = 1
        pygame.mixer.music.load("Media/photArrived.mp3")
        pygame.mixer.music.play()

    def receiveButtonClicked(self):
        self.receive_image_flag = 1
        pygame.mixer.music.load("Media/welcome_mix.mp3")
        pygame.mixer.music.play()

    def classifyButtonClicked(self):
        # Convert the PIL image to a format suitable for OpenCV
        print("Classify clicked!")
        if hasattr(self, 'currentImage'):
            width,height = self.currentImage.size
            if (width == 320 and height == 240):
                print('Start classifying')
                cv_image = cv2.cvtColor(np.array(self.currentImage), cv2.COLOR_RGB2BGR)

                # Start the classification thread
                self.classify_thread = ClassifyFace(cv_image)
                self.classify_thread.classification_done.connect(self.handleClassificationResult)
                self.classify_thread.start()
                print('Now classifying')

    def handleClassificationResult(self, result):
        print("Classification result:", result)
        # Update the UI based on the classification result
        if ((result['dominant_race'] == 'white')):
            self.spiceLevel = 0   
        elif ((result['dominant_race'] == 'black') or (result['dominant_race'] == 'middle_eastern')):
            self.spiceLevel = 1
        elif ((result['dominant_race'] == 'latino hispanic') or (result['dominant_race'] == 'asian') or (result['dominant_race'] == 'indian')):
            self.spiceLevel = 2
        else:
            self.spiceLevel = -1

        if (int(result['age']) < 18 ):
            self.minorAlert = 1
            pygame.mixer.music.load("Media/child.mp3")
            pygame.mixer.music.play()
        elif (int(result['age']) >= 18 ):
            self.minorAlert = 0
            pygame.mixer.music.load("Media/adult.mp3")
            pygame.mixer.music.play()
        else:
            self.minorAlert = -1

        if (result['dominant_emotion'] == 'happy'):
            self.emotion = 0
        elif (result['dominant_emotion'] == 'angry'):
            self.emotion = 1
        elif (result['dominant_emotion'] == 'sad'):
            self.emotion = 2
        else:
            self.emotion = -1


if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = mainWindow()
    window.show()
    sys.exit(app.exec_())