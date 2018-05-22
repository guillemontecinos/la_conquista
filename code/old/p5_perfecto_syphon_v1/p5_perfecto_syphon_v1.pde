//perfecto
//by aaron montoya-moraga and guillermo montecinos
//commisioned by maria jose contreras
//v0.1.0
//august 2017

//import libraries
import ipcapture.*;
import codeanticode.syphon.*;

//Syphon elements
PGraphics canvas;
SyphonServer server;

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

void setup() {

  //size of canvas
  //size(800, 600);
  size(600, 450, P3D);
  canvas = createGraphics(600, 450, P3D);
  //Syphon server initialization
  server = new SyphonServer(this, "Processing Syphon");
  //for hiding the cursor
  noCursor();
  setupDomestik();
}

void draw() {
  canvas.beginDraw();
  
  //reset background
  canvas.background(0);

  displayDomestik();

  canvas.endDraw();
  //plotting canvas into screen
  image(canvas,0,0);
  //sending image to madmapper
  server.sendImage(canvas);
}

void setupDomestik(){
  //change ip address here
  cams[0] = new IPCapture(this, "http://169.254.30.237/live", "", "");
  cams[1] = new IPCapture(this, "http://169.254.30.237/live", "", "");
  cams[2] = new IPCapture(this, "http://169.254.30.237/live", "", "");

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
    canvas.filter(GRAY);
  }
}


void keyPressed() {

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