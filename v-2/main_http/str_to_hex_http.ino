String STR_TO_HEX(String t) {
  char data[250];
  int a = t.length();
  String sText = "";
  char tChar[a] = "";
  t.toCharArray(tChar, a + 1);
  for (int i = 0; i < sizeof(tChar); i++) {
    sprintf(data, "%x", tChar[i]);
    sText += data;
  }
  return sText;
}
