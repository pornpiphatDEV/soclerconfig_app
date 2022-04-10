#include <HardwareSerial.h> // Serial RX2,TX2

#include <ArduinoJson.h>
#include "ClosedCube_HDC1080.h"
#include "EEPROM.h"
#include <BluetoothSerial.h>

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

int address = 0;
String Nivel1 = "";
String Nivel2 = "";
BluetoothSerial SerialBT;

ClosedCube_HDC1080 hdc1080;


const byte sensorPin = 36;
const byte sensorPin_solar = 39;
const byte sensorPin_LEDs = 35;

const int lightSensorPin = 34;
int sensorValue = 0;
int sensorValue_solar = 0;
int sensorValue_LEDs = 0;

String convert_response = "";

String response_sime = "";
bool check_while = true;

String chipID;
float voltageValue = 0.00;  // Edit Value
float voltageValue_solar = 0.00;
float voltageValue_LEDs = 0.00;
float temperature = 0.00;
float humidity = 0.00;
float light = 0.00;

int status_bat_int;
int status_solar_int;
int status_LEDs_int;
int status_temp_int;
int status_humidity_int;
int status_light_int;


String url_api = "/bmscollector/sendDataSolarLight";
String message_data;
int count_error_connect;


uint64_t chipid;
String getChipID() {
  chipid = ESP.getEfuseMac();
  String re_chipID = "";
  char ssid[23];
  uint64_t chipid = ESP.getEfuseMac();
  uint16_t chip = (uint16_t)(chipid >> 32);
  snprintf(ssid, 23, "%04X%08X", chip, (uint32_t)chipid);

  for (int i = 0; i < 12; i++) {
    re_chipID += ssid[i];
  }
  return re_chipID;
}

//***************************Create Sreing to Json***************************
String create_json() {
  String json_data = "";
  String json_data2 = "";

  String token = "868333030869180";  //NB-IoT IMEI.

  StaticJsonDocument<800> doc_battery;
  doc_battery["token"] = token;
  JsonArray array_battery = doc_battery.createNestedArray("batteries");
  JsonObject ob_battery = array_battery.createNestedObject();
  ob_battery["vbatt"] = voltageValue;
  ob_battery["status"] = status_bat_int;
  JsonArray array_solar = doc_battery.createNestedArray("solarpanels");
  JsonObject ob_solar = array_solar.createNestedObject();
  ob_solar["vsolar"] = voltageValue_solar;
  ob_solar["status"] = status_solar_int;
  JsonArray array_leds = doc_battery.createNestedArray("LEDs");
  JsonObject ob_leds = array_leds.createNestedObject();
  ob_leds["vled"] = voltageValue_LEDs;
  ob_leds["status"] = status_LEDs_int;
  JsonObject ob_temp = doc_battery.createNestedObject("temperaturesensor");
  ob_temp["temp"] = temperature;
  ob_temp["status"] = status_temp_int;
  JsonObject ob_light = doc_battery.createNestedObject("lightsensor");
  ob_light["lighton"] = light;
  ob_light["status"] = status_light_int;
  JsonObject ob_humidity = doc_battery.createNestedObject("humiditysensor");
  ob_humidity["valuehumidity"] = humidity;
  ob_humidity["status"] = status_humidity_int;


  serializeJson(doc_battery, json_data2);
  serializeJsonPretty(doc_battery, json_data);
  Serial.println(json_data2);
  //    return json_data;
  return json_data2;
}
//***************************--END-- Create Sreing to Json***************************


