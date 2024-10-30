#include <WiFiNINA.h>
#include "functions.h"

int count_wait = 0;

// variables for timing how long it takes images to send
unsigned long startTime;
unsigned long endTime;

// // variables for wifi connection
// const char* ssid = "KIRBYBOTS";      // Your Wi-Fi network SSID
// const char* password = "room330!";  // Your Wi-Fi network password

// new version for wifi
const char* ssid = "eb542147pi";      // Your Wi-Fi network SSID
const char* password = "turtlebot";  // Your Wi-Fi network password

// general variables to consider
const int BAUD_RATE = 115200;
const int expected_pixels = 320 * 240;
int pixel_count = 0;
bool finished_flush = false;

// Create a server on port 80
WiFiServer server(80);  

void setup() {
  // put your setup code here, to run once:
  Serial.begin(BAUD_RATE);  
  Serial1.begin(BAUD_RATE, SERIAL_8N1); //communication between FPGA and arduino

  //Setup communication from arduino to WIFI
  // Start the server
  connectToWiFi(ssid, password);
  server.begin();  

  //flush Serial1
  serialFlush();

  Serial.println("Starting everything up!");
  
}

/*
Deprecated function - not really used anymore because
you're not meant to read serial as 16 bits
*/
uint16_t read_pixel()
{
  uint16_t high_byte = Serial1.read();  // First byte (high byte)
  uint16_t low_byte = Serial1.read();   // Second byte (low byte)
  uint16_t pixel = (high_byte << 4) | (low_byte & 0xFF); // Combine bytes
  return pixel;
}

void waitForSOP()
{
  bool sop_not_found = true;
  while(sop_not_found)
  {

    // check if there are two bytes available
    if(Serial1.available() >= 2)
    {
      // extract the bytes from the bufffer
      uint16_t pixel = read_pixel();

      if(pixel == 0x00A){
        Serial.println("Starting Image Read");
        sop_not_found = false;
      }
      else 
      {
        Serial.println("Another process taking place - needs reset.");

        // clear the buffer
        while(Serial1.available() > 0){uint8_t thing = Serial1.read();}
      
        Serial.println("Finished flushing the serial buffer");
      }
    }
  }
  // exit function
  return;
}


void loop()
{
  WiFiClient client = server.available();
  // put your main code here, to run repeatedly:
  bool finding_client = true;
  while(finding_client)
  {
    count_wait++;
    if(count_wait%1000000 == 0){Serial.println("Searching for client");}
  
    WiFiClient client = server.available();

    if(client) {
      Serial.println("Client Connected");
      finding_client = false;
    }
  }

  while(client.connected())
  {
    waitForSOP();
    startTime = millis();

    while(pixel_count < expected_pixels)
    {   
        if(Serial1.available() >= 2)
        {   
            // // print out the pixel data that has been received
            Serial.print("Pixel number ");
            Serial.println(pixel_count);

            uint8_t high_byte = Serial1.read();  // First byte (high byte)
            uint8_t low_byte = Serial1.read();   // Second byte (low byte)
            client.write(high_byte);  // Send high byte
            client.write(low_byte); // Send low byte
            pixel_count = pixel_count + 1;
        }
    }

    endTime = millis();
    Serial.println("End of Image");

    unsigned long elapsedTime = endTime - startTime; // Calculate the elapsed time
    Serial.print("Process Time: ");
    Serial.print(elapsedTime);
    Serial.println(" milliseconds");

    pixel_count = 0;
  }


  Serial.println("Client Disconnected");
  Serial.println("--------------------");
  serialFlush();
  client.stop(); 

}