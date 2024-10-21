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

uint16_t receive_pixel(){

    // Receive the high and low bytes
    uint8_t high_byte = Serial.read();  // First byte (high byte)
    uint8_t low_byte = Serial.read();   // Second byte (low byte)

    // Reconstruct the 12-bit pixel values
    uint16_t pixel = (high_byte << 4) | (low_byte & 0xFF); // Combine bytes

    // Here you can store the pixel in an array or process it as needed
    Serial.print("Pixel data received: ");
    Serial.println(pixel, HEX);  // Print the pixel data in HEX format
    return pixel;

}