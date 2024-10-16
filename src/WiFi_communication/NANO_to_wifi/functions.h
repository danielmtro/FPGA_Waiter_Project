#ifndef _FUNCTIONS_H_
#define _FUNCTIONS_H_

#include <WiFiNINA.h>

uint16_t getPixelData(int index);

void connectToWiFi(const char* ssid, const char* password);

uint16_t receive_UART();
#endif