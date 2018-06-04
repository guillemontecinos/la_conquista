import codeanticode.syphon.*;


SyphonServer server;

//create PGraphics object outside of the canvas
PGraphics buffer;

void setup() { 
  size(400, 400, P3D);
  buffer = createGraphics(400, 400);

  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");
}

void draw() {

  //do stuff on the PGraphics object
  buffer.beginDraw();
  buffer.background(random(255), random(255), random(255));
  buffer.endDraw();

  //place the PGraphics object on the Processing window
  image(buffer, 0, 0);

  //make the PGraphics reflect the change on the Processing window
  buffer.beginDraw();

  //load pixels() array inside of the PGraphics object
  //it can be accessed through dot notation pixels()
  buffer.loadPixels();
  
  //declare variables for RGB
  float thisRed;
  float thisGreen;
  float thisBlue;

  //go through every pixel, retrieve RGB and average it to make it gray
  for (int i = 0; i < buffer.pixels.length; i++) {
    thisRed = red(buffer.pixels[i]);
    thisGreen = green(buffer.pixels[i]);
    thisBlue = blue(buffer.pixels[i]);
    buffer.pixels[i] = color(0.33*(thisRed + thisGreen + thisBlue));
  }
  
  //update pixels array()
  buffer.updatePixels();

  //close the buffer and save it
  buffer.endDraw();
 
  //send the PGraphics object through Syphon
  server.sendImage(buffer);
}
