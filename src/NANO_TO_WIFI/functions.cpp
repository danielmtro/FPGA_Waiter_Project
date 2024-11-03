#include "functions.h"

void connectToWiFi(const char* ssid, const char* password){
  int status = WL_IDLE_STATUS; 

  //connect to WIFI network
  while (status != WL_CONNECTED) {
    delay(1000);
    Serial.println("Trying to create connection to WiFi...");
    status = WiFi.begin(ssid, password);
  }

  //announce successful conenction
  Serial.print("Successfully Connected to WiFi network: ");
  Serial.println(WiFi.SSID());

  //announce ip address of arduino
  //copy this IP address to the Python file which is connecting
  IPAddress ip = WiFi.localIP();
  Serial.print("Arduino IP: ");
  Serial.println(ip);
  return;
}


void serialFlush(){
  while(Serial1.available() > 0) {
    char t = Serial1.read();
  }
}

/*
Function processes an image. Will be a busy wait and
stuck in this function until it finishes
*/
// void process_image(int expected_pixels,
//                    bool print_pixels)
// {
//  // only count the expected number of pixels
//   bool finished_flush = false;
//   int pixel_count = 0;

//   while(pixel_count < expected_pixels)
//   {
//    if(Serial1.available() >= 2)
//      {   
//         // Serial.print("Serial 1 buffer: ");
//         // Serial.println(Serial1.available());
//       if(pixel_count  == 0)
//       {
//         startTime = millis(); // start recording when we receive the first image
//       }
      
//       // extract the bytes from the bufffer
//       uint16_t high_byte = Serial1.read();  // First byte (high byte)
//       uint16_t low_byte = Serial1.read();   // Second byte (low byte)
//       uint16_t pixel = (high_byte << 4) | (low_byte & 0xFF); // Combine bytes

//       // print out the pixel data that has been received
//       if(print_pixels)
//       {
//         Serial.print("Pixel number ");
//         Serial.print(pixel_count);
//         Serial.print(": ");
//         Serial.println(pixel, HEX);  // Print the pixel data in HEX format
//       }

//       // increment the pixel count found
//       pixel_count = pixel_count + 1;
//     }
//   }

//   // flush out the end byte and print a final message on timing
//   // print a message for how long it took the overall message to send
//   while(!finished_flush)
//   {
//     if(Serial1.available() >= 2)
//     {
//         // extract the bytes from the bufffer
//         uint16_t high_byte = Serial1.read(); 
//         uint16_t low_byte = Serial1.read();
//         finished_flush = true;

//         endTime = millis();
//         Serial.println("End of Image");

//         unsigned long elapsedTime = endTime - startTime; // Calculate the elapsed time
//         Serial.print("Process Time: ");
//         Serial.print(elapsedTime);
//         Serial.println(" milliseconds");
//     }
//   }

// }

// void alternative_wifi_loop() {
//   // put your main code here, to run repeatedly:
  
//   // Check for incoming clients
//   WiFiClient client = server.available(); 
//   if(client)
//   {
//     // keep reading in data as long as we are connected
//     while(client.connected())
//     {
//       // process the image
//       // process_image(expected_pixels);
//     }
  
//   }

//   // stop the client if we can't connect 
//   Serial.println("Dropping client");
//   client.stop(); 
//   Serial.println("--------------------------------------------------------------------------------------------------------");
//   Serial.println("--------------------------------------------------------------------------------------------------------");
//   Serial.println("--------------------------------------------------------------------------------------------------------");
//   Serial.println("--------------------------------------------------------------------------------------------------------");

// }