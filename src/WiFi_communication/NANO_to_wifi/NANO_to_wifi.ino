#include "functions.h"

const char* ssid = "KIRBYBOTS";      // Your Wi-Fi network SSID
const char* password = "room330!";  // Your Wi-Fi network password

uint16_t pixel;



WiFiServer server(80);   // Create a server on port 80

void setup() {
  Serial.begin(9600);  // Communication between Arduino and WiFi
  connectToWiFi(ssid, password);
  server.begin();        // Start the server
}

void loop() {
  WiFiClient client = server.available();  // Check for incoming clients

  if (client) {
    Serial.println("Client connected");
    delay(1000);
    while (client.connected()) {
      if (client.available() > 0){
        String request = client.readStringUntil('\n');
        if (request == "SEND_DATA"){

          if(Serial.available() >= 2){
            pixel = receive_UART();
            // pixel = Serial.read();
            client.write((uint8_t)(pixel >> 8));  // Send high byte
            client.write((uint8_t)(pixel & 0xFF)); // Send low byte
          }
          else{
            client.write("NULL");
          }
          
        }
      }
      //-------------------
      // if (Serial.available() >= 2) {  // Wait until at least two bytes are available
      //     Serial.println("pixel available");
      //     pixel = receive_UART();


      //     client.write((uint8_t)(pixel >> 8));  // Send high byte
      //     client.write((uint8_t)(pixel & 0xFF)); // Send low byte

      //     Serial.println("data sent to PC over wifi");
      //   }
      //-------------------OL' FAITHFUL----------------
      // for (int i = 0; i < 320 * 240; i++) {
      //   uint16_t pixel = getPixelData(i);  // Function to get pixel data
      //   client.write((uint8_t)(pixel >> 8));  // Send high byte
      //   client.write((uint8_t)(pixel & 0xFF)); // Send low byte
      //   Serial.println("sent data");
      // }
      
    }
    client.stop();
  }
}


