// If you want to debug the plotter without using a real serial port

int mockupValue = 0; // real time value subject to volitality
int mockupDirection = 10; //incremental value, used to create linear triangular waveforms
int delayIncrementer = 0;
float lastEmulatedGearVal = 0;


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
    case 0: //Engine RPM
      r += mockupValue/7+","; //using divisor such as 7 to fit triangle wave on small scale graphs
      break;
    case 1: //GEAR
    if(delayIncrementer<10){
      r += lastEmulatedGearVal+",";
       delayIncrementer+=1;
    }else{
      float temp = random(6);
      r += temp+",";
      lastEmulatedGearVal=temp;
      delayIncrementer=0;
    }
      break; 
    case 2: //Throttle
      r += 680*cos(mockupValue*(2*3.14)/1000)+",";
      break;
    case 3://Speed
      r += mockupValue/4+",";
      break;
    case 4:
      r += mockupValue/16+",";
      break;
    case 5:
      r += mockupValue/32+",";
      break;
    }
    if (i < 7)
      r += '\r'; // return carriage to simulate a newline, required to terminate csv string
  }
  delay(10);
  return r;
}
