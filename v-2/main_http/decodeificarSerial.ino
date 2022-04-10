
void DecodificarSerial(int Address) {
  // L1/100 \n
  // L1 es valor
  // 100 es numero

  String Mensaje = SerialBT.readStringUntil('\n');
  Serial.print("Mensaje : ");
  Serial.println(Mensaje);
  
  int PosicionPleca = Mensaje.indexOf('/');
  int PosicionSaltoLinea = Mensaje.length();

  String Dato = Mensaje.substring(0, PosicionPleca);

  String Valor = Mensaje.substring(PosicionPleca + 1, PosicionSaltoLinea);

  if (Dato.equals("L1")) {
    Nivel1 = Valor;
  } else if (Dato.equals("L2")) {
    Nivel2 = Valor;
  }

  Serial.print("D : ");
  Serial.print(Dato);
  Serial.print(" V : ");
  Serial.println(Valor);

   if(Mensaje == "restart"){
        ESP.restart();      
      }
   
   else if (Dato == "L1")
     {   
        Serial.print ("Register Token :");
        Serial.println(Valor);
        Address = 0;
        String sentence = Valor;
        delay(1000);
        EEPROM.writeString(Address, Valor);
        Address += sentence.length() + 1;
        EEPROM.commit();
        
        ESP.restart();
     }  
}
