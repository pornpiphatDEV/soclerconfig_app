#include <Preferences.h>
Preferences preferences;

//String PAYLOAD(String username, String password, String url) {
String PAYLOAD(String chipID, String data_json, String url) {
  String str_data = "";
  str_data += "message=";
  str_data += data_json;
  Serial.println("---------------");
  Serial.println(str_data);
  //Prepare payload format
  String str_header = "4163636570743a202a2f2a0d0a436f6e6e656374696f6e3a204b6565702d416c6976650d0a557365722d4167656e743a2053494d434f4d5f4d4f44554c450d0a";
  
  String str_data_all = "";
  str_data_all += "AT+CHTTPSEND=0,";
  str_data_all += "1,";
  str_data_all += "\""+url+"\"";
  str_data_all += ",";
  str_data_all += str_header;
  str_data_all += ",";
  str_data_all += "\"application/x-www-form-urlencoded\"";
  str_data_all += ",";
  str_data_all += STR_TO_HEX(str_data);
//  Serial.println(str_data_all);
return str_data_all;
}