//***************************Caheck Status V***************************
double analogReadAdjusted(byte pinNumber) {

  // Specify the adjustment factors.
  const double f1 = 1.7111361460487501e+001;
  const double f2 = 4.2319467860421662e+000;
  const double f3 = -1.9077375643188468e-002;
  const double f4 = 5.4338055402459246e-005;
  const double f5 = -8.7712931081088873e-008;
  const double f6 = 8.7526709101221588e-011;
  const double f7 = -5.6536248553232152e-014;
  const double f8 = 2.4073049082147032e-017;
  const double f9 = -6.7106284580950781e-021;
  const double f10 = 1.1781963823253708e-024;
  const double f11 = -1.1818752813719799e-028;
  const double f12 = 5.1642864552256602e-033;

  // Specify the number of loops for one measurement.
  const int loops = 40;

  // Specify the delay between the loops.
  const int loopDelay = 200;

  // Initialize the used variables.
  int counter = 1;
  int inputValue = 0;
  double totalInputValue = 0;
  double averageInputValue = 0;

  // Loop to get the average of different analog values.
  for (counter = 1; counter <= loops; counter++) {

    // Read the analog value.
    inputValue = analogRead(pinNumber);

    // Add the analog value to the total.
    totalInputValue += inputValue;

    // Wait some time after each loop.
    delay(loopDelay);
  }

  // Calculate the average input value.
  averageInputValue = totalInputValue / loops;

  // Calculate and return the adjusted input value.
  return f1 + f2 * pow(averageInputValue, 1) + f3 * pow(averageInputValue, 2) + f4 * pow(averageInputValue, 3) + f5 * pow(averageInputValue, 4) + f6 * pow(averageInputValue, 5) + f7 * pow(averageInputValue, 6) + f8 * pow(averageInputValue, 7) + f9 * pow(averageInputValue, 8) + f10 * pow(averageInputValue, 9) + f11 * pow(averageInputValue, 10) + f12 * pow(averageInputValue, 11);
}


float calculateVoltage() {
  float adjustedInputValue = analogReadAdjusted(sensorPin);
  float adjustedInputVoltage;
  if (adjustedInputValue < 3200 ) {
    adjustedInputVoltage = 6.27 / 4096 * adjustedInputValue;
  }
  else if (adjustedInputValue >= 3200 && adjustedInputValue < 3300 ) {
    adjustedInputVoltage = 6.36 / 4096 * adjustedInputValue;
  }
  else if (adjustedInputValue >= 3300 && adjustedInputValue < 3450 ) {
    adjustedInputVoltage = 6.45 / 4096 * adjustedInputValue;
  }
  else if (adjustedInputValue >= 3450 && adjustedInputValue < 3600) {
    adjustedInputVoltage = 6.44 / 4096 * adjustedInputValue;
  }
  else if (adjustedInputValue >= 3600 && adjustedInputValue < 3700 ) {
    adjustedInputVoltage = 6.48 / 4096 * adjustedInputValue;
  }
  else  {
    adjustedInputVoltage = 6.55 / 4096 * adjustedInputValue;
  }
  return adjustedInputVoltage;
}

float calculateVoltage_solar() {
  float adjustedInputValue_soalar = analogReadAdjusted(sensorPin_solar);
  float adjustedInputVoltage_soalar;
  if (adjustedInputValue_soalar < 3200 ) {
    adjustedInputVoltage_soalar = 6.27 / 4096 * adjustedInputValue_soalar;
  }
  else if (adjustedInputValue_soalar >= 3200 && adjustedInputValue_soalar < 3300 ) {
    adjustedInputVoltage_soalar = 6.36 / 4096 * adjustedInputValue_soalar;
  }
  else if (adjustedInputValue_soalar >= 3300 && adjustedInputValue_soalar < 3450 ) {
    adjustedInputVoltage_soalar = 6.45 / 4096 * adjustedInputValue_soalar;
  }
  else if (adjustedInputValue_soalar >= 3450 && adjustedInputValue_soalar < 3600) {
    adjustedInputVoltage_soalar = 6.44 / 4096 * adjustedInputValue_soalar;
  }
  else if (adjustedInputValue_soalar >= 3600 && adjustedInputValue_soalar < 3700 ) {
    adjustedInputVoltage_soalar = 6.48 / 4096 * adjustedInputValue_soalar;
  }
  else  {
    adjustedInputVoltage_soalar = 6.55 / 4096 * adjustedInputValue_soalar;
  }
  return adjustedInputVoltage_soalar;
}

float calculateVoltage_LEDs() {
  float adjustedInputValue_LED = analogReadAdjusted(sensorPin_LEDs);
  float adjustedInputVoltage_LED;
  adjustedInputVoltage_LED = 3.1 / 4096 * adjustedInputValue_LED;
//  Serial.print("Value : ");
//  Serial.println(adjustedInputValue_LED);
  return adjustedInputVoltage_LED;
}

