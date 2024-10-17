from PyQt5.QtCore import QTimer, QTime, Qt, QSize
from PyQt5.QtGui import QPixmap, QFont
import sys
import pyqtgraph as pg
from PyQt5.QtWidgets import *
from PyQt5 import QtCore
from random import randint
import serial
import cv2
import requests

import classifier_deepface


### TO DO ###

# Determine how updateDisplay displays image that has been received

# Connect Arduino to computer, update Arduino IP

class mainWindow(QWidget):
    def __init__(self):
        super().__init__()
        # Initialise layouts
        mainWindow = QVBoxLayout()
        menuBar = QGridLayout()
        graphicsArea = QGridLayout()

        # Layout Structure
        mainWindow.addLayout(graphicsArea)
        mainWindow.addLayout(menuBar)
        
        # Layout Specifics and Styling
        graphicRows = 3
        graphicCols = 4

        screen = QApplication.primaryScreen()
        rect = screen.availableGeometry()

        availableHeight = rect.height()
        graphicsRowsHeight = int(int(availableHeight)/graphicRows)

        # Fonts
        # Title
        titleFont = QFont()
        titleFont.setPointSize(16)

        # Bold Text
        boldFont = QFont()
        boldFont.setBold(True)
        boldFont.setPointSize(13)

        # Regular Text
        regFont = QFont()
        regFont.setPointSize(13)

        # Subtext
        smallFont = QFont()
        smallFont.setPointSize(10)

        # Menubar button font
        menuFont = QFont()
        menuFont.setPointSize(10)

        # Create features

        """
        # Load logo onto label
        self.pixmap = QPixmap('Project/b_University_of_Sydney_b.png')
        self.scaled = self.pixmap.scaled(600,300, aspectRatioMode=Qt.KeepAspectRatio, transformMode=Qt.FastTransformation)
        self.logo = QLabel(self)
        self.logo.setPixmap(self.scaled)

        """

        # Menu Bar buttons
        self.orderButton = QPushButton(text="ORDER", parent=self)
        self.orderButton.setFixedSize(400, 110)
        self.orderButton.clicked.connect(self.orderButtonClicked)
        self.orderButton.setFont(menuFont)

        # Flag Init
        self.flag_text = 0
        self.spiceLevel = 0
        self.image_flag = 0
        self.display_image_flag = 0

        # creating a timer object
        timer = QTimer(self)
        timer.timeout.connect(self.updateDisplay)
        timer.start(1000)

        # Set grid layout dimensions

        for i in range(4):
            graphicsArea.setColumnMinimumWidth(i,graphicsRowsHeight)
            graphicsArea.setColumnStretch(i,0)
        graphicsArea.setHorizontalSpacing(0)

        for j in range(3):
            graphicsArea.setRowMinimumHeight(j,graphicsRowsHeight)
            graphicsArea.setRowStretch(j,0)
        graphicsArea.setVerticalSpacing(0)

        for i in range(4):
            menuBar.setColumnMinimumWidth(i,graphicsRowsHeight)
            menuBar.setColumnStretch(i,0)
        menuBar.setHorizontalSpacing(0)

        for j in range(1):
            menuBar.setRowMinimumHeight(j,int(graphicsRowsHeight/2))
            menuBar.setRowStretch(j,0)
        menuBar.setVerticalSpacing(0)

        # Layout - Widgets
        self.spiceWidget = QFrame()
        self.faceWidget = QFrame()

        # Menu Bar
        # Set the background color of the main window to dark grey
        # Set the faceWidget to have a transparent background
        menuBar.setStyleSheet("background-color: #303030;") 
        menuBar.addWidget(self.orderButton, 0, 1, 1, 2, Qt.AlignHCenter)   
        graphicsArea.addWidget(self.faceWidget, 0, 0, 3, 4)
        graphicsArea.addWidget(self.spiceWidget, 0, 0, 3, 4)
        self.setLayout(mainWindow)
        
        # Set up Arduino Wifi connection
        arduino_ip = 'http://<arduino_ip_address>'
        url = f'{arduino_ip}/'

    def updateDisplay(self):
        # getting current time
        current_time = QTime.currentTime()
 
        # converting QTime object to string
        label_time = current_time.toString('hh:mm:ss')

        if self.display_image_flag == 1:
            image = "images/chad_small.jpg"
        else:
            image = "images/init.png"

        self.faceWidget.setStyleSheet(
            f"""QFrame {{border-image: url({image}) 0 0 0 0 stretch;}}""")

        if self.display_image_flag == 1:
            if self.spiceLevel == 0:
                self.spiceWidget.setStyleSheet(
                    """QFrame {border-image: url("images/MildSpice.png") 0 0 0 0 fit fit;}""")
            elif self.spiceLevel == 1:
                self.spiceWidget.setStyleSheet(
                    """QFrame {border-image: url("images/MedSpice.png") 0 0 0 0 fit fit;}""")
            elif self.spiceLevel == 2:
                self.spiceWidget.setStyleSheet(
                    """QFrame {border-image: url("images/HotSpice.png") 0 0 0 0 fit fit;}""")
        else:
            self.spiceWidget.setStyleSheet(
                """QFrame {border-image: url("images/NoSpice.png") 0 0 0 0 fit fit;}""")

    def orderButtonClicked(self):

        #self.sendData(0, 0, 1)

        self.display_image_flag = 1
        img =  cv2.imread("images\\chad_small.jpg") #loading image

        prediction = classifier_deepface.classify_face(img)
        prediction = prediction[0]

        if (prediction['dominant_race'] == 'white'):
            self.spiceLevel = 0
        elif (prediction['dominant_race'] == 'black' or prediction['dominant_race'] == 'middle eastern' or prediction['dominant_race'] == 'latino hispanic'):
            self.spiceLevel = 1
        elif (prediction['dominant_race'] == 'asian' or prediction['dominant_race'] == 'indian'):
            self.spiceLevel = 2

        print(prediction)

    def imageReceived(self):
        """
        self.image_flag = 1
        img =  cv2.imread("images\\chad_small.jpg") #loading image

        prediction = classifier_deepface.classify_face(img)

        if (prediction['dominant_race'] == 'white'):
            self.spiceLevel = 0
        elif (prediction['dominant_race'] == 'black' or prediction['dominant_race'] == 'middle eastern' or prediction['dominant_race'] == 'latino hispanic'):
            self.spiceLevel = 1
        elif (prediction['dominant_race'] == 'asian' or prediction['dominant_race'] == 'indian'):
            self.spiceLevel = 2

        self.sendData(prediction['age'], prediction['dominant_emotion'], 0)     
        self.image_flag = 0   
        """

    def check_interrupt(self):
        try:
            response = requests.get(self.arduino_ip)
            if response.status_code == 200:
                message = response.text.strip()
                if "Analyse Image Sent" in message:
                    if self.image_flag == 0:
                        self.imageReceived()
                if "Display Image Sent" in message:
                    self.updateDisplay()
                #else:
                #    self.label.setText("No Interrupt")
        except requests.exceptions.RequestException as e:
            print(f"Error: {e}")

    def sendData(self, age, emotion, order):
        """
        msg = [age, emotion, orderFlag]

        # Send the message via a GET request
        response = requests.get(url, params={'message': msg})

        # Print the response from the Arduino
        print(response.text)
        """

if __name__ == "__main__":
    import sys

    app = QApplication(sys.argv)
    window = mainWindow()
    window.showMaximized()
    sys.exit(app.exec_())