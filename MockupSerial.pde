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
      float tempRPM=8000+(mockupValue*50);
      r += tempRPM+","; //using divisor such as 7 to fit triangle wave on small scale graphs
      sensorValues[0]=tempRPM;
      break;
    case 1: //GEAR
    if(delayIncrementer<10){
      float tempGear = lastEmulatedGearVal;
      r += tempGear+",";
      sensorValues[1]=tempGear;
       delayIncrementer+=1;
    }else{
      float temp = random(6);
      r += temp+",";
      lastEmulatedGearVal=temp;
      delayIncrementer=0;
    }
      break; 
    case 2: //Throttle
    float tempThrottle = 680*cos(mockupValue*(2*3.14)/1000);
      r += tempThrottle+",";
      sensorValues[2]=tempThrottle;
      break;
    case 3://Speed
    float tempSpeed = mockupValue/4;
      r += tempSpeed+",";
      sensorValues[3]=tempSpeed;
      break;
    case 4: // Battery voltage
       sensorValues[4]= 11 + random(-2,2);
      break;
    case 5:
      
      break;
    }
    if (i < 7)
      r += '\r'; // return carriage to simulate a newline, required to terminate csv string
  }
  delay(10);
  return r;
}
