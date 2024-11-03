import numpy as np
import matplotlib.pyplot as plt

# Constants
IMG_HEIGHT = 240
IMG_WIDTH = 320

# Initialize the image with grey (base color)
image = np.zeros((IMG_HEIGHT, IMG_WIDTH, 3))  # Create a 3-channel (RGB) image

# Define colors in RGB
GREY = [0.5, 0.5, 0.5]  # Grey
BLACK = [0, 0, 0]  # Black
BLUE = [0, 0, 1]  # Blue
RED = [1, 0, 0]  # Red
GREEN = [0, 1, 0]  # Green
WHITE = [1, 1, 1]  # White

# Create the image pattern
for i in range(IMG_HEIGHT):
    for j in range(IMG_WIDTH):
        # Base color for the image
        image[i, j] = GREY

        # Add two vertical lines to simulate noise
        if ((7 < j < 13) or (307 < j < 313)):
            image[i, j] = BLACK  # Black

        # Add one horizontal line outside of blurring scope
        elif (227 < i < 233):
            image[i, j] = BLACK  # Black

        # Make the outer and inner diamonds
        if i <= 120:
            # Outer diamond top left half
            if (140 - i <= j <= 140 - i + 4):  # 5 pixels thick
                image[i, j] = BLUE  # Blue

            # Outer diamond top right half
            elif (180 + i <= j <= 180 + i + 4):  # 5 pixels thick
                image[i, j] = BLUE  # Blue

            # Top half of the inner diamond
            elif (j - 160) <= (i - 20) and (j - 160) >= (20 - i):
                # Add a thick diagonal line every 40 pixels
                if (i + j) % 40 < 5:  # Continuous 5-pixel thick diagonal line
                    image[i, j] = RED  # Red
                else:
                    image[i, j] = WHITE  # White

        else:
            # Outer diamond bottom left half
            if (i - 100 <= j <= i - 100 + 4):  # 5 pixels thick
                image[i, j] = BLUE  # Blue

            # Outer diamond bottom right half
            elif (420 - i <= j <= 420 - i + 4):  # 5 pixels thick
                image[i, j] = BLUE  # Blue

            # Bottom half of the inner diamond
            elif (j - 160) <= (220 - i) and (j - 160) >= (i - 220):
                # Add diagonal lines every 40 pixels
                if (80 + j - i) % 40 < 5:  # Continuous 5-pixel thick diagonal line
                    image[i, j] = GREEN  # Green
                else:
                    image[i, j] = WHITE  # White

# Plot the image
plt.imshow(image)
plt.axis('off')
plt.show()