// Client lib
import processing.net.*; 
Client myClient; 
byte dataBytes[];

// Keystone lib
import deadpixel.keystone.*;
Keystone ks;
CornerPinSurface surface;
PGraphics o;

import java.nio.ByteBuffer;
Star stars[];
Square squares[];
Star symbols[];
PImage symbolImages[];
Star constellations[];
PImage constellationImages[];
String constellationNames[] = {"owl", "moth", "handeye", "whale", "orchid"}; 
ConstellationLine constellationLines[];
boolean alreadyUpdated = false;
Line lines[];
long lastUpdatedSong = 0;
long timeBytesIn = 0;

// Modes
public enum Mode {
  STARS, LINES, STRIPED, PULSING, BACKFORTH, UPDOWN, FFT_LINES, FFT_CIRCLE, CONSTELLATIONS;
  private static Mode[] vals = values();

  Mode next() {
    return vals[(ordinal() + 1)% vals.length];
  }

  Mode previous() {
    if (ordinal() - 1 < 0) return vals[vals.length -1];
    return vals[(ordinal() - 1)];
  }

  Mode getMode(int i) {
    if (i < vals.length) return vals[i];
    return vals[0];
  }
};
Mode mode = Mode.STARS;

void setup() {
  fullScreen(P3D);
  //size(1200, 800, P3D);
  init();
  dataBytes = new byte[10];
}

void checkData() {
  if (myClient.available() > 0) { 
    timeBytesIn = millis();
    int byteCount = myClient.readBytes(dataBytes); 
    if (byteCount > 0 ) {
      if (dataBytes[0] == 47) {
        setMode(dataBytes[1]);
        updateSong();
        //if (!alreadyUpdated) {
        //  updateSong();
        //  alreadyUpdated = true;
        //}
      } else {
        myClient.clear();
      }
    }
  }
}

void setMode(int b) {
  mode = mode.getMode(b);
}

void draw() {  
  o.beginDraw();
  o.background(255,0,0);
  if (clearBackground()) o.background(0);
  o.stroke(255);
  o.fill(255);

  playMode();
  if (trim) drawBlackout();
  else if (outline) drawBlackoutOutline();

  o.endDraw();
  background(0);  
  surface.render(o);

  updateFFT();
  //checkData();
}

void playMode() {
  switch(mode) {
  case LINES:
    o.strokeWeight(2);
    drawStars();
    moveStars(0, 0);
    drawLines();
    moveLines(5, 0);
    break;
  case STARS:
    o.strokeWeight(2);
    drawStars();
    moveStars(-2, 0);
    break;
  case PULSING:
    symbols[2].displaySymbol(2, .5);
    symbols[2].pulseStar();
    break;
  case STRIPED:
    drawStars();
    moveStars(-3, 0);
    drawStripedSquares();
    break;
  case CONSTELLATIONS:
    drawConstellationLines();
    moveConstellationLines(5);
    break;
  case UPDOWN:
    updown();
    break;
  case BACKFORTH:
    backforth();
    break;
  case FFT_LINES:
    fftLines();
    break;
  case FFT_CIRCLE:
    fftCircle();
    break;
  default:
    break;
  }
}

void fftLines() {
  o.stroke(255);
  o.strokeWeight(5);
  for (int i = 0; i < 5; i++) {
    float x2 = map(getBand(i), 0, 130, 0, width);
    float y2 = map(x2, 0, width, startH + smallGap + smallSideH/2, startH + i *50);
    o.line(0, startH + smallGap + smallSideH/2, x2, y2);
  }
}

void fftCircle() {
  int startx = width/2;
  int starty = int(startH + bigSideH/2);
  int c = getBand(0);
  c = int(map(c, 0, 130, 0, 350));
  o.noStroke();
  o.fill(255);
  o.ellipse(startx, starty, c, c);

  //for (int i = 0; i < 5; i++) {
  //  int c = getBand(i);
  //  c = constrain(int(map(c, 0, 130, 0, 50)), 0, 50);
  //  o.fill(255);
  //  o.ellipse(startx, starty, width - i * 100 + c, width - i * 100 + c);

  //}
}

void fftBrightness() {
  int c = getBand(0);
  c = constrain(int(map(c, 0, 130, 0, 255)), 0, 255);
  if (c > 100) {
    o.stroke(c);
    o.fill(c);
  } else {
    o.stroke(0);
    o.fill(0);
  }
  o.rect(0, 0, width, height);
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

  if (keyCode == RIGHT) {
    mode = mode.next();
  } else if (keyCode == LEFT) {
    mode = mode.previous();
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
  //return mode != Mode.SOLITARE;
  return true;
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

void backforth() {
  o.stroke(255);
  o.strokeWeight(5);
  int w = 50;
  o.rect(getKinectZ(), 0, w, height);
}

void updateSong() {

  if (millis() - lastUpdatedSong > 10000) {
    myAudio.pause();
    lastUpdatedSong = millis();
    checkNextSong(dataBytes[5]);
    byte [] durationBytes = new byte[4];
    for (int i = 0; i < 4; i++) {
      durationBytes[i] = dataBytes[i + 6];
    }
    int duration = fromByteArray(durationBytes);

    myAudio.play(int(duration + (millis() - timeBytesIn)));
  }
}

int getBand(int i) {
  //return dataBytes[5+i];
  return bands[i];
}

void drawLines() {
  o.stroke(255);
  o.fill(255);
  o.strokeWeight(10);
  for (int i = 0; i < lines.length; i++) {
    lines[i].display();
  }
}

void moveLines(int dx, int dy) {
  for (int i = 0; i < lines.length; i++) {
    lines[i].move(dx, dy);
  }
}

int fromByteArray(byte[] bytes) {
  return ByteBuffer.wrap(bytes).getInt();
}