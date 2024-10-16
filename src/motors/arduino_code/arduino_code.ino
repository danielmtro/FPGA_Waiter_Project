int FPGA_RX = 12;

void setup() {
  // put your setup code here, to run once:
  // Pinmode (FPGA_RX, INPUT)
  Serial.begin(115200);

  Serial1.begin(115200);
}

void loop() {
  // put your main code here, to run repeatedly:
  
  if(Serial1.available() > 0)
  {
    char incomingByte = Serial1.read();
    Serial.print(incomingByte);
  }
}
