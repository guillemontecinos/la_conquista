//la conquista app
//by aaron montoya-moraga and guillermo montecinos
//commisioned by maria jose contreras, trinidad piriz & roxana gomez
//based on daniel shiffman's kinect raw depth data example, & Domestik app devolped by montoya-moraga & guillermo montecinos
//v0.0.6
//jun 2018

//import libraries
//image capture
import ipcapture.*;
//kinect capture
import org.openkinect.processing.*; 
//audio processing
import ddf.minim.*; 
//syphon connection
import codeanticode.syphon.*;
//midi link
import themidibus.*;
import javax.sound.midi.MidiMessage; 

//objects

//syphon elements
PGraphics canvas;
SyphonServer server;

//kinect library object
Kinect2 kinect2;
//minim object
Minim minim;
//minim input
AudioInput audioInput;
//MidiBus
MidiBus myBus; 

//variables

//main control vars
int scene = 0; //0: blackout, 1: domestik, 2:moral game, 3:big data, 4: kinect
boolean domestikScene = false;
boolean moralGameScene = false;
boolean bigDataScene = false;
boolean kinectScene = false;

//Kinect Scene vars
//kinect audio processing vars
int soundOption = 1;

//Moral Game Scene vars
PImage fotosL[] = new PImage[7];
PImage fotosR[] = new PImage[7];
float margenMG = 0.05;
int fotoDisplayMG = 0;

//Big Data Scene vars
PFont font;
int yScan = 0; //y position for vertical scanning
int xScan = 0; //x position for horizontal scanning
String myText[] = {"","",""}; //string array for binary random writting
boolean whiteOutBD = false;
boolean scanVertBD = false;
boolean scanVertFrozBD = false;
boolean scanHorBD = false;
boolean noiseBD = false;
boolean textDisplayBD1 = false;
boolean textDisplayBD2 = false;
boolean textDisplayBD3 = false;

// Domestik Scene vars
//IPCamera image processing vars
//press 1 to toggle cam 1
//press 2 to toggle cam 2
//press 3 to toggle cam 3

//assume three cameras
int numberCameras = 3;

//from library ipcapture
IPCapture[] cams = new IPCapture[numberCameras];

//array for toggling showing each camera
boolean[] showCam = new boolean[numberCameras];

//array for checking if cameras are landscape mode or not
boolean[] isLandscape = new boolean[numberCameras];

//how many cameras show at the same time
int howMany = 0;

//cameras are 640 * 480;
int landscapeWidth = 640;
int landscapeHeight = 480;

int portraitWidth = 480;
int portraitHeight = 640;

//boolean for toggling color or grayscale
boolean isGray = true;

//setup function
void setup(){
  
  //Processing window
  size(990, 450, P3D);
  
  //image on buffer
  canvas = createGraphics(990, 450, P3D);
  
  //Syphon server initialization
  server = new SyphonServer(this, "Processing Syphon");
  
  //Kinect setup
  kinectSetup();
  
  //midi bus setup
  MidiBus.list(); 
  myBus = new MidiBus(this, 1, 2); 
  
  // domestik app setup
  setupDomestik();
  
  //Morgal Game Scene setup
  for(int i = 0; i < 7; i++){
    fotosL[i] = loadImage("MG_"+ (i+1) + "_L.jpg");
    fotosR[i] = loadImage("MG_"+ (i+1) + "_R.jpg");
  }
  
  //for hiding the cursor
  noCursor();
  
  //font loading
  font = loadFont("Courier-48.vlw");
}

//draw loop
void draw(){
  //MIDI blinking
  ledBlink();
  //scene control
  sceneControl();
  
  //Syphon open drawing
  canvas.beginDraw();
  
  if(scene == 0){
    canvas.background(0);
  }
  else if(scene == 1){
    displayDomestik();
  }
  else if(scene == 2){
    drawMG();
  }
  else if(scene == 3){
    displayBD();
  }
  else if(scene == 4){
    kinectDisplay();
  }
  
  //Syphon end drawing
  canvas.endDraw();
  //plotting canvas into screen
  image(canvas,0,0);
  //sending image to madmapper
  server.sendImage(canvas);
}

//===========================
//setup functions
//===========================

void kinectSetup(){
  //constructor function
  kinect2 = new Kinect2(this);
  //ask for depth image
  kinect2.initDepth();
  //start device
  kinect2.initDevice();
}

