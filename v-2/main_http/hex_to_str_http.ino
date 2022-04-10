String HEX_TO_STR(String stringInHex){
  String str_hex = stringInHex;
  const char *pos = str_hex.c_str();
  short unsigned int *val = new short unsigned int[str_hex.length() / 2];
  String str;
  for (size_t i = 0; i < str_hex.length()/2; i++)
  {
    sscanf(pos, "%2hx", &val[i]);
    str += (char)val[i];
    pos += 2;
  }
  delete[] val;
//  Serial.println(str); //String
  return str;
}
