import cv2
import numpy as np
from matplotlib import pyplot as plt

# Load the image (in grayscale)
image = cv2.imread('chadho.png', cv2.IMREAD_GRAYSCALE)

# Define the first 5x5 kernel (for vertical top/bottom edges)
kernel1 = np.array([
    [  2.0,  2.0,  4.0,  2.0,  2.0],
    [  1.0,  2.0,  2.0,  2.0,  1.0],
    [    0,    0,    0,    0,    0],
    [ -2.0, -2.0, -2.0, -2.0, -2.0],
    [ -2.0, -2.0, -4.0, -2.0, -2.0]
])

# Define the second 5x5 kernel (for horizontal left/right edges)
kernel2 = np.array([
    [ 2.0,  1.0,  0,  -2.0,  -2.0],
    [ 2.0,  2.0,  0,  -2.0,  -2.0],
    [ 4.0,  2.0,  0,  -2.0,  -4.0],
    [ 2.0,  2.0,  0,  -2.0,  -2.0],
    [ 2.0,  1.0,  0,  -2.0,  -2.0]
])

# Apply the first kernel to the image (vertical edges)
output_image1 = cv2.filter2D(src=image, ddepth=-1, kernel=kernel1)

# Apply the second kernel to the image (horizontal edges)
output_image2 = cv2.filter2D(src=image, ddepth=-1, kernel=kernel2)

# Create masks to extract the top and bottom from output_image1 (vertical)
vertical_edges = np.zeros_like(output_image1)
vertical_edges[output_image1 > 0] = 255  # Retain non-zero edges from the vertical image

# Create masks to extract the left and right from output_image2 (horizontal)
horizontal_edges = np.zeros_like(output_image2)
horizontal_edges[output_image2 > 0] = 255  # Retain non-zero edges from the horizontal image

# Combine the vertical and horizontal edges
combined_edges = cv2.bitwise_or(vertical_edges, horizontal_edges)

# Display the original, filtered images, and the combined edge result
plt.subplot(1, 4, 1)
plt.imshow(image, cmap='gray')
plt.title('Original Image')
plt.axis('off')

plt.subplot(1, 4, 2)
plt.imshow(output_image1, cmap='gray')
plt.title('Vertical (Top/Bottom) Edges')
plt.axis('off')

plt.subplot(1, 4, 3)
plt.imshow(output_image2, cmap='gray')
plt.title('Horizontal (Left/Right) Edges')
plt.axis('off')

plt.subplot(1, 4, 4)
plt.imshow(combined_edges, cmap='gray')
plt.title('Combined Edges')
plt.axis('off')

# Show the figure
plt.show()