void minimSetup() {
   minim = new Minim(this);
  audioInput = minim.getLineIn();
}

//===========================
//Kinect processing functions
//===========================

void kinectDisplay(){
  // Translate and rotate
  canvas.pushMatrix();
  canvas.translate(width/2, height/2, -2250);

  // We're just going to calculate and draw every 2nd pixel
  int skip = 4;

  // Get the raw depth as array of integers
  int[] depth = kinect2.getRawDepth();
  canvas.background(0);
  canvas.stroke(255);
  canvas.strokeWeight(2);
  canvas.beginShape(POINTS);
  for (int x = 0; x < kinect2.depthWidth; x+=skip) {
    for (int y = 0; y < kinect2.depthHeight; y+=skip) {
      int offset = x + y * kinect2.depthWidth;
      int d = 0;
      if(soundOption == 1){
      //non sound responsive solution
        d = depth[offset];
      }
      else if(soundOption == 2){
      //sound responsivity on depth axis
        d = int(depth[offset] + 500 * audioInput.mix.get(0));
      }
      else if(soundOption == 3){
      //sound responsivity in x-y plane, using randomness from samples 0 & 1 of Line in
        d = depth[offset];
      }
      else if(soundOption == 4){
      //sound responsivity on depth axis
        d = int(depth[offset] + 500 * audioInput.mix.get(2));
      }
      
      //calculte the x, y, z camera position based on the depth information
      if(d > 800 && d < 2500){
        PVector point = depthToPointCloudPos(x, y, d);
        if(soundOption == 1){
          canvas.vertex(point.x, point.y, point.z);
        }
        else if(soundOption == 2){
          canvas.vertex(point.x, point.y, point.z);
        }
        else if(soundOption == 3){
          canvas.vertex(point.x + int(random(500 * audioInput.mix.get(0))), point.y+int(random(500 * audioInput.mix.get(1))), point.z);
        }
        else if(soundOption == 4){
          canvas.vertex(point.x+int(random(250 * audioInput.mix.get(0))), point.y+int(random(250 * audioInput.mix.get(1))), point.z);
        }
        // Draw a point
        //Sound responsive oscillation 1
        
        //Sound responsive oscillation 2
        
      } 
    }
  }
  canvas.endShape();
  canvas.popMatrix();
}

//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = 1.1*(x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}

//=================================
//Domestik app processing functions
//=================================

void setupDomestik(){
  //change ip address here
  cams[0] = new IPCapture(this, "http://169.254.34.75/live", "", "");
  cams[1] = new IPCapture(this, "http://169.254.37.117/live", "", "");
  cams[2] = new IPCapture(this, "http://169.254.56.79/live", "", "");

  //start cameras
  for (int i = 0; i < cams.length; i++) {
    cams[i].start();
  }

  //initialize every camera to be not showing
  for (int i = 0; i < showCam.length; i++) {
    showCam[i] = false;
  }
}

void displayDomestik(){
  //get images from cameras
  readCameras();
  howManyCameras();
  displayCameras();
}

void readCameras() {
  //start cameras
  for (int i = 0; i < cams.length; i++) {
    if (cams[i].isAvailable()) {
      cams[i].read();
    }
  }
}

//determine how many cameras are being shown
void howManyCameras() {

  //reset
  howMany = 0;

  //iterate through array and count how many cameras are shown
  for (int i = 0; i < showCam.length; i++) {
    if (showCam[i] == true) {
      howMany++;
    }
  }

  //check if cameras are landscape mode or portrait mode
  for (int i = 0; i < cams.length; i++) {
    if (showCam[i] == true) {

      if (cams[i].height == 480) {
        isLandscape[i] = true;
      } else {
        isLandscape[i] = false;
      }
    }
  }
}

