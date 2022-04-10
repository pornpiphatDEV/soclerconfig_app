
String ATCMD(String at) {
  String content = "";
  char character;
  Serial2.println(at);
  delay(1000);
  while (Serial2.available()) {
        character = Serial2.read();
        content += String(character);
  }
  Serial.println(content);
  return content;
}


void Task_delay(void *p){
  delay(10000);
  check_while = false;
  Serial.println("xTaskCreate END !!!!!!!!");
//  Serial.println(content_response);
  vTaskDelete(NULL);
}



String ATCMD_response(String at) {
  String content_response = ""; //get response POST
  char character_response;
  check_while = true;
  TaskHandle_t Task1 = NULL;
  Serial2.println(at);
  delay(1000);
  xTaskCreate(&Task_delay, "Task_delay", 2048, NULL, 10, &Task1);
  
  while (check_while) {
    if(Serial2.available()){
      character_response = Serial2.read();
      content_response += String(character_response);
    }
  }
  Serial.print("response OUT :");
  Serial.println(content_response);
  return content_response;
}
