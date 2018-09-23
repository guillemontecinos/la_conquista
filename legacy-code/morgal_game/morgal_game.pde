//for moral game scene in la conquista performance
//guillermo montecinos

//syphon connection
import codeanticode.syphon.*;

//syphon elements
PGraphics canvas;
SyphonServer server;

PImage fotosL[] = new PImage[7];
PImage fotosR[] = new PImage[7];
float margenMG = 0.05;
int fotoDisplayMG = 0;

void setup(){
  size(990, 450, P3D);
  //setupMG
  for(int i = 0; i < 7; i++){
    fotosL[i] = loadImage("MG_"+ (i+1) + "_L.jpg");
    fotosR[i] = loadImage("MG_"+ (i+1) + "_R.jpg");
  }
  //image on buffer
  canvas = createGraphics(990, 450, P3D);
  
  //Syphon server initialization
  server = new SyphonServer(this, "Processing Syphon");
}

void draw(){
  //Syphon open drawing
  canvas.beginDraw();
  //drawMG
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
  //end drawMG
  
  //Syphon end drawing
  canvas.endDraw();
  //plotting canvas into screen
  image(canvas,0,0);
  //sending image to madmapper
  server.sendImage(canvas);
}

void keyPressed(){
  if(key == '0'){
    fotoDisplayMG = 0;
  }
  if(key == '1'){
    fotoDisplayMG = 1;
  }
  if(key == '2'){
    fotoDisplayMG = 2;
  }
  if(key == '3'){
    fotoDisplayMG = 3;
  }
  if(key == '4'){
    fotoDisplayMG = 4;
  }
  if(key == '5'){
    fotoDisplayMG = 5;
  }
  if(key == '6'){
    fotoDisplayMG = 6;
  }
  if(key == '7'){
    fotoDisplayMG = 7;
  }
}