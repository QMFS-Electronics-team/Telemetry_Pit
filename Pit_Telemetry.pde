import controlP5.*;
import processing.serial.*; //library to access serial comms

//TODO;
//create grid line from setting
//No Live time data
//Check nums not used
//place  logo in assets foldler

//Debugging console messages
boolean printlineEnable=true;//Enable/disable println message to console [FOR DEBUGGING PURPOSES]
boolean eventActionDisplay = false; //Enable/disable event and controller messages
boolean printBuffer = true;//Enable/disable print sensor value buffers

//Serial comms
Serial port;
String Buffer; //holds the csv received 
float[] sensorValues; //Refer to serialSpecification for corrosponding data 
final int baudRate = 57600; //define baud rate of serial communicate
DropdownList commsdroplist; 
String portName;
boolean serialConnected = false;

boolean mockupSerial = false;
ControlP5 cP5;

static final int chartxPos = 870;
static final int chartDefaultHeight = 100;
static final int chartxBase = 110;
// plots
Graph LineGraphRPM = new Graph(chartxPos, chartxBase, 1000, chartDefaultHeight, color (0, 0, 0));
Graph LineGraphGear = new Graph(chartxPos,(chartxBase+(chartDefaultHeight*2)*1), 1000, chartDefaultHeight, color (0,0,0));
Graph LineGraphThrottle = new Graph(chartxPos,(chartxBase+(chartDefaultHeight*2)*2), 1000, chartDefaultHeight, color (0,0,0));
Graph LineGraphSpeed = new Graph(chartxPos,(chartxBase+(chartDefaultHeight*2)*3), 1000, chartDefaultHeight, color (0,0,0));
float[] barChartValues = new float[6];
float[][] lineGraphValues = new float[6][100];
float[] lineGraphSampleNumbers = new float[100];
String[] nums;
final int graphDisplays = 4;

//image logo
PImage imgLogo,imgTopViewCar,gaugeDisplay,gaugeNeedle;

void setup(){
  surface.setTitle("QMFS Data Acquisition Viewer"); // Software Title
  size(1920,1000);//define the size of windows
  centerWindow();
  background(0);//set background to RGB value of 0,0,0
  loadImages(); //load the images into buffer from file
  cP5 = new ControlP5(this);
  
  //drop down menu for coms
  commsdroplist = cP5.addDropdownList("Select COM PORT").setPosition(280, 25);
  // add items to the dropdownlist
  for (int i=0; i<=15; i++) {
    commsdroplist.addItem("COM " + i, i);
  }
  
  //COM connect button
  cP5.addButton("CONNECT",1,400,20,80,40);
  
  //Ping the car, triggers the piezo on the car
  cP5.addButton("PING",1,610,20,80,40);
  //stop recording
  cP5.addButton("STOP",1,700,20,80,40);
  //Enable emulation mode
  cP5.addButton("EMULATION MODE",1,610,70,170,40);
  initDisplayElements();
  
  setChartSettings(); //init chart
   // build x axis values for the line graph
  for (int i=0; i<lineGraphValues.length; i++) {
    for (int k=0; k<lineGraphValues[0].length; k++) {
      lineGraphValues[i][k] = 0;
      if (i==0)
        lineGraphSampleNumbers[k] = k;
    }
  }
  
}


int i = 0; // loop variable
void draw(){
  background(0); // set background to be black color
  drawConsole(); 
  //draw images loaded from buffer
  image(imgLogo,20,20,240,67);
  image(imgTopViewCar,70,140,122,334);
  image(gaugeDisplay,350,200,255,253);
  image(gaugeNeedle,406,310,129*0.7,125*0.7);
  
  /* Read serial and update values */
  //if (mockupSerial || serialPort.available() > 0) {
    String myString = ""; //temporary buffer used when no serial connected
    if (!mockupSerial&&serialConnected) { //<>//
      myString = Buffer;
    }else {
      myString = mockupSerialFunction();
    }
    nums = split(myString, ' ');
  // update line graph
  for (i=0; i<graphDisplays; i++) {
      try {
         if (i<lineGraphValues.length) { //loop to the amount of graph displayed = 4
          for (int k=0; k<lineGraphValues[i].length-1; k++) {
            lineGraphValues[i][k] = lineGraphValues[i][k+1];
          }
          if(serialConnected){
          lineGraphValues[i][lineGraphValues[i].length-1] = sensorValues[i];
          }else{
          lineGraphValues[i][lineGraphValues[i].length-1] = float(nums[i])*1;
          }
        }
      }
      catch (Exception e) {
      }
  }
    
  
  // draw the line graphs
  LineGraphRPM.DrawAxis();
  for (i=0;i<lineGraphValues.length; i++) {
    LineGraphRPM.GraphColor = color(200, 46, 232); //set color of lines

    LineGraphRPM.LineGraph(lineGraphSampleNumbers, lineGraphValues[0]); //view graph values of RPM at array of index 0
  }
  
   
  LineGraphGear.DrawAxis();
  for (i=0;i<lineGraphValues.length; i++) {
    LineGraphGear.GraphColor = color(232, 158, 12);//color of graph lines

    LineGraphGear.LineGraph(lineGraphSampleNumbers, lineGraphValues[1]);
  }
  
  LineGraphThrottle.DrawAxis();
  for (i=0;i<lineGraphValues.length; i++) {
    LineGraphThrottle.GraphColor = color(131, 255, 20);

    LineGraphThrottle.LineGraph(lineGraphSampleNumbers, lineGraphValues[2]);
  }
  
   LineGraphSpeed.DrawAxis();
  for (i=0;i<lineGraphValues.length; i++) {
    LineGraphSpeed.GraphColor = color(255, 0, 0);
 //<>//
    LineGraphSpeed.LineGraph(lineGraphSampleNumbers, lineGraphValues[3]);
  }
  
  if(serialConnected){
  updateConsoleBox();
  updateTyreThermals();
  }
}


