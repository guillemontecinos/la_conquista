//la conquista app
//by aaron montoya-moraga and guillermo montecinos
//commisioned by maria jose contreras, trinidad piriz & roxana gomez
//based on daniel shiffman's kinect raw depth data example, & Domestik app devolped by montoya-moraga & guillermo montecinos
//v0.0.3
//may 2018

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
int scene = 0; //0: blackout, 1: domestik, 2: kinect
boolean domestikScene = false;
boolean kinectScene = false;

//kinect audio processing vars
int soundOption = 1;

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
  
  //for hiding the cursor
  noCursor();
}

//draw loop
void draw(){
  //MIDI blinking
  ledBlink();
  //scene control
  sceneControl();
  
  //Syphon open drawing
  canvas.beginDraw();
  canvas.background(0);
  
  if(scene == 1){
    displayDomestik();
  }
  else if(scene == 2){
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
  cams[0] = new IPCapture(this, "http://169.254.48.201/live", "", "");
  cams[1] = new IPCapture(this, "http://169.254.45.242/live", "", "");
  cams[2] = new IPCapture(this, "http://169.254.124.151/live", "", "");

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
//Message controlling functions
//=================================

//Converts boolean control variables into scene int variable
void sceneControl(){
  if(domestikScene == false && kinectScene == false){
    scene = 0;
    println("Blackout scene");
  }
  else if(domestikScene == true && kinectScene == false){
    scene = 1;
  }
  else if(domestikScene == false && kinectScene == true){
    scene = 2;
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
     kinectScene = false;
     println("Domestik scene");
   }
  }
  if (pitch == 82 ) {
   kinectScene = !kinectScene;
   if(kinectScene == true){
     domestikScene = false;
     println("Kinect scene");
   }
  }
}

//MIDI feedback to controller. Makes leds blink
void ledBlink(){
  //Scene control
  if(domestikScene == true){
    myBus.sendNoteOn(1,81,127);
  }
  else{
    myBus.sendNoteOff(1,81,127);
  }
  if(kinectScene == true){
    myBus.sendNoteOn(1,82,127);
  }
  else{
    myBus.sendNoteOff(1,82,127);
  }
  //===========================
  //Camera control led blinking
  //===========================
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