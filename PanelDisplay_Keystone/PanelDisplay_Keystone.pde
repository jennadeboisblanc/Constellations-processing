// Client lib
import processing.net.*; 
Client myClient; 
byte dataBytes[];

// Keystone lib
import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface;
PGraphics o;

Star stars[];
Square squares[];
Star symbols[];
PImage symbolImages[];
Star constellations[];
PImage constellationImages[];
String constellationNames[] = {"owl", "moth", "handeye", "whale", "orchid"}; 
ConstellationLine constellationLines[];

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
int WHALE = 13;

int mode = WHALE;

void setup() {
  //fullScreen(P3D);
  size(1300, 800, P3D);
  init();
  dataBytes = new byte[10];
}

void checkData() {
if (myClient.available() > 0) { 
    int byteCount = myClient.readBytes(dataBytes); 
    if (byteCount > 0 ) {
      if (dataBytes[0] == 47) {
        //setMode(dataBytes[1]);
        println("getting data");
      }
      else {
        //myClient.clear();
      }
    } 
  } 
}

void setMode(int b) {
  if (b > 0 && b < 12) {
    mode = b;
  }
}

void draw() {  
  //PVector surfaceMouse = surface.getTransformedMouse();
  o.beginDraw();
  if (clearBackground()) o.background(0);
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
    //drawVoronoi();
  } else if (mode == CONSTELLATION) {
    drawConstellationLines();
    moveConstellationLines(3);
    drawConstellationImages();
    //pulseConstellations();
  } else if (mode == MOTH) {
    drawConstellationImages(1);
    moveConstellationImages(5);
  } else if (mode == SYMBOLS) {
    drawSymbols();
    //moveSymbols(5);
    pulseSymbols();
  } else if (mode == SOLITARE) {
    constellationLines[3].display();
    constellationLines[0].display();
    moveConstellationLines(5);
  } else if (mode == UPDOWN) {
    updown();
  } else if (mode == WHALE) {
    drawStars();
    o.image(constellationImages[3], 500, 150, constellationImages[3].width*.4, constellationImages[3].height*.4);
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
  
  //checkData();
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
    o.image(constellationImages[1], (millis()/5)%canvasW*2-i*constellationImages[1].width*.2, 200, constellationImages[1].width*.2, constellationImages[1].height*.2);
  }
}

void drawLines(int dir) {
  for (int i = 0; i < 10; i ++) {
    stroke(255);
    //o.line((millis()/5)%canvasW*2-i*moth.width*.2, 0, (millis()/5)%canvasW*2-i*moth.width*.2, canvasH);
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

void drawConstellationLines() {
  for (int i = 0; i < constellationLines.length; i++) {
    constellationLines[i].display();
  }
}

void moveConstellationLines(int speed) {
  for (int i = 0; i < constellationLines.length; i++) {
    constellationLines[i].move(speed);
  }
}

void drawSymbols() {
  for (int i = 0; i < symbols.length; i++) {
    symbols[i].displaySymbol(i, .5);
  }
}


void drawConstellationImages(int ind) {
  for (int i = 0; i < constellations.length; i++) {
    constellations[i].displayConstellation(ind, .2);
  }
}

void drawConstellationImages() {
  for (int i = 0; i < constellations.length; i++) {
    constellations[i].displayConstellation(i, .2);
  }
}

void moveConstellationImages(int speed) {
  for (int i = 0; i < constellations.length; i++) {
    constellations[i].move(speed, 0);
  }
}

void pulseConstellations() {
  for (int i = 0; i < constellations.length; i++) {
    constellations[i].pulseStar();
  }
}

void pulseSymbols() {
  for (int i = 0; i < symbols.length; i++) {
    symbols[i].pulseStar();
  }
}

void moveSymbols(int speed) {
  for (int i = 0; i < symbols.length; i++) {
    symbols[i].move(speed, 0);
  }
}

void solitare() {
}

boolean clearBackground() {
  return mode != SOLITARE;
}

float getBandHeight(int ind) {
  if (ind >= 0 && ind < 5) {
    return map(dataBytes[ind + 5], 0, 255, 0, 300);
  }
  return 0;
}

float getKinectX() {
  return map(dataBytes[2], 0, 255, 0, 300);
}

float getKinectY() {
  return map(dataBytes[3], 0, 255, -bigSideH/2, bigSideH/2);
}

float getKinectZ() {
  return map(dataBytes[4], 0, 255, 0, 300);
}

void updown() {
  o.stroke(255);
  o.strokeWeight(5);
  o.line(0, startH + smallGap + smallSideH/2, width, startH + getKinectY());
}