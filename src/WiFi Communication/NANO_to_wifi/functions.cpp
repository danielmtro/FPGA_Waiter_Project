#include "functions.h"

uint16_t getPixelData(int index) {
  // Simulate retrieving pixel data; this would be replaced by actual data
  // Calculate green and blue values for 12-bit color
  int greenValue = map(index, 0, 76800, 0, 15);  // Gradually increase green from 0 to 15
  int blueValue = map(index, 0, 76800, 15, 0);   // Gradually decrease blue from 15 to 0

  // Combine red, green, and blue into a 12-bit RGB value (red stays at 0)
  int rgb12bit = (greenValue << 4) | blueValue;
  return rgb12bit;  // Example: return a 12-bit RGB value
}

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
  IPAddress ip = WiFi.localIP();
  Serial.print("Arduino IP: ");
  Serial.println(ip);

  return;
}

uint16_t receive_UART(){

    // Receive the high and low bytes
    uint8_t high_byte = Serial.read();  // First byte (high byte)
    uint8_t low_byte = Serial.read();   // Second byte (low byte)

    // Reconstruct the 12-bit pixel value
    uint16_t pixel = (high_byte << 4) | (low_byte >> 4); // Combine bytes

    // Here you can store the pixel in an array or process it as needed
    Serial.print("Pixel data received: ");
    Serial.println(pixel, HEX);  // Print the pixel data in HEX format
    return pixel;

}