void centerWindow(){
  if(frame!=null){
    frame.setLocation(displayWidth/2-width/2,displayHeight/2-height/2);
  }
}

//configure graph settings
void setChartSettings() {
  LineGraphRPM.yLabel="";
  LineGraphRPM.xLabel="";
  LineGraphRPM.xMax=0; 
  LineGraphRPM.xMin=-100;
  LineGraphRPM.Title="Engine RPM";  
  LineGraphRPM.yDiv=4;  
  LineGraphRPM.yMax=16; 
  LineGraphRPM.yMin=0;
  //----------------------
  LineGraphGear.yLabel="";
  LineGraphGear.xLabel="";
  LineGraphGear.xMax=0; 
  LineGraphGear.xMin=-100;
  LineGraphGear.Title="GEAR";  
  LineGraphGear.yDiv=6;  
  LineGraphGear.yMax=6; 
  LineGraphGear.yMin=0;
  //-----------------------
  LineGraphThrottle.yLabel="";
  LineGraphThrottle.xLabel="";
  LineGraphThrottle.xMax=0; 
  LineGraphThrottle.xMin=-100;
  LineGraphThrottle.Title="Throttle";  
  LineGraphThrottle.yDiv=6;  
  LineGraphThrottle.yMax=1020; 
  LineGraphThrottle.yMin=0;
  //------------------------
  LineGraphSpeed.yLabel="";
  LineGraphSpeed.xLabel="";
  LineGraphSpeed.xMax=0; 
  LineGraphSpeed.xMin=-100;
  LineGraphSpeed.Title="Speed(Mp/h)";  
  LineGraphSpeed.yDiv=6;  
  LineGraphSpeed.yMax=120; 
  LineGraphSpeed.yMin=0;
}

void initDisplayElements(){
  //desc: a slider horiz or verti
  //param: name,minimum,maximum,default value(float),x,y,width,height
  cP5.addSlider("TPS",0,100,128,890,875,30,100);
  
 
}

void drawConsole(){ 
 //draw outline rect console
  stroke(255);
  fill(0);
  rect(30,530,720,440);
  //draw top right console
  stroke(255);
  fill(0);
  rect(790,5,1100,50);
}

//function to handle CP5 interrupts
void controlEvent(ControlEvent theEvent) {
  
  String name = theEvent.getController().getName();
  if(name.equals("CONNECT")){
    try{
    port = new Serial(this,portName,baudRate);
    port.bufferUntil('\n');
    serialConnected=true;
    }catch(Exception e){
    if(printlineEnable)
     System.err.println("Error opening Serial port "+ portName); //<>//
    e.printStackTrace();
    }
    if(printlineEnable)
    println("Connected to " + portName + " at Baud rate: " + baudRate);
  }else if(name.equals("PING")){
    port.write('P');
  }else if(name.equals("STOP")){
  
  }else if(name.equals("Select COM PORT")){
    portName = "COM"+int(theEvent.getController().getValue());
  } else if(name.equals("EMULATION MODE")){
    mockupSerial = !mockupSerial;
  } 
  
  if(eventActionDisplay){
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } 
  else if (theEvent.isController()) {
    println("event from controller : "+ int(theEvent.getController().getValue())+" from "+theEvent.getController());
  }
  }
}

//function to handle serial interupts
void serialEvent(Serial port){
  Buffer = port.readString();//read csv into buffer
  sensorValues = float(split(Buffer,','));//Separate csv
  if(printBuffer)
    println(Buffer);
}

void updateTyreThermals(){
textSize(17);
//left side text
text("40C", 60, 210);
text("40C", 60, 425);
//right side text
text("40C", 230, 210);
text("40C", 230, 425);
}
/*------------------------------------------
@Brief: Update values within the console box
*/
void updateConsoleBox(){
try{
textSize(25);
//left side text
text("SENSORS READING", 260, 525);
textSize(18);
//text("RPM: "+nf(float(nums[1]),0,2),270,600);
text("RPM: "+sensorValues[0],270,600);
text("GEAR: "+sensorValues[1],270,620);
text("Water Temp: FIX this",270,660);
text("Air Temp: FIX this",270,680);
text("Oil Pressure: FIX this",270,700);
//--------------------------------------------------
//right side text
text("Battery Voltage: "+sensorValues[4]+" V",700,600);
text("Battery Status: LOW ",700,620);
text("Baud rate: "+baudRate,700,640);
text("Ambient Temperature: 20C",700,660);

}catch(Exception e){
    if(printlineEnable)
     System.err.println("NULL sensor values");
    e.printStackTrace();
    }
}

/*------------------------------------------------------------------------
@Brief:Insert the images from resource folder, based on relative posistion
*/
void loadImages(){
  
  imgLogo = loadImage("assets/qmfsLogo.png"); 
  imgTopViewCar = loadImage("assets/adjustCarColor.png");
  gaugeDisplay = loadImage("assets/Gauge1.png");
  gaugeNeedle = loadImage("assets/needle.png");
}
