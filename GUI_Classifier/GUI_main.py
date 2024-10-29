from PyQt5.QtCore import QTimer, QTime, Qt, QSize
from PyQt5.QtGui import QPixmap, QFont, QImage
import sys
import pyqtgraph as pg
from PyQt5.QtWidgets import *
from PyQt5 import QtCore
from random import randint
import serial
import cv2
import requests
import numpy as np
from PIL import Image

import classifier_deepface


### TO DO ###

# Determine how updateDisplay displays image that has been received

# Connect Arduino to computer, update Arduino IP

from PyQt5.QtCore import QTimer, QTime, Qt, QSize
from PyQt5.QtGui import QPixmap, QFont
import sys
import pyqtgraph as pg
from PyQt5.QtWidgets import *
from PyQt5 import QtCore
from random import randint
import serial

spiceLevel = 0

class mainWindow(QWidget):
    def __init__(self):
        super().__init__()
        #######################################################
        # Initialise layouts

        # Display: current speed, current direction, current position, last floor, next floor, weight
        # Input: speed, floor, emergency stop
        mainWindow = QVBoxLayout()
        menuBar = QGridLayout()
        graphicsArea = QGridLayout()

        #######################################################
        # Nested Layout Structure
        mainWindow.addLayout(graphicsArea)
        mainWindow.addLayout(menuBar)
        
        #######################################################
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

        ######################################################################################################################################
        # Create features

        """
        # Load logo onto label
        self.pixmap = QPixmap('Project/b_University_of_Sydney_b.png')
        self.scaled = self.pixmap.scaled(600,300, aspectRatioMode=Qt.KeepAspectRatio, transformMode=Qt.FastTransformation)
        self.logo = QLabel(self)
        self.logo.setPixmap(self.scaled)

        """

        ######################################################################################################################################
        # Buttons

        # Menu Bar buttons
        self.orderButton = QPushButton(text="ORDER", parent=self)
        self.orderButton.setFixedSize(400, 110)
        self.orderButton.clicked.connect(self.orderButtonClicked)
        self.orderButton.setFont(menuFont)

        #######################################################
        # Flag Init

        # textEdit
        self.flag_text = 0
        self.spiceLevel = 0
        self.display_image_flag = 0

        #######################################################
        # Timer

        # creating a timer object
        timer = QTimer(self)
 
        timer.timeout.connect(self.updateDisplay)

        # update sensors every 0.5 second
        timer.start(250)

        #######################################################
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

        #######################################################
        # Layout - Widgets

        # Update layout to include QLabel overlays for images
                # Update layout to include QLabel overlays for images
        self.spiceWidget = QFrame()
        self.spiceWidget.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)  # Allow QFrame to expand
        self.spiceLayout = QVBoxLayout(self.spiceWidget)  # Add a layout inside the QFrame
        self.spiceImageLabel = QLabel(self.spiceWidget)  # Create QLabel
        self.spiceImageLabel.setScaledContents(True)  # Scale the pixmap to fill QLabel
        self.spiceImageLabel.setAlignment(Qt.AlignCenter)  # Center the QLabel content
        self.spiceLayout.addWidget(self.spiceImageLabel)  # Add QLabel to QFrame layout
        self.spiceLayout.setContentsMargins(0, 0, 0, 0)  # Remove margins

        self.faceWidget = QFrame()
        self.faceWidget.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)  # Allow QFrame to expand
        self.faceLayout = QVBoxLayout(self.faceWidget)  # Add a layout inside the QFrame
        self.faceImageLabel = QLabel(self.faceWidget)  # Create QLabel
        self.faceImageLabel.setScaledContents(True)  # Scale the pixmap to fill QLabel
        self.faceImageLabel.setAlignment(Qt.AlignCenter)  # Center the QLabel content
        self.faceLayout.addWidget(self.faceImageLabel)  # Add QLabel to QFrame layout
        self.faceLayout.setContentsMargins(0, 0, 0, 0)  # Remove margins

        # Apply stylesheet for formatting
        self.faceWidget.setStyleSheet("QFrame {border: 2px solid black; border-radius: 10px;}")
        self.spiceWidget.setStyleSheet("QFrame {border: 2px solid red; border-radius: 10px;}")

        # Menu Bar
        menuBar.addWidget(self.orderButton, 0, 1, 1, 2, Qt.AlignHCenter)   
        graphicsArea.addWidget(self.faceWidget, 0, 0, 3, 4)
        graphicsArea.addWidget(self.spiceWidget, 0, 0, 3, 4)
        self.setLayout(mainWindow)

    def pil_to_qpixmap(self, image):
        image = image.convert("RGBA")  # Convert to RGBA for PyQt compatibility
        data = image.tobytes("raw", "RGBA")
        qimage = QImage(data, image.width, image.height, QImage.Format_RGBA8888)
        return QPixmap.fromImage(qimage)

    def updateDisplay(self):
        # Set dynamic image on the face image label
        if self.display_image_flag == 1:
            image = Image.open("images/chad_small.jpg")
            pixmap = self.pil_to_qpixmap(image)
            self.faceImageLabel.setPixmap(pixmap)
        else:
            pixmap = QPixmap("images/init.png")
            self.faceImageLabel.setPixmap(pixmap)

        # Set dynamic image on the spice image label
        if self.display_image_flag == 1:
            if self.spiceLevel == 0:
                self.spiceImageLabel.setPixmap(QPixmap("images/MildSpice.png"))
            elif self.spiceLevel == 1:
                self.spiceImageLabel.setPixmap(QPixmap("images/MedSpice.png"))
            elif self.spiceLevel == 2:
                self.spiceImageLabel.setPixmap(QPixmap("images/HotSpice.png"))
        else:
            self.spiceImageLabel.setPixmap(QPixmap("images/NoSpice.png"))

    def orderButtonClicked(self):
        self.spiceLevel = self.spiceLevel + 1
        self.display_image_flag = 1

        if self.spiceLevel >= 3:
            self.spiceLevel = 0
        
        print(self.spiceLevel)
        #ser.write(bytes('E', 'UTF-8'))
           

if __name__ == "__main__":
    import sys

    # Init Values
    
    spiceLevel = 0

    #ser = serial.Serial('COM6',9600)


    app = QApplication(sys.argv)
    window = mainWindow()
    window.showMaximized()
    sys.exit(app.exec_())