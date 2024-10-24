#include "functions.h"

const char* ssid = "KIRBYBOTS";      // Your Wi-Fi network SSID
const char* password = "room330!";  // Your Wi-Fi network password
bool rcv_image_flag = false;
uint16_t pixel;

//delcare a pin number for sending info TO the FPGA GPIO
int READY_OUT = 4;

// Create a server on port 80
WiFiServer server(80);   

void setup() {
  // Communication between Arduino and Serial monitor in IDE
  Serial.begin(115200);  

  //Setup communication from arduino to WIFI
  // Start the server
  connectToWiFi(ssid, password);
  server.begin();        

  
  //communication between FPGA and arduino
  //Note: we cannot use Serial1.write because the FPGA doesn't have UART_RX
  Serial1.begin(115200, SERIAL_8N1); //communication between FPGA and arduino

  //declare READY_OUT as output pin
  pinMode(READY_OUT, OUTPUT); 
  digitalWrite(READY_OUT, LOW);
}


void loop() {

  // Check for incoming clients
  WiFiClient client = server.available();  

  // if (Serial1.available() > 1){
  //   uint16_t pixel = receive_pixel();

  //   // Serial.print("Pixel is: ")
  // }

  if (client) {
    Serial.println("Client connected");
    delay(1000);

    while (client.connected()) {
      //if there is a message (request) being received over WiFI 
      digitalWrite(READY_OUT, LOW);
      if (client.available() > 0){
        //read the entire message
        //NOTE: 1 character messages have been used for speed
        String request = client.readStringUntil('\n');

        //remove everything from the incoming buffer from the FPGA
        //buffer size is only 256 bytes which is half as many pixels
        if (request == "F"){
          Serial1.flush();
        }

        //read 1 pixel off the Serial1 buffer and send it over WiFi
        else if (request == "S"){
            digitalWrite(READY_OUT, HIGH);
            if(Serial1.available() >= 2){              
              pixel = receive_pixel();
              //send pixel over WiFi
              //NOTE: this is the slow part
              //TODO: Can you please sanity the high byte send? 
              //I suspect it should actually by >> 4 considering the data in
              //pixel is only 12 bits not actually 16
              client.write((uint8_t)(pixel >> 4));  // Send high byte
              client.write((uint8_t)(pixel & 0xFF)); // Send low byte
            }
        }
      }
    }
    digitalWrite(READY_OUT, LOW);
    Serial.println("Dropping client");
    client.stop();
  }
}


