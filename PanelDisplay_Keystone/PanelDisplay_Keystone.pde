// Client lib
import processing.net.*; 
Client myClient; 
int dataIn; 

// Keystone lib
import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface;
PGraphics o;
PImage moth;

// Blackout variables
float smallSideActualH = 8.0;
float bigSideActualH = 4.0*12;
float sideRatio;
float startH = 400;
float bigSideH;
float smallGap;
float smallSideH;
int canvasW = 1200;
int canvasH = 800;
boolean trim = false;
boolean outline = false;

Star stars[];
Square squares[];
Constellation constellations[];

// Modes
int STARS = 1;
int LINES = 2;
int STRIPED = 3;
int MOTH = 4;
int PULSING = 5;
int BACKFORTH = 6;
int UPDOWN = 7;
int FFTONE = 8;
int SOLITARE = 9;
int CONSTELLATION = 10;
int VORONOI = 11;
int SYMBOLS = 12;

int mode = SYMBOLS;
Star symbols[];
PImage symbolImages[];

void setup() {
  rectMode(CENTER);
  ellipseMode(CENTER);
  imageMode(CENTER);
  fullScreen(P3D);
  canvasH = height;
  canvasW = width;

  stars = new Star[150];
  for (int i = 0; i < stars.length; i++) {
    stars[i] = new Star(int(random(canvasW)), int(random(canvasH)));
  }
  squares = new Square[10];
  for (int i = 0; i < squares.length; i++) {
    squares[i] = new Square(i * 200, int(startH), 900);//int(random(100, 300)));
  }
  constellations = new Constellation[10];
  for (int i = 0; i < constellations.length; i++) {
    constellations[i] = new Constellation(i*200, int(startH));//int(random(100, 300)));
  }

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(canvasW, canvasH, 20);
  o = createGraphics(canvasW, canvasH, P3D);

  moth = loadImage("moth.png");
  sideRatio = canvasW/(22.0*12);
  bigSideH = sideRatio * bigSideActualH;
  smallSideH = sideRatio * smallSideActualH;
  smallGap = (bigSideH -smallSideH) / 2;

  symbols = new Star[6];
  symbolImages = new PImage[6];
  for (int i = 0; i < 6; i++) {
    symbolImages[i] = loadImage("symbols/c" + i + ".png");
    symbols[i] = new Star(i * 200 + 200, int(startH) +170);
  }
}

void draw() {  
  PVector surfaceMouse = surface.getTransformedMouse();
  o.beginDraw();
  o.background(0);

  o.stroke(255);
  o.fill(255);
  if (mode == LINE) {
    drawStars();
    moveStars(-3, 0);
    drawLines(-1);
  } else if (mode == STARS) {
    drawStars();
    moveStars(-3, 0);
  } else if (mode == STRIPED) {
    drawStars();
    moveStars(-3, 0);
    drawStripedSquares();
  } else if (mode == MOTH) {
    drawMoths();
  } else if (mode == VORONOI) {
    drawVoronoi();
  } else if (mode == CONSTELLATION) {
    drawConstellations();
    moveConstellations(5);
  } else if (mode == SYMBOLS) {
    drawSymbols();
    //moveSymbols(5);
  }

  if (trim) {
    drawBlackout();
  } else if (outline) {
    //drawBoxOutline();
    drawBlackoutOutline();
  }
  o.endDraw();
  background(0);  
  surface.render(o);
}

void drawBlackout() {
  o.pushMatrix();
  o.translate(0, 0, 2);
  o.fill(0);
  o.stroke(0);
  // top triangle
  o.triangle(0, startH, width, startH, 0, smallGap+startH);
  // bottom triangle
  o.triangle(0, smallGap + smallSideH + startH, width, bigSideH + startH, 0, bigSideH + startH);
  // bottom rectangl
  o.rect(0, smallGap*2 + smallSideH + startH, width, height - (smallGap*2 + smallSideH));
  // top rectangle
  o.rect(0, 0, width, startH);
  o.popMatrix();
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
  case 'b':
    trim = !trim;
    break;
  case 'o':
    outline = !outline;
    break;
  }
}

void drawBoxOutline() {
  o.stroke(255);
  o.noFill();
  o.strokeWeight(4);
  o.rect(2, 2, canvasW - 2, canvasH - 2);
}

void drawBlackoutOutline() {
  o.pushMatrix();
  translate(0, 0, 2);
  o.noFill();
  o.stroke(255);
  o.strokeWeight(4);
  o.line(2, startH + smallGap - 2, width-2, startH+2);
  o.line(width-2, startH-2, width - 2, bigSideH + 2, 2, startH + smallGap + smallSideH + 2);
  o.line(width-2, startH + bigSideH+2, 2, startH + smallGap + smallSideH -2);
  o.line(2, startH + smallGap + smallSideH + 2, 2, startH + smallGap -2);
  o.popMatrix();
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

void drawStripedSquares() {
  for (int i = 0; i < squares.length; i++) {
    squares[i].displayStriped(20);
  }
}

void drawConstellations() {
  for (int i = 0; i < constellations.length; i++) {
    constellations[i].display();
  }
}

void moveConstellations(int speed) {
  for (int i = 0; i < constellations.length; i++) {
    constellations[i].move(speed);
  }
}

void drawSymbols() {
  for (int i = 0; i < symbols.length; i++) {
    symbols[i].displaySymbol(i, .5);
  }
}

void moveSymbols(int speed) {
  for (int i = 0; i < symbols.length; i++) {
    symbols[i].move(speed, 0);
  }
}