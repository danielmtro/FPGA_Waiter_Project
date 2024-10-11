import sys
from  PyQt5.QtWidgets import *
from PyQt5.QtCore import *

class FrameExample(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Frame Example")
        self.setGeometry(100, 100, 600, 600)

        self.frame = QFrame()
        self.frame.setStyleSheet("background-color:skyblue")

        self.frame.setMinimumSize(QSize(200, 200))
        self.frame.setSizePolicy(
            QSizePolicy.MinimumExpanding, QSizePolicy.Fixed)

        hbox = QHBoxLayout()

        # align left
        hbox.addWidget(self.frame, 1)
        hbox.addStretch(2)

        # align centre
        # hbox.addStretch()
        # hbox.addWidget(self.frame)
        # hbox.addStretch()

        self.frame1 = QFrame()
        self.frame1.setStyleSheet("background-color:lightgreen")

        layout = QVBoxLayout()
        layout.addLayout(hbox)
        layout.addWidget(self.frame1)
        self.setLayout(layout)


if __name__=="__main__":
    app = QApplication(sys.argv)
    countrywin =FrameExample()

    countrywin.show()
    sys.exit(app.exec_())