void get_Data() {
  chipID = "null";
  voltageValue = 0;
  voltageValue_solar = 0;
  voltageValue_LEDs = 0;
  temperature = 0;
  humidity = 0;
  light = 0;
  Serial.println("--------------------------------------------------------------------------------------------");
  Serial.println("***********************************************");
//  sensorValue = analogRead(sensorPin);
  voltageValue = calculateVoltage();
  //  Serial.print("\t");
  Serial.print(" Voltage Value: ");
  Serial.println(voltageValue);
  Serial.println("***********************************************");
//  sensorValue_solar = analogRead(sensorPin_solar);
  voltageValue_solar = calculateVoltage_solar();
  //  Serial.print("\t");
  Serial.print(" Voltage Value Solar : ");
  Serial.println(voltageValue_solar);
  Serial.println("***********************************************");
//  sensorValue_LEDs = analogRead(sensorPin_LEDs);
  voltageValue_LEDs = calculateVoltage_LEDs();
  //  Serial.print("\t");
  Serial.print(" Voltage Value LEDs : ");
  Serial.println(voltageValue_LEDs);
  Serial.println("***********************************************");
  chipID = getChipID();
  temperature = hdc1080.readTemperature();
  humidity = hdc1080.readHumidity();
  light = analogRead(lightSensorPin);
  Serial.print(" chipID Value: ");
  Serial.print(chipID);
  Serial.print(" temperature Value: ");
  Serial.print(temperature);
  Serial.print(" humidity Value: ");
  Serial.print(humidity);
  Serial.print(" Light Value: ");
  Serial.println(light);
}


void check_status_V(double value_bat, double value_solar, double value_LEDs, double value_temp, double value_humidity, double value_light) {
  // bat max gate
  if (value_bat > 3.2) {
    voltageValue = 3.2;
    status_bat_int = 1;
  }

  if (value_solar <= 1.5) {
    status_bat_int = 0;
    status_solar_int = 0;
    if (value_LEDs <= 1) {
      status_LEDs_int = 1;
    } else {
      status_LEDs_int = 0;
    }
    // bat หมด low gate
    if (value_bat <= 2.5) {
      status_bat_int = 0;
      status_LEDs_int = 0;
    }
  } else {
    status_bat_int = 1;
    status_solar_int = 1;
    status_LEDs_int = 0;
  }

  //temp
  if(value_temp == 0.00){
    status_temp_int = 0;
  }else{
    status_temp_int = 1;
  }

  //humidity
  if(value_humidity == 0.00){
    status_humidity_int = 0;
  }else{
    status_humidity_int = 1;
  }

  //light
  if(value_light == 0.00){
    status_light_int = 0;
  }else{
    status_light_int = 1;
  }
}

void Set_host() {
  String url = "http://www.enames.co.th/";

  ATCMD("AT+CHTTPCREATE=\"" + url + "\"");
  delay(2000);
}

void send_data(String data_send) {
  digitalWrite(2, HIGH);
  ATCMD("AT+CHTTPDISCON=0");
  delay(1000);
  String check_connect = ATCMD("AT+CHTTPCON=0");
  Serial.println(check_connect.length());
  if(count_error_connect == 15){
    removeURL();
    delay(2000);
    ESP.restart();
  }
  if (check_connect.length() == 20) {
    response_sime = ATCMD_response("" + data_send + "");

    Serial.print("Response Sime 1 : ");
    Serial.println(response_sime);
    Serial.println("***************************************************");
    Serial.println(response_sime.length());
    Serial.println("***************************************************");

  }
  if (check_connect.length() != 20) {
    count_error_connect++;
    send_data(data_send);
    delay(1000);
  }
  digitalWrite(2, LOW);
}

void removeURL(){
  ATCMD("AT+CHTTPDESTROY=0");
  delay(1000);
  ATCMD("AT+CHTTPDESTROY=1");
  delay(1000);
  ATCMD("AT+CHTTPDESTROY=2");
  delay(1000);
  ATCMD("AT+CHTTPDESTROY=3");
  delay(1000);
  ATCMD("AT+CHTTPDESTROY=4");
  delay(1000);
}

String subString_response(String rasponse) {
  rasponse.trim();
  int cutResponse = rasponse.indexOf("+CHTTPNMIC");
  rasponse.remove(0, cutResponse);
  int cutResponse2 = rasponse.indexOf("+CHTTPERR");
  rasponse.remove(cutResponse2, rasponse.length() - 1);
  rasponse.trim();
  int cutResponse3 = rasponse.indexOf(",");
  int position_rasponse = rasponse.indexOf(",", cutResponse3 + 1);
  rasponse.remove(0, position_rasponse + 1);
  int cutResponse4 = rasponse.indexOf(",");
  int position_rasponse2 = rasponse.indexOf(",", cutResponse4 + 1);
  rasponse.remove(0, position_rasponse2 + 1);

  String rasponse_return = HEX_TO_STR(rasponse); // Convert String Hex to String
  //  String response_hexToString = ConvertToASCII(rasponse);
  return rasponse_return;
}

