
#include "EEPROM.h"

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("\nTesting EEPROM Library\n");
  if (!EEPROM.begin(1000)) {
    Serial.println("Failed to initialise EEPROM");
    Serial.println("Restarting...");
    delay(1000);
    ESP.restart();
  }

  int address = 0;


  String sentence = "";
  EEPROM.writeString(address, sentence);
  address += sentence.length() + 1;

  EEPROM.commit();
  address = 0;
  

  Serial.println(EEPROM.readString(address));
  address += sentence.length() + 1;
  Serial.println(address);


}

void loop() {
  // put your main code here, to run repeatedly:

}
