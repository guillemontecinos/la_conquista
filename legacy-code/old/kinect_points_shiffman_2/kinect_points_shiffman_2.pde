import org.openkinect.processing.*; //<>//
import ddf.minim.*;

// Kinect Library object
Kinect2 kinect2;
// Minim object
Minim minim;
//Minim input
AudioInput in;

// Angle for rotation
//float a = 0;

int soundOption = 1;

void setup() {
  //size(1200, 900, P3D);
  fullScreen(P3D);
  //Kinect intialization
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  //Minim initialization
  minim = new Minim(this);
  in = minim.getLineIn();
}


void draw() {
  background(0);

  // Translate and rotate
  pushMatrix();
  translate(width/2, height/2, -2250);
  //rotateY(a);

  // We're just going to calculate and draw every 2nd pixel
  int skip = 4;

  // Get the raw depth as array of integers
  int[] depth = kinect2.getRawDepth();

  stroke(255);
  strokeWeight(2);
  beginShape(POINTS);
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
        d = int(depth[offset]+500*in.mix.get(0));
      }
      else if(soundOption == 3){
      //sound responsivity in x-y plane, using randomness from samples 0 & 1 of Line in
        d = depth[offset];
      }
      else if(soundOption == 4){
      //sound responsivity on depth axis
        d = int(depth[offset]+500*in.mix.get(2));
      }
      
      //calculte the x, y, z camera position based on the depth information
      if(d > 800 && d < 2500){
        PVector point = depthToPointCloudPos(x, y, d);
        if(soundOption == 1){
          vertex(point.x, point.y, point.z);
        }
        else if(soundOption == 2){
          vertex(point.x, point.y, point.z);
        }
        else if(soundOption == 3){
          vertex(point.x+int(random(500*in.mix.get(0))), point.y+int(random(500*in.mix.get(1))), point.z);
        }
        else if(soundOption == 4){
          vertex(point.x+int(random(250*in.mix.get(0))), point.y+int(random(250*in.mix.get(1))), point.z);
        }
        // Draw a point
        //Sound responsive oscillation 1
        
        //Sound responsive oscillation 2
        
      } 
    }
  }
  endShape();

  popMatrix();

  fill(255);
  text(frameRate, 50, 50);

  // Rotate
  //a += 0.0015;
}



//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = 1.1*(x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}

//Sound responsivity control
void keyPressed() {
  if (key == '1') {
    soundOption = 1;
  }
  if (key == '2') {
    soundOption = 2;
  }
  if (key == '3') {
    soundOption = 3;
  }
  if (key == '4') {
    soundOption = 4;
  }
}