void displayCameras() {

  if (howMany == 0) {
    //black background
    canvas.background(0);
  } else if (howMany == 1) {
    for (int i = 0; i < cams.length; i++) {
      //check which camera should be displayed
      if (showCam[i] == true) {
        if (isLandscape[i] == true) 
        {
          //one camera in landscape mode
          canvas.imageMode(CORNER);
          canvas.image(cams[i], 0, 0, width, height);
        } else {
          //one camera in portrait mode
          canvas.imageMode(CENTER);
          float factor = 1.775*height/cams[i].height;
          canvas.image(cams[i], width/2, height/2, factor*cams[i].width, factor*cams[i].height);
        }
      }
    }
  } else if (howMany == 2) {
    int positioned = 0;
    for (int i = 0; i < cams.length; i++) {
      if (showCam[i] == true) {
        if (isLandscape[i] == true) 
        {
          //landscape mode
          canvas.imageMode(CORNER);
          //TODO FIX
          canvas.image(cams[i], positioned*width/2, 0, width/2, height);
          positioned++;
        } else {
          //portrait mode
          canvas.imageMode(CORNER);
          canvas.image(cams[i], positioned*width/2, 0, width/2, height);
          positioned++;
        }
      }
    }
  } else if (howMany == 3) {
    int positioned = 0;
    for (int i = 0; i < cams.length; i++) {
      if (showCam[i] == true) {
        if (isLandscape[i] == true) 
        {
          canvas.imageMode(CORNER);
          //TODO FIX
          canvas.image(cams[i], positioned*width/3, 0, width/3, height);
          positioned++;
        }
        if (isLandscape[i] == false) {
          canvas.imageMode(CORNER);
          canvas.image(cams[i], positioned*width/3, 0, width/3, height);
          positioned++;
        }
      }
    }
  }
  if (isGray == true) {
    //grayscale filter
    //TODO: gray filtering doesn't export to madmapper via syphon. make pixel filtering
    //MAYBE: hice esta funcion maybeGray, quizas funciona? jiji
    canvas.filter(GRAY);
    //maybeGray();
  }
}

void maybeGray() {
  canvas.loadPixels();
  for (int i = 0; i < canvas.width; i++) {
    for (int j = 0; j < canvas.height; j++) {
      color originalColor = pixels[ i + j * canvas.width]; 
      float grayValue = (red(originalColor) + green(originalColor) + blue(originalColor)) / 3;
      pixels[i + j * canvas.width] = color(grayValue);
    }
  }
  canvas.updatePixels();
}

//=================================
//Big Data Scene Functions
//=================================

void displayBD(){
  if(whiteOutBD){
    canvas.background(255);
  }
  else if(noiseBD){
    canvas.loadPixels();  
    for(int i = 0; i < canvas.width; i++){
      for(int j = 0; j < canvas.height; j++){
        canvas.pixels[i + j * canvas.width] = color(int(random(180)));
      }
    }
    canvas.updatePixels();
  }
  else if(scanVertBD){
    canvas.background(255);
    canvas.stroke(0);
    canvas.strokeWeight(3);
    canvas.line(0,yScan,width,yScan);
    
    yScan++;
    
    if(yScan > height)
    {
      yScan = 0;
    }
  }
  else if(scanVertFrozBD){
    canvas.background(255);
    canvas.stroke(0);
    canvas.strokeWeight(3);
    canvas.line(0,yScan,width,yScan);
  }
  else if(scanHorBD){
    canvas.background(255);
    canvas.stroke(0);
    canvas.strokeWeight(3);
    canvas.line(xScan,0,xScan,height);
    
    xScan++;
    
    if(xScan > width){
      xScan = 0;
    }
  }
  else{
    canvas.background(0);
  }
  
  if(textDisplayBD1){
    canvas.background(0);
    //writeTextBD();
    writeTextBD1();
  }
  if(textDisplayBD2){
    writeTextBD2();
  }
  if(textDisplayBD3){
    writeTextBD3();
  }
}

void writeTextBD1(){
   canvas.textFont(font);
   canvas.textSize(20);
   canvas.fill(255);
   if(random(1)<0.1){
     myText[0] +=  String.valueOf(int(random(0,2)));
   }
   canvas.text(myText[0],0,10,width/3,height);
}

void writeTextBD2(){
   canvas.textFont(font);
   canvas.textSize(20);
   canvas.noStroke();
   canvas.fill(255);
   canvas.rect(width/3,0,width/3,height);
   canvas.fill(0);
   if(random(1)<0.1){
     myText[1] +=  String.valueOf(int(random(0,2)));
   }
   canvas.text(myText[1],width/3,10,width/3,height);
}

