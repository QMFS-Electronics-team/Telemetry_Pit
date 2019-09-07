// If you want to debug the plotter without using a real serial port

int mockupValue = 0; // real time value subject to volitality
int mockupDirection = 10; //incremental value, used to create linear triangular waveforms
//csv generation function, we will be using space a delimiters not commas
String mockupSerialFunction() {
  //triangle wave generator
  mockupValue = (mockupValue + mockupDirection);
  if (mockupValue > 100)
    mockupDirection = -10;
  else if (mockupValue <= 0)
    mockupDirection = 10;
   
  String r = ""; //initialising csv string
  for (int i = 0; i<6; i++) {//6 test cases for 6 different graphs, we only have 4 graphs
    //each incremental case indicates increments in csv e.g case 0 corrosponds to position 1 in csv
    switch (i) {
    case 0:
      r += mockupValue/7+" "; //using divisor such as 7 to fit triangle wave on small scale graphs
      break;
    case 1:
      r += random(6)+" ";
      break;
    case 2:
      r += 680*cos(mockupValue*(2*3.14)/1000)+" ";
      break;
    case 3:
      r += mockupValue/4+" ";
      break;
    case 4:
      r += mockupValue/16+" ";
      break;
    case 5:
      r += mockupValue/32+" ";
      break;
    }
    if (i < 7)
      r += '\r'; // return carriage to simulate a newline, required to terminate csv string
  }
  delay(10);
  return r;
}
