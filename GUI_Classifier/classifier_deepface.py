import cv2
import matplotlib.pyplot as plt
from deepface import DeepFace

# Activate venv

#loading image
img =  cv2.imread("images\\chad_smaller.jpg") #loading image
color_img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

#this analyses the given image and gives values
#when we use this for 1st time, it may give many errors and some google drive links to download some '.h5' and zip files, download and save them in the location where it shows that files are missing.
prediction = DeepFace.analyze(color_img, actions = ['age', 'gender', 'race', 'emotion'])

print(prediction)