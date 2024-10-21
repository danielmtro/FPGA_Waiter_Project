#ifndef _FUNCTIONS_H_
#define _FUNCTIONS_H_

#include <WiFiNINA.h>

/**
 * @brief this connects the arduino Nano to WiFi and prints 
 * some useful information. Notably it prints the 
 * IP address which must be used by your code in python
 * 
 * @param ssid is the WiFi name
 * @param password is the WiFi password
 */
void connectToWiFi(const char* ssid, const char* password);

/**
 * @brief this function receives 1 incoming pixel from the FPGA
 * 
 * @return pixel as a uint16_t
 */
uint16_t receive_pixel();
#endif