void writeTextBD3(){
   canvas.textFont(font);
   canvas.textSize(20);
   canvas.fill(255);
   if(random(1)<0.1){
     myText[2] +=  String.valueOf(int(random(0,2)));
   }
   canvas.text(myText[2],2*width/3,10,width/3,height);
}

void resetBD(){
  xScan = 0;
  yScan = 0;
  for(int i=0;i<myText.length;i++){
      myText[i]="";
  }
}
//=================================
//Moral Game Scene Functions
//=================================
void drawMG(){
  canvas.background(0);
  if(fotoDisplayMG != 0){
    //Rects
    canvas.noStroke();
    canvas.fill(245,245,42);
    canvas.rect(0,0,width/3,height);
    canvas.fill(69,57,229);
    canvas.rect(2*width/3,0,width/3,height);
    //Images
    canvas.image(fotosL[fotoDisplayMG-1],margenMG*width/3,margenMG*height,(1-2*margenMG)*width/3,(1-2*margenMG)*height);
    canvas.image(fotosR[fotoDisplayMG-1],2*width/3+(margenMG)*width/3,margenMG*height,(1-2*margenMG)*width/3,(1-2*margenMG)*height);
  }
}

//=================================
//Message controlling functions
//=================================

//Converts boolean control variables into scene int variable
void sceneControl(){
  if(domestikScene == false && moralGameScene == false && bigDataScene == false && kinectScene == false){
    scene = 0;
    println("Blackout scene");
  }
  else if(domestikScene == true && moralGameScene == false && bigDataScene == false && kinectScene == false){
    scene = 1; //demestik
  }
  else if(domestikScene == false && moralGameScene == true && bigDataScene == false && kinectScene == false){
    scene = 2; //moral game
  }
  else if(domestikScene == false && moralGameScene == false && bigDataScene == true && kinectScene == false){
    scene = 3; //big data
  }
  else if(domestikScene == false && moralGameScene == false && bigDataScene == false && kinectScene == true){
    scene = 4; //kinect
  }
}

