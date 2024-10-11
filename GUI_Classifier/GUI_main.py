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

        self.spiceWidget = QFrame()
        self.faceWidget = QFrame()

        # Menu Bar
        menuBar.addWidget(self.orderButton, 0, 1, 1, 2, Qt.AlignHCenter)   
        graphicsArea.addWidget(self.faceWidget, 0, 0, 3, 4)
        graphicsArea.addWidget(self.spiceWidget, 0, 0, 3, 4)
        self.setLayout(mainWindow)

    def updateDisplay(self):
        # getting current time
        current_time = QTime.currentTime()
 
        # converting QTime object to string
        label_time = current_time.toString('hh:mm:ss')

        #self.faceWidget.setStyleSheet(
        #        """QFrame {background-image: url("images/chad.jpg"); 
        #               background-position: center; 
        #               background-repeat: no-repeat; 
        #               object-fit: cover;}""")

        self.faceWidget.setStyleSheet(
                """QFrame {border-image: url("images/chad.jpg") 0 0 0 0 fit fit;}""")

        if self.spiceLevel == 0:
            self.spiceWidget.setStyleSheet(
                """QFrame {border-image: url("images/MildSpice.png") 0 0 0 0 stretch stretch;}""")
        elif self.spiceLevel == 1:
            self.spiceWidget.setStyleSheet(
                """QFrame {border-image: url("images/MedSpice.png") 0 0 0 0 stretch stretch;}""")
        elif self.spiceLevel == 2:
            self.spiceWidget.setStyleSheet(
                """QFrame {border-image: url("images/HotSpice.png") 0 0 0 0 stretch stretch;}""")
        else:
            self.spiceWidget.setStyleSheet(
                """QFrame {border-image: url("images/NoSpice.png") 0 0 0 0 stretch stretch;}""")

    def orderButtonClicked(self):
        self.spiceLevel = self.spiceLevel + 1

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