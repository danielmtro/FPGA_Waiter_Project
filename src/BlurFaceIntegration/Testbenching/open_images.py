import numpy as np
import matplotlib.pyplot as plt
import mplcursors  # For interactive cursor

# Constants
IMG_LENGTH = 240  # Image height
IMG_WIDTH = 320   # Image width

# Function to read image data from a file
def read_image_data(file_name):
    image = np.zeros((IMG_LENGTH, IMG_WIDTH), dtype=np.uint16)
    with open(file_name, "r") as file:
        for i in range(IMG_LENGTH):
            for j in range(IMG_WIDTH):
                line = file.readline()
                if line:
                    image[i, j] = int(line.strip(), 2)  # Convert from binary string to integer
    return image

# Function to convert 12-bit color to RGB (normalized for matplotlib)
def convert_to_rgb(image):
    rgb_image = np.zeros((IMG_LENGTH, IMG_WIDTH, 3), dtype=np.float32)
    for i in range(IMG_LENGTH):
        for j in range(IMG_WIDTH):
            pixel = image[i, j]
            red = (pixel >> 8) & 0xF    # Extract bits 8-11 for red
            green = (pixel >> 4) & 0xF  # Extract bits 4-7 for green
            blue = pixel & 0xF          # Extract bits 0-3 for blue
            # Normalize to [0, 1] for display in matplotlib
            rgb_image[i, j] = [red / 15.0, green / 15.0, blue / 15.0]
    return rgb_image

# Read input and output image data
input_image = read_image_data("input_image_data.txt")
output_image = read_image_data("output_image_data.txt")

# Convert to RGB format
input_image_rgb = convert_to_rgb(input_image)
output_image_rgb = convert_to_rgb(output_image)

# Create the figure and two subplots for input and output images
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 5))

# Display input image in the first subplot (in RGB)
cax1 = ax1.imshow(input_image_rgb)
ax1.set_title('Input Image (Color)')
ax1.set_xticks(np.arange(0, IMG_WIDTH+1, 20))
ax1.set_yticks(np.arange(0, IMG_LENGTH+1, 20))
ax1.set_xticklabels(np.arange(0, IMG_WIDTH+1, 20))
ax1.set_yticklabels(np.arange(0, IMG_LENGTH+1, 20))
ax1.grid(color='white', linestyle='--', linewidth=0.5)

# Display output image in the second subplot (in RGB)
cax2 = ax2.imshow(output_image_rgb)
ax2.set_title('Output Image (Color)')
ax2.set_xticks(np.arange(0, IMG_WIDTH+1, 20))
ax2.set_yticks(np.arange(0, IMG_LENGTH+1, 20))
ax2.set_xticklabels(np.arange(0, IMG_WIDTH+1, 20))
ax2.set_yticklabels(np.arange(0, IMG_LENGTH+1, 20))
ax2.grid(color='white', linestyle='--', linewidth=0.5)

# Create interactive cursors for both input and output images
cursor1 = mplcursors.cursor(cax1, hover=True)
cursor2 = mplcursors.cursor(cax2, hover=True)

# Add hover functionality to display cell information for the input image
@cursor1.connect("add")
def on_add_input(sel):
    x, y = int(sel.target[0]), int(sel.target[1])
    pixel_value = input_image[y, x]
    sel.annotation.set(text=f"Input Cell: ({x}, {y})\nValue: {bin(pixel_value)}")
    sel.annotation.set_fontsize(8)

# Add hover functionality to display cell information for the output image
@cursor2.connect("add")
def on_add_output(sel):
    x, y = int(sel.target[0]), int(sel.target[1])
    pixel_value = output_image[y, x]
    sel.annotation.set(text=f"Output Cell: ({x}, {y})\nValue: {bin(pixel_value)}")
    sel.annotation.set_fontsize(8)

# Display the plot with both subplots
plt.tight_layout()
plt.show()