//Event called when an on note MIDI message is received
void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  //Big Data Scene Control
  if(pitch == 51){
    whiteOutBD = !whiteOutBD;
    if(whiteOutBD == true){
      scanVertBD = false;
      scanVertFrozBD = false;
      scanHorBD = false;
      noiseBD = false;
      textDisplayBD1 = false;
      textDisplayBD2 = false;
      textDisplayBD3 = false;
      resetBD();
    }
  }
  if(pitch == 52){
    scanVertBD = !scanVertBD;
    if(scanVertBD == true){
      whiteOutBD = false;
      scanVertFrozBD = false;
      scanHorBD = false;
      noiseBD = false;
      textDisplayBD1 = false;
      textDisplayBD2 = false;
      textDisplayBD3 = false;
      resetBD();
    }
  }
  if(pitch == 53){
    scanVertFrozBD = !scanVertFrozBD;
    if(scanVertFrozBD == true){
      whiteOutBD = false;
      scanVertBD = false;
      scanHorBD = false;
      noiseBD = false;
      textDisplayBD1 = false;
      textDisplayBD2 = false;
      textDisplayBD3 = false;
      //resetBD();
    }
  }
  if(pitch == 54){
    scanHorBD = !scanHorBD;
    if(scanHorBD == true){
      whiteOutBD = false;
      scanVertBD = false;
      scanVertFrozBD = false;
      noiseBD = false;
      textDisplayBD1 = false;
      textDisplayBD2 = false;
      textDisplayBD3 = false;
      resetBD();
    }
  }
  if(pitch == 55){
    noiseBD = !noiseBD;
    if(noiseBD == true){
      whiteOutBD = false;
      scanVertBD = false;
      scanVertFrozBD = false;
      scanHorBD = false;
      textDisplayBD1 = false;
      textDisplayBD2 = false;
      textDisplayBD3 = false;
    }
  }
  if(pitch == 56){
    textDisplayBD1 = !textDisplayBD1;
    if(textDisplayBD1 == true){
      whiteOutBD = false;
      scanVertBD = false;
      scanVertFrozBD = false;
      scanHorBD = false;
      noiseBD = false;
      myText[0] = "";
    }
  }
  if(pitch == 57){
    textDisplayBD2 = !textDisplayBD2;
    if(textDisplayBD2 == true){
      whiteOutBD = false;
      scanVertBD = false;
      scanVertFrozBD = false;
      scanHorBD = false;
      noiseBD = false;
      myText[1] = "";
    }
  }
  if(pitch == 58){
    textDisplayBD3 = !textDisplayBD3;
    if(textDisplayBD3 == true){
      whiteOutBD = false;
      scanVertBD = false;
      scanVertFrozBD = false;
      scanHorBD = false;
      noiseBD = false;
      myText[2] = "";
    }
  }
  //Moral Game Scene Control
  if (pitch == 61){
    fotoDisplayMG = 1;
  }
  if (pitch == 62){
    fotoDisplayMG = 2;
  }
  if (pitch == 63){
    fotoDisplayMG = 3;
  }
  if (pitch == 64){
    fotoDisplayMG = 4;
  }
  if (pitch == 65){
    //fotoDisplayMG = 5;
    fotoDisplayMG = 6;
  }
  if (pitch == 66){
    //fotoDisplayMG = 6;
    fotoDisplayMG = 7;
  }
  //if (pitch == 67){
  //  fotoDisplayMG = 7;
  //}
  if (pitch == 68){
    fotoDisplayMG = 0;
    myBus.sendNoteOn(1,68,5);
    delay(100);
    myBus.sendNoteOff(1,68,127);
  }
  //Camera Control
  if (pitch == 71){
    showCam[0] = !showCam[0];
  }
  if (pitch == 72){
    showCam[1] = !showCam[1];
  }
  if (pitch == 73){
    showCam[2] = !showCam[2];
  }
  if (pitch == 74){
    myBus.sendNoteOn(1,74,5);
    for (int i =0; i < showCam.length; i++) {
      showCam[i] = false;
    }
    delay(100);
    myBus.sendNoteOff(1,74,127);
  }
  //Scenes Control
  if (pitch == 81 ) {
   domestikScene = !domestikScene;
   if(domestikScene == true){
     moralGameScene = false;
     bigDataScene = false;
     kinectScene = false;
     println("Domestik scene");
   }
  }
  if (pitch == 82 ) {
   moralGameScene = !moralGameScene;
   if(moralGameScene == true){
     domestikScene = false;
     bigDataScene = false;
     kinectScene = false;
     println("Moral Game scene");
     fotoDisplayMG = 0;
   }
   else{
     fotoDisplayMG = 0;
   }
  }
  if (pitch == 83 ) {
   bigDataScene = !bigDataScene;
   if(bigDataScene == true){
     domestikScene = false;
     moralGameScene = false;
     kinectScene = false;
     println("Big Data scene");
     resetBD();
   }
  }
  if (pitch == 84 ) {
   kinectScene = !kinectScene;
   if(kinectScene == true){
     domestikScene = false;
     moralGameScene = false;
     bigDataScene = false;
     println("Kinect");
   }
  }
}

