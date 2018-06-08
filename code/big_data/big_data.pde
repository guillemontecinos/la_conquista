//syphon connection
import codeanticode.syphon.*;

//syphon elements
PGraphics canvas;
SyphonServer server;


PFont font;
int yScan = 0;
int xScan = 0;
String myText[] = {"","",""};
boolean noiseBD = false;
boolean scanVertBD = false;
boolean scanHorBD = false;
boolean textDisplayBD = false;

void setup(){
  size(990, 450, P3D);
  font = loadFont("Courier-48.vlw");
  
  //image on buffer
  canvas = createGraphics(990, 450, P3D);
  
  //Syphon server initialization
  server = new SyphonServer(this, "Processing Syphon");
}

void draw(){
  //background(0);
  
  //Syphon open drawing
  canvas.beginDraw();
  
  displayBD();
  
  //Syphon end drawing
  canvas.endDraw();
  //plotting canvas into screen
  image(canvas,0,0);
  //sending image to madmapper
  server.sendImage(canvas);
}

void displayBD(){
  if(noiseBD){
    canvas.loadPixels();
    
    for(int i = 0; i < canvas.width; i++){
      for(int j = 0; j < canvas.height; j++){
        canvas.pixels[i + j * canvas.width] = color(int(random(180)));
      }
    }
    canvas.updatePixels();
  }
  else if(scanVertBD){
    canvas.background(0,90);
    canvas.stroke(255);
    canvas.strokeWeight(3);
    canvas.line(0,yScan,width,yScan);
    
    yScan++;
    
    if(yScan > height)
    {
      yScan = 0;
    }
  }
  else if(scanHorBD){
    canvas.background(0,90);
    canvas.stroke(255);
    canvas.strokeWeight(3);
    canvas.line(xScan,0,xScan,height);
    
    xScan++;
    
    if(xScan > width){
      xScan = 0;
    }
  }
  else if(textDisplayBD){
    canvas.background(0);
    writeTextBD();
  }
  else{
    canvas.background(0);
  }
}

void writeTextBD(){
   canvas.textFont(font);
   canvas.textSize(20);
   canvas.fill(255);
   for(int i = 0; i< myText.length; i++){
     canvas.text(myText[i],i*width/3,10,width/3,height);
     if(random(1)<0.07){
       //binarios
       if(myText[0].length() < 540){
         myText[0] +=  String.valueOf(int(random(0,2)));
       }
       else if(myText[1].length() < 540){
         myText[1] +=  String.valueOf(int(random(0,2)));
       }
       else if(myText[2].length() < 540){
         myText[2] +=  String.valueOf(int(random(0,2)));
       }
       //texto random
       //myText[i] +=  Character.toString((char)int(random(64,127)));
     }
   }
}



void keyPressed(){
  if(key == '1'){
    noiseBD = !noiseBD;
  }
  
  if(key == '2'){
    scanVertBD = !scanVertBD;
    yScan = 0;
  }
  
  if(key == '3'){
    scanHorBD = !scanHorBD;
    xScan = 0;
  }
  
  if(key == '4'){
    textDisplayBD = !textDisplayBD;
    for(int i=0;i<myText.length;i++){
      myText[i]="";
    }
  }
}