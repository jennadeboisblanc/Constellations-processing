// keystone lib
import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface;
PImage moth;

PGraphics o;

int canvasW = 1200;
int canvasH = 800;

Star stars[];

int mode = 0;
int STARS = 1;
int LINES = 2;

void setup() {
  // Keystone will only work with P3D or OPENGL renderers, 
  // since it relies on texture mapping to deform
  fullScreen(1200, 800, P3D);
  
  stars = new Star[150];
  for (int i = 0; i < 150; i++) {
    stars[i] = new Star(int(random(canvasW)), int(random(canvasH)));
  }

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(canvasW, canvasH, 20);
  
  // We need an o buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The o buffer can be P2D or P3D)
  moth = loadImage("moth.png");
  o = createGraphics(canvasW, canvasH, P3D);
}

void draw() {

  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the 
  // surface from your screen. 
  PVector surfaceMouse = surface.getTransformedMouse();

  // Draw the scene, o
  o.beginDraw();
  o.background(0);
  
  // white outline
  drawOutline();
  
  //drawMoths();
  drawLines(-1);
  drawStars();
 
  //moveStars(mouseX - pmouseX, 0);
  moveStars(-3, 0);
  o.endDraw();

  // most likely, you'll want a black background to minimize
  // bleeding around your projection area
  background(0);
 
  // render the scene, transformed using the corner pin surface
  surface.render(o);
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  }
}

void drawOutline() {
  
  o.stroke(255);
  o.noFill();
  o.strokeWeight(4);
  o.rect(2, 2, canvasW - 2, canvasH - 2);
  
}

void drawMoths() {
  for (int i = 0; i < 10; i ++) {
    o.image(moth, (millis()/5)%canvasW*2-i*moth.width*.2, 200, moth.width*.2, moth.height*.2);
  }
}

void drawLines(int dir) {
  for (int i = 0; i < 10; i ++) {
    stroke(255);
    o.line((millis()/5)%canvasW*2-i*moth.width*.2, 0, (millis()/5)%canvasW*2-i*moth.width*.2, canvasH);
  }
}

void drawStars() {
  for (int i = 0; i < stars.length; i++) {
    stars[i].display();
  }
}

void moveStars(int mx, int my) {
   for (int i = 0; i < stars.length; i++) {
    stars[i].move(mx, my);
  }
}