//MIDI feedback to controller. Makes leds blink
void ledBlink(){
  //====================================
  //Big Data Scenes control led blinking
  //====================================
  if(whiteOutBD == true){
    myBus.sendNoteOn(1,51,127);
  }
  else{
    myBus.sendNoteOff(1,51,127);
  }
  if(scanVertBD == true){
    myBus.sendNoteOn(1,52,127);
  }
  else{
    myBus.sendNoteOff(1,52,127);
  }
  if(scanVertFrozBD == true){
    myBus.sendNoteOn(1,53,127);
  }
  else{
    myBus.sendNoteOff(1,53,127);
  }
  if(scanHorBD == true){
    myBus.sendNoteOn(1,54,127);
  }
  else{
    myBus.sendNoteOff(1,54,127);
  }
  if(noiseBD == true){
    myBus.sendNoteOn(1,55,127);
  }
  else{
    myBus.sendNoteOff(1,55,127);
  }
  if(textDisplayBD1 == true){
    myBus.sendNoteOn(1,56,127);
  }
  else{
    myBus.sendNoteOff(1,56,127);
  }
  if(textDisplayBD2 == true){
    myBus.sendNoteOn(1,57,127);
  }
  else{
    myBus.sendNoteOff(1,57,127);
  }
  if(textDisplayBD3 == true){
    myBus.sendNoteOn(1,58,127);
  }
  else{
    myBus.sendNoteOff(1,58,127);
  }
  //====================================
  //Moral Game control led blinking
  //====================================
  if(fotoDisplayMG==1){
    myBus.sendNoteOn(1,61,127);
  }
  else{
    myBus.sendNoteOff(1,61,127);
  }
  if(fotoDisplayMG==2){
    myBus.sendNoteOn(1,62,127);
  }
  else{
    myBus.sendNoteOff(1,62,127);
  }
  if(fotoDisplayMG==3){
    myBus.sendNoteOn(1,63,127);
  }
  else{
    myBus.sendNoteOff(1,63,127);
  }
  if(fotoDisplayMG==4){
    myBus.sendNoteOn(1,64,127);
  }
  else{
    myBus.sendNoteOff(1,64,127);
  }
  /*if(fotoDisplayMG==5){
    myBus.sendNoteOn(1,65,127);
  }
  else{
    myBus.sendNoteOff(1,65,127);
  }*/
  if(fotoDisplayMG==6){
    //myBus.sendNoteOn(1,66,127);
    myBus.sendNoteOn(1,65,127);
  }
  else{
    //myBus.sendNoteOff(1,66,127);
    myBus.sendNoteOff(1,65,127);
  }
  if(fotoDisplayMG==7){
    //myBus.sendNoteOn(1,67,127);
    myBus.sendNoteOn(1,66,127);
  }
  else{
    //myBus.sendNoteOff(1,67,127);
    myBus.sendNoteOff(1,66,127);
  }
  //====================================
  //Domestik Camera control led blinking
  //====================================
  //camera 1 On
  if(showCam[0] == true){
    myBus.sendNoteOn(1,71,127);
  }
  //camera 1 Off
  else{
    myBus.sendNoteOff(1,71,127);
  }
  //camera 2 On
  if(showCam[1] == true){
    myBus.sendNoteOn(1,72,127);
  }
  //camera 2 Off
  else{
    myBus.sendNoteOff(1,72,127);
  }
  //camera 3 On
  if(showCam[2] == true){
    myBus.sendNoteOn(1,73,127);
  }
  //camera 3 Off
  else{
    myBus.sendNoteOff(1,73,127);
  }
  //===========================
  //Scene control led blinking
  //===========================
  if(domestikScene == true){
    myBus.sendNoteOn(1,81,127);
  }
  else{
    myBus.sendNoteOff(1,81,127);
  }
  if(moralGameScene == true){
    myBus.sendNoteOn(1,82,127);
  }
  else{
    myBus.sendNoteOff(1,82,127);
  }
  if(bigDataScene == true){
    myBus.sendNoteOn(1,83,127);
  }
  else{
    myBus.sendNoteOff(1,83,127);
  }
  if(kinectScene == true){
    myBus.sendNoteOn(1,84,127);
  }
  else{
    myBus.sendNoteOff(1,84,127);
  }
}

void keyPressed() {
  //main control domestik
  if(key == 'd' || key == 'D'){
    scene = 1;
    println("Domestik scene");
  }
  //main control kinect
  if(key == 'k' || key == 'K'){
    scene = 2;
    println("Kinect scene");
  }
  //main control blackout
  if(key == 'b' || key == 'B'){
    scene = 0;
    println("Blackout scene");
  }

  //stop cameras
  if (key == 'm') {
    for (int i = 0; i < cams.length; i++) {
      cams[i].stop();
    }
  }

  //start cameras
  if (key == 'n') {
    for (int i = 0; i < cams.length; i++) {
      cams[i].start();
    }
  }

  //toggling the showing of cameras
  //according to numbers of keyboard
  //todo: optimize using the boolean array
  if (key == '1') {
    showCam[0] = !showCam[0];
  }

  if (key == '2') {
    showCam[1] = !showCam[1];
  }

  if (key == '3') {
    showCam[2] = !showCam[2];
  }
  
  //sound responsivity control
  if (key == '6') {
    soundOption = 1;
  }
  if (key == '7') {
    soundOption = 2;
  }
  if (key == '8') {
    soundOption = 3;
  }
  if (key == '9') {
    soundOption = 4;
  }

  //turn off all cameras
  if (key == '0') {
    for (int i =0; i < showCam.length; i++) {
      showCam[i] = false;
    }
  }
  
  //toggle color or grayscale
  if (key == 'c') {
    isGray = !isGray;
  }

  //quit program if enter/return is pressed
  if (keyCode == ENTER || keyCode == RETURN) {
    exit();
  }
}