//***************************Timer Reset***************************
hw_timer_t * timer = NULL;
void onTimer(){
//    Serial.print("timer ");
//    Serial.println(millis());
  int millis_int = millis();
  if(millis_int > 180000){  // 60000 = 1 minute
     Serial.print("ESP32 Time is overdue Restart!!!!!");
     Serial.print("Reset ESP32!!!!!");
     ESP.restart();
  }
}
// start/stop the timer
void toggleTimer(){
    if(timer){
        timerEnd(timer);
        timer = NULL;
    } else {
        timer = timerBegin(3, 80, 1);//div 80
        timerAttachInterrupt(timer, &onTimer, 1);
        timerAlarmWrite(timer, 1000000, true);//1000ms
        timerAlarmEnable(timer);
    }
}
//***************************--END-- Timer Reset***************************

void callback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param){
  if(event == ESP_SPP_SRV_OPEN_EVT){
    Serial.println("Client Connected");
  }

  if(event == ESP_SPP_CLOSE_EVT ){
    Serial.println("Client disconnected");
    delay(1000);
     ESP.restart();
  }
}

void setup() {
  pinMode(26, OUTPUT);  //pwrkey sim7020e
  pinMode(27, OUTPUT);  //reset sim7020e
  pinMode(2, OUTPUT);  //reset sim7020e
  digitalWrite(2, LOW);
  delay(5000);

  Serial.begin(115200);
  Serial2.begin(9600);     //Port

  SerialBT.begin("a002");
  Serial.println("Bluetooth device is ready to pair");

  Serial.println("\nTesting EEPROM Library\n");
  if (!EEPROM.begin(1000)) {
    Serial.println("Failed to initialise EEPROM");
    Serial.println("Restarting...");
    delay(1000);
    ESP.restart();
  }

  address = 0;
  String tokenconfig = EEPROM.readString(address);  
  Serial.println(tokenconfig);
  Serial.println(tokenconfig.length());
  address += tokenconfig.length() + 1;

  while (tokenconfig.length() == 0) {
      SerialBT.register_callback(callback);
      if (SerialBT.available()) {
        DecodificarSerial(address);
      }
     }
  Serial.println("Register Token OK");
  
  toggleTimer();
  String check_status_at = ATCMD("AT");
  Serial.print("Status SIM7020E :");
  //  check_status_sim7020.remove(0, 5);substring
  String status_AT = check_status_at.substring(5, 7);
  Serial.println(status_AT);
  if (check_status_at.length() == 0) {
    digitalWrite(26, HIGH);
    delay(800);
    ESP.restart();
  }

  String check_status_url = ATCMD("AT+CHTTPCREATE?");
  Serial.print("Status URL 1 :");
  Serial.println(check_status_url.length());
  if (check_status_url.length() == 154) {
    Set_host();
  }
  String check_status_url2 = ATCMD("AT+CHTTPCREATE?");
  Serial.println("Status URL ALL :");
  Serial.println(check_status_url2.length());
  if (check_status_url2.length() == 154) {
    ESP.restart();
  }

  analogReadResolution(12);
  hdc1080.begin(0x40);

  delay(3000);
  count_error_connect = 0;
  Serial.println("Send !!!!!!!!!!!!!!!");
  //      ATCMD("AT+CHTTPPARA=1");
}

void loop() {
  message_data = "";
  get_Data();
  check_status_V(voltageValue, voltageValue_solar, voltageValue_LEDs, temperature, humidity, light);
  String data_json = create_json();
  
  Serial.print("OUT Json :");
  Serial.println(data_json);
  message_data = PAYLOAD(chipID, data_json, url_api);
  Serial.print("OUT PUT:");
  Serial.println(message_data);

  send_data(message_data);
  convert_response = subString_response(response_sime);
  Serial.print("get convert response = ");
  Serial.println(convert_response);
  Serial.print("get convert_response.length = ");
  Serial.println(convert_response.length());
  Serial.println("*-*-*-*-*-*-*-*-*-*-*-*-*Wait 10 minute*-*-*-*-*-*-*-*-*-*-*-*-*");

//      for(int i = 1; i <30;i++){
//        Serial.print("Time second :");
//        Serial.println(i);
//        delay(1000);
//      }

  Serial.println();
  Serial.println();
  delay(1000);
  esp_sleep_enable_timer_wakeup(10 * 60 * 1000 * 1000);
  esp_deep_sleep_start();
}
