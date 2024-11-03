# VFX_FPGA: Assignment 2 for MTRX3700.

# TO DO

1. Test Bench for Address Generator
2. Test Bench for Data Expander (Adam have you done this already?)
3. Test Bench for FFT 

## Rules
1. Do not edit the main. Always branch before you edit, create new files, etc. Only push to the main once your module is complete and passes its test benches
2. Once you have created a module, immediately make a test bench
3. Record test bench goals and things you want to see from it in the overleaf before its made (make sure tb's are informative).
4. Document your module in this README including all important info incl. clock cycles required for initialisation and/or functional use
    1. This was an issue for the debounce module. Noone making the main testbench understood it's clock cycle requirements (50,000) and tried to use it anyway
5. Read documentation before using a module
6. 
7. 

## Branch Naming Convention
name.date.whatever tf you're trying to do

## DON'T USE OLD PIN ASSIGNMENTS

Use the camera_enable.qsf file for pin assignments

## Things to Do:

- Microphone working
  Make sure that appropriate filtering is done to detect things in the human voice range.
  Determine the max frequency based on sampling frequency. Then filter out everything above that using a low pass filter.
  When using the fft in the IP's don't worry about the imaginary components (just enter them as zero)
  HUman Frequency f = fs * k/N (N shouldbe 1024, fs sampling frequency, k is the output of the fft)
  
    - implement an FFT
    - output the peak frequency (and hopefully amplitude of signal)

- Streaming from camera into BRAM
    - storing in BRAM
    - sending to VGA
    - Handle FIFO stuff
    - Stream output to VGA

- Apply filters to frames including:
      the filters should be general enough so that they can be reconfigured easily if we want to change
      them based on the amplitude and different frequencies.
    - colour
    - brightness
    - blurring
    - edge detection

- Board interface LCD and pushbuttons 
    - Create module to interface with board to select frames based on this (probably be an fsm)
    - Make sure that the states here are binary so that they can be easily read by a different operation
    - Create LCD interface based on the state output of the fsm in the previous task

## Responsibilities


# Modules

## video_data_expander.sv
This module takes a static image from BRAM of which has AxB pixels and where each pixel is represented by 3 bit RGB value. 
It takes the number of pixels as an input parameter as well as the number of bits representing each pixel. However it is currently only configured for 3 bit GRB values and is not smart enough to change yet.
It is always outputting VALID unless a reset signal is received.
It is receives a ready signal and will only output a new value if the ready signal is received!!
It has a pulse to indicate the beginning and end of a packet (a frame, an image etc.)

## State_machine_with_display.sv
Inputs: 
    [3:0]key: All of the keys on the FPGA
    A bunch of other DATA I/O ports on the FPGA (if its in caps then just use as a pin assignment)
Outputs:
    [1:0]filter_type: The current 'state' of the machine. Filter type mapping shown below.

STATE MAPPING
    00: COLOUR
    01: BLUR
    10: BRIGHTNESS
    11: EDGES

Module Explanation
This module controls what the current state of the overall machine is and displays the state on the LCD.
Pressing any of the keys on the FPGA will correspond to a change to that state.
    


## inversion_filter.sv
This module receives a stream of pixel data each which is 12 bit RGB and outputs a data stream of the same size with all values inverted. It only inverts the pixels if the frequency flag `freq_flag` is above a given threshold (currently set to 1 [01]).
This module has no latency and is not at all reliant on the clock.

## brightness_filter
This module increases the brightness of the image based on the maximum output frequency of the voice.
It receives a data stream of 12 bit RGB values and increases their value by multiplying the R, G, B values and keeping the same ratio between them. If the multiple of the result of the multiplication is greater than 255 (1111) then the value is set to 255.
There is no latency
*Note that the multiplication factor = freq_flag + 1 != freq_flag*