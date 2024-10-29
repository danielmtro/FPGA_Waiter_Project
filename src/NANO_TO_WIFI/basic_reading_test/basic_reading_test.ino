#include "functions.h"

const int BAUD_RATE = 9600;
const int expected_pixels = 100;
int pixel_count = 0;
bool finished_flush = false;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(BAUD_RATE);  
  Serial1.begin(BAUD_RATE, SERIAL_8N1); //communication between FPGA and arduino

  Serial.println("Starting everything up!");
  
}

void loop() {
  // put your main code here, to run repeatedly:
  
  // only count the expected number of pixels
  finished_flush = false;
  while(pixel_count < expected_pixels)
  {
   if(Serial1.available() >= 2)
     {   
        // Serial.print("Serial 1 buffer: ");
        // Serial.println(Serial1.available());
      
      // extract the bytes from the bufffer
      uint16_t high_byte = Serial1.read();  // First byte (high byte)
      // Serial.print("High Byte received: ");
      // Serial.println(high_byte, HEX);  // Print the pixel data in HEX format

      uint16_t low_byte = Serial1.read();   // Second byte (low byte)
      uint16_t pixel = (high_byte << 4) | (low_byte & 0xFF); // Combine bytes
      // Serial.print("Low byte received: ");
      // Serial.println(low_byte, HEX);  // Print the pixel data in HEX format

      // print out the pixel data that has been received
      Serial.print("Pixel number ");
      Serial.print(pixel_count);
      Serial.print(": ");
      Serial.println(pixel, HEX);  // Print the pixel data in HEX format

      // increment the pixel count found
      pixel_count = pixel_count + 1;
    }
  }

  // flush out the end byte
  while(!finished_flush)
  {
    if(Serial1.available() >= 2)
    {
        // extract the bytes from the bufffer
        uint16_t high_byte = Serial1.read(); 
        uint16_t low_byte = Serial1.read();
        finished_flush = true;
        Serial.println("End of Image");
    }
  }

  pixel_count = 0;
}
