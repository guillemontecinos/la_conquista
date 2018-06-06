//syphon connection
import codeanticode.syphon.*;

//syphon elements
PGraphics canvas;
SyphonServer server;


PFont font;
int y = 0;
String myText[] = {"","",""};
boolean noise = false;
boolean scanner = false;
boolean textDisplay = false;

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
  
  if(noise){
    canvas.loadPixels();
    
    for(int i = 0; i < canvas.width; i++){
      for(int j = 0; j < canvas.height; j++){
        canvas.pixels[i + j * canvas.width] = color(int(random(180)));
      }
    }
    canvas.updatePixels();
  }
  else if(scanner){
    canvas.background(0);
    //canvas.stroke(255);
    canvas.stroke(43,215,49);
    canvas.strokeWeight(3);
    canvas.line(0,y,width,y);
    
    y++;
    
    if(y>height)
    {
      y=0;
    }
  }
  else if(textDisplay){
    canvas.background(0);
    writeText();
  }
  else{
    canvas.background(0);
  }
  
  //Syphon end drawing
  canvas.endDraw();
  //plotting canvas into screen
  image(canvas,0,0);
  //sending image to madmapper
  server.sendImage(canvas);
}

void writeText(){
   canvas.textFont(font);
   canvas.textSize(20);
   canvas.fill(255);
   for(int i = 0; i< myText.length; i++){
     canvas.text(myText[i],i*width/3,10,width/3,height);
     if(random(1)<0.1){
       //binarios
       //myText[i] +=  String.valueOf(int(random(0,2)));
       //texto random
       myText[i] +=  Character.toString((char)int(random(64,127)));
     }
   }
}



void keyPressed(){
  if(key == '1'){
    noise = !noise;
  }
  
  if(key == '2'){
    scanner = !scanner;
    y=0;
  }
  
  if(key == '3'){
    textDisplay = !textDisplay;
    for(int i=0;i<myText.length;i++){
      myText[i]="";
    }
  }
}