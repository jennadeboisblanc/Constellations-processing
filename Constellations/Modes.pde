/////////////////////
// VISUAL MODES
int V_NONE = -1;
int V_PULSING = 0;
int V_LINE_PERCENT = 1;
int V_LINE_EQUALIZER = 2;
int V_ROTATE_ANGLE_COUNT = 3;
int V_ROTATE_ANGLE = 4;
int V_PULSE_LINE_BACK = 5;
int V_PULSE_LINE_RIGHT = 6;
int V_PULSE_LINE_LEFT = 7;
int V_PULSE_LINE_UP = 8;
int V_PULSE_LINE_DOWN = 9;
int V_CYCLE_CONST = 10;
int V_FFT_CONST = 11;
int V_SHOW_ONE = 12;
int V_SEESAW = 13;
int V_ROTATE_ANGLE_BEATS = 14;
int V_PULSING_ON_LINE = 15;
int V_SNAKE = 16;
int V_SEGMENT_SHIFT = 17;
int V_FADE = 18;
int V_TRANSIT = 19;

/////////////////////
// KINECT MODES
int K_NONE = -1;
int K_AIR_Z = 0;
int K_TRANSIT_X = 1;
int K_AIR_BRIGHT = 2;
int K_AIR_LINE = 3;
int K_SPOTLIGHT = 4;
int K_CONSTELLATION = 5;
int K_PAINT = 6;
int kinectHues[] = { 0, 50, 100, 150, 200, 250 };
/////////////////////
// PANEL MODES

// Modes
public enum PanelMode {
  STARS, LINES, STRIPED, PULSING, BACKFORTH, UPDOWN, FFT_LINES, FFT_CIRCLE, CONSTELLATIONS;
  private static PanelMode[] vals = values();

  PanelMode next() {
    return vals[(ordinal() + 1)% vals.length];
  }

  PanelMode previous() {
    if (ordinal() - 1 < 0) return vals[vals.length -1];
    return vals[(ordinal() - 1)];
  }

  PanelMode getMode(int i) {
    if (i < vals.length) return vals[i];
    return vals[0];
  }

  byte getPanelByte() {
    return byte(ordinal());
  }
};
PanelMode panelMode = PanelMode.STARS;

///////////////////////
// OTHER VARIABLES
int pulseIndex = 0;
int lastCheckedPulse = 0;
Scene[] deltaScenes;
Scene[] cyclesScenes;
Scene[] songScenes;
Scene[] riteScenes;
Scene[] kirasuScenes;
int pointDirection = 4;
int seesawVals[] = {0, 0};
ArrayList<Integer> randomPath;

/////////////////////////////////////////////////////////////////////////////////////////////
// SCENES
void initDeltaWaves() {
  deltaScenes = new Scene[14];

  deltaScenes[0] = new Scene(0.0, V_SHOW_ONE, K_NONE, PanelMode.STARS);                   
  deltaScenes[1] = new Scene(0.07, V_SEESAW, K_CONSTELLATION, PanelMode.STARS);                    
  deltaScenes[2] = new Scene(0.14, V_LINE_EQUALIZER, K_TRANSIT_X, PanelMode.STARS);
  deltaScenes[3] = new Scene(0.29, V_PULSING_ON_LINE, K_AIR_LINE, PanelMode.STARS);  
  deltaScenes[4] = new Scene(0.36, V_PULSE_LINE_LEFT, K_AIR_Z, PanelMode.LINES);    
  deltaScenes[5] = new Scene(0.50, V_ROTATE_ANGLE, K_AIR_BRIGHT, PanelMode.PULSING);
  deltaScenes[6] = new Scene(1.12, V_LINE_PERCENT, K_SPOTLIGHT, PanelMode.FFT_CIRCLE);
  //deltaScenes[7] = new Scene(1.25, V_TRANSIT, K_CONSTELLATION, PanelMode.FFT_LINES);
  deltaScenes[7] = new Scene(1.42, V_PULSING, K_TRANSIT_X, PanelMode.BACKFORTH);
  deltaScenes[8] = new Scene(1.53, V_PULSE_LINE_BACK, K_AIR_LINE, PanelMode.CONSTELLATIONS);
  deltaScenes[9] = new Scene(2.14, V_LINE_PERCENT, K_AIR_Z, PanelMode.STRIPED);
  deltaScenes[10] = new Scene(2.17, V_SHOW_ONE, K_SPOTLIGHT, PanelMode.UPDOWN);
  deltaScenes[11] = new Scene(2.46, V_ROTATE_ANGLE, K_TRANSIT_X, PanelMode.STARS);
  deltaScenes[12] = new Scene(3.01, V_PULSE_LINE_BACK, K_CONSTELLATION, PanelMode.LINES);
  deltaScenes[13] = new Scene(3.13, V_TRANSIT, K_NONE, PanelMode.FFT_LINES);
  // randomPath = graphL.getRandomPath(11, 5);
}

void initSongForM() {
  songScenes = new Scene[13];
  songScenes[0] = new Scene(0, V_PULSING_ON_LINE, K_NONE, PanelMode.LINES);              
  songScenes[1] = new Scene(0.18, V_SEESAW, K_CONSTELLATION, PanelMode.STARS);                    
  songScenes[2] = new Scene(0.34, V_LINE_EQUALIZER, K_TRANSIT_X, PanelMode.STARS);
  songScenes[3] = new Scene(0.50, V_PULSING_ON_LINE, K_AIR_LINE, PanelMode.STARS);  
  songScenes[4] = new Scene(1.14, V_PULSE_LINE_LEFT, K_AIR_Z, PanelMode.LINES);    
  songScenes[5] = new Scene(1.22, V_ROTATE_ANGLE, K_AIR_BRIGHT, PanelMode.PULSING);
  songScenes[6] = new Scene(1.40, V_LINE_PERCENT, K_SPOTLIGHT, PanelMode.FFT_CIRCLE);
  songScenes[7] = new Scene(1.52, V_TRANSIT, K_CONSTELLATION, PanelMode.FFT_LINES);
  songScenes[8] = new Scene(2.10, V_PULSE_LINE_BACK, K_AIR_LINE, PanelMode.CONSTELLATIONS);
  songScenes[9] = new Scene(2.26, V_LINE_PERCENT, K_AIR_Z, PanelMode.STRIPED);
  songScenes[10] = new Scene(2.42, V_SHOW_ONE, K_SPOTLIGHT, PanelMode.UPDOWN);
  songScenes[11] = new Scene(2.58, V_TRANSIT, K_NONE, PanelMode.FFT_LINES);
  songScenes[12] = new Scene(3.01, V_PULSE_LINE_BACK, K_CONSTELLATION, PanelMode.LINES);
}

void initRiteOfSpring() {
  riteScenes = new Scene[12];
  riteScenes[0] = new Scene(0, V_PULSING_ON_LINE, K_NONE, PanelMode.LINES);              
  riteScenes[1] = new Scene(0.08, V_SEESAW, K_CONSTELLATION, PanelMode.STARS);                    
  riteScenes[2] = new Scene(0.24, V_LINE_EQUALIZER, K_TRANSIT_X, PanelMode.STARS);
  riteScenes[3] = new Scene(0.40, V_PULSING_ON_LINE, K_AIR_LINE, PanelMode.STARS);  
  riteScenes[4] = new Scene(0.48, V_PULSE_LINE_LEFT, K_AIR_Z, PanelMode.LINES);    
  riteScenes[5] = new Scene(1.04, V_ROTATE_ANGLE, K_AIR_BRIGHT, PanelMode.PULSING);
  riteScenes[6] = new Scene(1.19, V_LINE_PERCENT, K_SPOTLIGHT, PanelMode.FFT_CIRCLE);
  riteScenes[7] = new Scene(1.35, V_TRANSIT, K_CONSTELLATION, PanelMode.FFT_LINES);
  riteScenes[8] = new Scene(1.51, V_PULSE_LINE_BACK, K_AIR_LINE, PanelMode.CONSTELLATIONS);
  riteScenes[9] = new Scene(2.07, V_LINE_PERCENT, K_AIR_Z, PanelMode.STRIPED);
  riteScenes[10] = new Scene(2.23, V_SHOW_ONE, K_SPOTLIGHT, PanelMode.UPDOWN);
  riteScenes[11] = new Scene(2.38, V_TRANSIT, K_NONE, PanelMode.FFT_LINES);
}


void initCycles() {
  cyclesScenes = new Scene[11];
  cyclesScenes[0] = new Scene(0, V_PULSING_ON_LINE, K_NONE, PanelMode.LINES);              
  cyclesScenes[1] = new Scene(0.24, V_SEESAW, K_CONSTELLATION, PanelMode.STARS);                    
  cyclesScenes[2] = new Scene(0.49, V_LINE_EQUALIZER, K_TRANSIT_X, PanelMode.STARS);
  cyclesScenes[3] = new Scene(1.08, V_PULSING_ON_LINE, K_AIR_LINE, PanelMode.STARS);  
  cyclesScenes[4] = new Scene(1.33, V_PULSE_LINE_LEFT, K_AIR_Z, PanelMode.LINES);    
  cyclesScenes[5] = new Scene(1.47, V_ROTATE_ANGLE, K_AIR_BRIGHT, PanelMode.PULSING);
  cyclesScenes[6] = new Scene(1.55, V_LINE_PERCENT, K_SPOTLIGHT, PanelMode.FFT_CIRCLE);
  deltaScenes[7] = new Scene(2.14, V_TRANSIT, K_CONSTELLATION, PanelMode.FFT_LINES);
  cyclesScenes[8] = new Scene(2.32, V_PULSE_LINE_BACK, K_AIR_LINE, PanelMode.CONSTELLATIONS);
  cyclesScenes[9] = new Scene(2.42, V_LINE_PERCENT, K_AIR_Z, PanelMode.STRIPED);
  cyclesScenes[10] = new Scene(2.49, V_SHOW_ONE, K_SPOTLIGHT, PanelMode.UPDOWN);
}

void initKirasu() {
  kirasuScenes = new Scene[10];
  kirasuScenes[0] = new Scene(0.36, V_SHOW_ONE, K_NONE, PanelMode.UPDOWN);  
  kirasuScenes[1] = new Scene(0.58, V_SEESAW, K_CONSTELLATION, PanelMode.STARS);                    
  kirasuScenes[2] = new Scene(1.22, V_LINE_EQUALIZER, K_TRANSIT_X, PanelMode.STARS);
  kirasuScenes[3] = new Scene(1.35, V_PULSING_ON_LINE, K_AIR_LINE, PanelMode.STARS);  
  kirasuScenes[4] = new Scene(1.58, V_PULSE_LINE_LEFT, K_AIR_Z, PanelMode.LINES);    
  kirasuScenes[5] = new Scene(2.22, V_ROTATE_ANGLE, K_AIR_BRIGHT, PanelMode.PULSING);
  kirasuScenes[6] = new Scene(2.46, V_LINE_PERCENT, K_SPOTLIGHT, PanelMode.FFT_CIRCLE);
  kirasuScenes[7] = new Scene(3.00, V_TRANSIT, K_CONSTELLATION, PanelMode.FFT_LINES);
  kirasuScenes[8] = new Scene(3.22, V_PULSE_LINE_BACK, K_AIR_LINE, PanelMode.CONSTELLATIONS);
  kirasuScenes[9] = new Scene(3.46, V_LINE_PERCENT, K_AIR_Z, PanelMode.STRIPED);
}

/////////////////////////////////////////////////////////////////////////////////////////////

void startScene() {
  currentScene = 0;
  if (currentSong == 0) deltaScenes[0].setModes();
  else if (currentSong == 1) cyclesScenes[0].setModes();
  else if (currentSong == 2) kirasuScenes[0].setModes();
  else if (currentSong == 3) riteScenes[0].setModes();
  else if (currentSong == 4) songScenes[0].setModes();

  //  Cycles
  //Deltawaves
  //Song for m
  //When the moon comes
  //Rite of spring
}

void checkScene() {
  int songMinutes = myAudio.position() / 1000 / 60;
  int songSeconds = myAudio.position() / 1000 % 60;
  float songReading = songMinutes + (songSeconds / 100.0);
  if (currentSong == 0) {
    if (currentScene+1 < deltaScenes.length) {
      if (deltaScenes[currentScene + 1].hasStarted(songReading)) {
        currentScene++;
        deltaScenes[currentScene].setModes();
      }
    }
  } else if (currentSong == 1) {
    if (currentScene+1 < cyclesScenes.length) {
      if (cyclesScenes[currentScene + 1].hasStarted(songReading)) {
        currentScene++;
        cyclesScenes[currentScene].setModes();
      }
    }
  } else if (currentSong == 2) {
    if (currentScene+1 < kirasuScenes.length) {
      if (kirasuScenes[currentScene + 1].hasStarted(songReading)) {
        currentScene++;
        kirasuScenes[currentScene].setModes();
      }
    }
  } else if (currentSong == 3) {
    if (currentScene+1 < riteScenes.length) {
      if (riteScenes[currentScene + 1].hasStarted(songReading)) {
        currentScene++;
        riteScenes[currentScene].setModes();
      }
    }
  } else if (currentSong == 4) {
    if (currentScene+1 < songScenes.length) {
      if (songScenes[currentScene + 1].hasStarted(songReading)) {
        currentScene++;
        songScenes[currentScene].setModes();
      }
    }
  }
}

void playMode() {
  if (visualMode == V_LINE_PERCENT) linePercentW();
  else if (visualMode == V_LINE_EQUALIZER) lineEqualizer();
  else if (visualMode == V_ROTATE_ANGLE_COUNT) rotateAngleCounter(100, 20);
  else if (visualMode == V_ROTATE_ANGLE) rotateAngleBeat(20); //rotateAngle(100, 20);
  else if (visualMode == V_PULSE_LINE_BACK) pulseLineBack(500);
  else if (visualMode == V_PULSE_LINE_RIGHT) pulseLineRight(90, 80);
  else if (visualMode == V_PULSE_LINE_LEFT)  pulseLineLeft(90, 80);
  else if (visualMode == V_PULSE_LINE_UP) pulseLineUp(90, 80);
  else if (visualMode == V_PULSE_LINE_DOWN) pulseLineDown(90, 80);
  else if (visualMode == V_CYCLE_CONST) cycleConstellation(150);
  else if (visualMode == V_FFT_CONST) fftConstellations(650);
  else if (visualMode == V_PULSING) pulsing(9);
  else if (visualMode == V_SHOW_ONE) showOne(100);
  else if (visualMode == V_SEESAW) seesaw();
  else if (visualMode == V_PULSING_ON_LINE) pulseLinesCenter(1);
  else if (visualMode == V_SEGMENT_SHIFT) segmentShift(10);
  else if (visualMode == V_TRANSIT) transit(30);
}

//////////////////////////////////////////////////////////////////
void handLight(float x, float y, int rad, color c) {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).handLight(x, y, rad, c);
  }
}
void transit(int rate) {

  if (millis() - lastCheckedPulse > rate) {
    pulseIndex++;
    if (pulseIndex > 100) pulseIndex = 0;
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displaySegment(pulseIndex / 100.0, .2);
  }
}

void transitHand(float per, color c) {
  stroke(c);
  per = constrain(per, 0, 1.0);
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displaySegment(per, .2);
  }
}


void rainbowRandom() {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayRainbowRandom();
  }
}

void rainbowCycle(int amt) {
  colorMode(HSB, 255);
  pulseIndex+= amt;
  if (pulseIndex > 255) pulseIndex = 0;
  for (int i=0; i< lines.size(); i++) {
    //color c =  color(((i * 256 / lines.size()) + pulseIndex) % 255, 255, 255);
    lines.get(i).displayRainbowCycle(pulseIndex);
  }
  colorMode(RGB, 255);
}

void rainbow() {
  pulseIndex++;
  if (pulseIndex > 255) pulseIndex = 0;
  colorMode(HSB, 255);
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).display(color(pulseIndex, 255, 255));
  }
  colorMode(RGB, 255);
}

void segmentShift(int jump) {
  updateShift(jump);
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displaySegment(pulseIndex / 100.0, .5);
  }
}

void updateShift(int amt) {
  if (oldBeats[0] < currentBeats[0]) {
    oldBeats[0] = currentBeats[0];
    pulseIndex += amt;
    if (pulseIndex > 100) pulseIndex = 50;
  }
  if (oldBeats[1] < currentBeats[1]) {
    oldBeats[1] = currentBeats[1];
    pulseIndex -= amt;
    if (pulseIndex < 0) pulseIndex = 50;
  }
}

void rotateAngle(int rate, int angleGap) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex+= angleGap;
    if (pulseIndex > -70 ) {
      pulseIndex = -280;
    }
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayAngle(pulseIndex, pulseIndex+angleGap, color(255));
  }
}

void rotateAngleBeat(int angleGap) {
  if (oldBeats[9] < currentBeats[9]) {
    oldBeats[9] = currentBeats[9];
    pulseIndex+= angleGap;
    if (pulseIndex > -70 ) {
      pulseIndex = -280;
    }
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayAngle(pulseIndex, pulseIndex+angleGap, color(255));
  }
}

void displayThirdsBeat() {
  if (oldBeats[9] < currentBeats[9] && millis() - lastCheckedPulse > 100) {
    oldBeats[9] = currentBeats[9];
    pulseIndex++;
    lastCheckedPulse = millis();
  }
  int select = pulseIndex %3;
  for (int i = 0; i < lines.size(); i++) {
    if (i %3 == select) lines.get(i).display(color(255));
    else lines.get(i).display(color(0));
  }
}


void displayLines(color c) {
  for (int i = 0; i < lines.size(); i++) {
    stroke(c);
    fill(c);
    lines.get(i).display(c);
  }
}

void displayLines() {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).display();
  }
}

void wipeRight(int amt, int w) {
  stroke(255);
  displayLines();
  fill(0);
  noStroke();
  pulseIndex += amt;
  if (pulseIndex > width) pulseIndex = 0;
  rect(pulseIndex, 0, w, height);
}

void rotateAngleCounter(int rate, int angleGap) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex-= angleGap;
    if (pulseIndex < -280 ) {
      pulseIndex = -70;
    }
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayAngle(pulseIndex, pulseIndex+angleGap, color(255));
  }
}

void displayYPoints(int y, color c) {
  fill(c);
  stroke(c);
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayPointY(y);
  }
}

void displayXPoints(int x, color c) {
  fill(c);
  stroke(c);
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayPointX(x);
  }
}

void displayYPoints(int rate, int bottom, int top) {
  pulseIndex += pointDirection * rate;
  if (pulseIndex > top) {
    pulseIndex = top;
    pointDirection = -1;
  } else if (pulseIndex < bottom) {
    pulseIndex = bottom;
    pointDirection = 1;
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayPointY(pulseIndex);
  }
}

void displayXPoints(int rate, int left, int right) {
  pulseIndex += pointDirection * rate;
  if (pulseIndex > right) {
    pulseIndex = right;
    pointDirection = -1;
  } else if (pulseIndex < left) {
    pulseIndex = left;
    pointDirection = 1;
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayPointX(pulseIndex);
    lines.get(i).displayPointX(pulseIndex+100);
  }
}

void randomLines(int rate) {
  if (millis() - lastCheckedPulse > rate) {
    background(0);
    lastCheckedPulse = millis();
    for (int i = 0; i < 20; i++) {
      line(random(50, width - 100), random(50, height - 100), random(50, width - 100), random(50, height - 100));
    }
  }
}


void pulseLinesCenter(int rate) {
  pulseIndex += pointDirection * rate;
  if (pulseIndex > 100) {
    pulseIndex = 100;
    pointDirection = -1;
  } else if (pulseIndex < 0) {
    pulseIndex = 0;
    pointDirection = 1;
  }
  float per = pulseIndex / 100.0;
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayCenterPulse(per);
  }
}

void seesaw() {
  updateSeesaw();
  for (int i = 0; i < lines.size()/2; i++) {
    lines.get(i).display(color(seesawVals[0]));
  }
  for (int i = lines.size()/2; i < lines.size(); i++) {
    lines.get(i).display(color(seesawVals[1]));
  }
}

void snake() {
  if (millis() - lastCheckedPulse > 1000) {
    pulseIndex++;
    if (pulseIndex > randomPath.size() - 1) randomPath = graphL.getRandomPath(11, 5);
    lastCheckedPulse = millis();
  }



  if ( randomPath.size()-1 > 0) {
    int currentPath = pulseIndex % randomPath.size();
    for (int i = 0; i < currentPath; i++) {
      int p1 = randomPath.get(i);
      int p2 = randomPath.get(i+1);
      for (int j = 0; j < lines.size(); j++) {
        lines.get(j).displayByIDs(p1, p2);
      }
    }
  }
}

void updateSeesaw() {
  seesawVals[0] -= 8;
  seesawVals[1] -= 8;
  if (seesawVals[0] < 0) seesawVals[0] = 0;
  if (seesawVals[1] < 0) seesawVals[1] = 0;

  for (int i = 0; i < 2; i++) {
    if (oldBeats[i] < currentBeats[i]) {
      oldBeats[i] = currentBeats[i];
      seesawVals[i] = 255;
    }
  }
}


void randomSegments(int rate) {
}

void twinkleLines() {
  for (int i = 0; i < lines.size(); i++) {
    fill(255);
    lines.get(i).twinkle(50);
  }
}

void pulseLineRight(int rate, int bandSize) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex+= bandSize;
    if (pulseIndex > width) {
      pulseIndex = -bandSize;
    }
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayBandX(pulseIndex, pulseIndex+bandSize);
  }
}

void pulseLineLeft(int rate, int bandSize) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex-=bandSize;
    if (pulseIndex < -bandSize) {
      pulseIndex = width;
    }
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayBandX(pulseIndex, pulseIndex+bandSize);
  }
}

void pulseLineUp(int rate, int bandSize) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex-=bandSize;
    if (pulseIndex < -bandSize) {
      pulseIndex = height;
    }
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayBandY(pulseIndex, pulseIndex+bandSize, color(255));
  }
}


void pulseLineDown(int rate, int bandSize) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex+=bandSize;
    if (pulseIndex > height) {
      pulseIndex = -bandSize;
    }
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayBandY(pulseIndex, pulseIndex+bandSize, color(255));
  }
}

void pulseLineBack(int rate) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex++;
    if (pulseIndex > 9) {
      pulseIndex = -1;
    }
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayBandZ(pulseIndex, color(255));
  }
}

void cycleConstellation(int rate) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex++;
    if (pulseIndex > 9) {
      pulseIndex = 1;
    }
    lastCheckedPulse = millis();
  }
  showConstellationLine(pulseIndex);
}

void showOne(int rate) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex++;
    lastCheckedPulse = millis();
  }
  if (pulseIndex >= lines.size()) pulseIndex = 0;
  lines.get(pulseIndex).display();
}

void fftConstellations(int rate) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex = int(random(0, 9));
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).fftConstellation(pulseIndex, bands[0]*1.0/bandMax[0]);
  }
}

void pulsing(int rate) {
  pulseIndex += rate;
  pulseIndex %= 510;
  int b = pulseIndex;
  if (pulseIndex > 255) b = int(map(pulseIndex, 255, 510, 255, 0));
  for (int i = 0; i < lines.size(); i++) {
    stroke(b);
    fill(b);
    lines.get(i).display();
  }
}

void showConstellationLine(int l) {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayConstellation(l, color(255));
  }
}

void linePercentW() {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayPercentWid(bands[i%bands.length]*1.0/bandMax[i%bands.length]);
  }
}

void lineEqualizer() {
  int [] fourBands = new int[4];
  fourBands[0] = averageBands(bands[0], bands[1], bands[2]);
  fourBands[1] = averageBands(bands[3], bands[4]);
  fourBands[2] = averageBands(bands[5], bands[6]);
  fourBands[3] = averageBands(bands[7], bands[8], bands[9]);

  for (int i = 0; i < 4; i++) {
    fourBands[i] = int(map(fourBands[i]*1.0/fourBandsMax[i], 0, .5, 0, height));
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayEqualizer(fourBands, color(255));
  }
}

void cycleModes(int rate) {
  if (millis() - stringChecked > rate) {
    visualMode = int(random(1, 11));
    stringChecked = millis();
  }
  playMode();
}



void resetZIndex() {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).setZIndex(0);
  }
}

void resetConstellationG() {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).setConstellationG(0);
  }
}



///////////////////////////////////////////////////////////////////////////////////////////
// KINECT MODES


void playKinectModes() {

  if (kinectMode >= 0) {
    colorMode(HSB, 255);
    color c = color(kinectHues[kinectMode], 255, 255);
    if (kinectMode == K_SPOTLIGHT) drawSpotlightLR(50, c);
    else if (kinectMode == K_CONSTELLATION) {
      checkConstellations();
      if (triggered >= 0) playConstellations(2000);
      else drawOrganicConstellation(11, c);
    } else if (kinectMode == K_AIR_Z) airBenderZ(c);
    else if (kinectMode == K_TRANSIT_X) airBenderX(c);
    else if (kinectMode == K_AIR_BRIGHT) brightnessAirBenderY(c);
    else if (kinectMode == K_AIR_LINE) linesXY(c);
    else if (kinectMode == K_PAINT) paint(50, c);
    colorMode(RGB, 255);
  }
}


void airBenderZ(color c) {
  int band = constrain(int(map(handRDZ, -0.5, 0.5, 6, -1)), 0, 5);
  int start = lines.size() / 6 * band;
  int end = lines.size() / 6 * (band + 1);
  if (end > lines.size()) end = lines.size();
  for (int i = start; i < lines.size(); i++) {
    // assumes lines are sorted closest to farthest
    // we draw closest last (at end of lines)

    // if hand is positive and big when far back
    // so map inverse so that when hand is big, we draw first items in lines array (corresponding to farthest back items)
    if (i >= start && i < end) lines.get(i).display(c);
    //else lines.get(i).display(color(0));
  }
}

void airBenderX(color c) {
  float x = map(handRDX, -2, 2, 0, 1);
  transitHand(x, c);
}

void brightnessAirBenderY(color c) {
  int brightR = constrain(int(map(handRDY, -.6, 0, 0, 255)), 0, 255);
  int brightL = constrain(int(map(handLDY, -.6, 0, 0, 255)), 0, 255);
  int bright = max(brightR, brightL);
  float hue = hue(c);
  colorMode(HSB, 255);
  displayLines(color(hue, 255, bright));
  colorMode(RGB, 255);
}

void linesXY(color c) {
  int r = constrain(int(map(handRDY, -.5, 0.3, height, 0)), 0, height);
  int l = constrain(int(map(handLDX, -.5, .7, 0, width)), 0, width);
  displayYPoints(r, c);
  displayXPoints(l, c);
}

void paint(int r, color c) {
  //pulseIndex += pointDirection * rate;
  //if(pulseIndex > 255) pointDirection = -1;
  //else if (pulseIndex < 50) pointDirection = 1;
  //stroke(pulseIndex);
  drawSpotlightLR(r, c);
}


void checkConstellations() {
  if (triggered < 0) {
    if (checkWhale(20)) {
      triggered = 0;
      triggeredTime = millis();
    } else if (checkHand(20)) {
      triggered = 1;
      triggeredTime = millis();
    } else if (checkOwl(20)) {
      triggered = 2;
      triggeredTime = millis();
    } else if (checkMoth(20)) {
      triggered = 3;
      triggeredTime = millis();
    } else if (checkOrchid(20)) {
      triggered = 4;
      triggeredTime = millis();
    }
  }
}

void playConstellations(int t) {
  if (millis() - triggeredTime > t) {
    triggered = -1;
    triggeredTime = millis();
  } else {
    if (triggered == 0) drawWhale();
    else if (triggered == 1) drawHand();
    else if (triggered == 2) drawOwl();
    else if (triggered == 3) drawMoth();
    else if (triggered == 4) drawOrchid();
  }
}

void drawWhale() {
  rainbowCycle(20);
  println("whale!!");
}

void drawHand() {
  rainbowCycle(20);
  println("hand!!");
}

void drawOwl() {
  rainbowCycle(20);
  println("owl!!");
}

void drawMoth() {
  rainbowCycle(20);
  println("moth!!");
}

void drawOrchid() {
  rainbowCycle(20);
  println("orchid!!");
}

void drawOrganicConstellation(int index, color c) {
  stroke(c);
  graphL.drawOrganicPath3D(index, getHandMapped());
}

void drawSpotlightLR(int rad, color c) {
  int y1 = constrain(int(map(handRDY, -.5, 0.3, height, 0)), 0, height);
  int x1 = constrain(int(map(handRDX, -.5, .7, 0, width)), 0, width);

  int y2 = constrain(int(map(handLDY, -.5, 0.3, height, 0)), 0, height);
  int x2 = constrain(int(map(handLDX, -.5, .7, 0, width)), 0, width);

  handLight(x1, y1, rad, c);
  handLight(x2, y2, rad, c);
}


// good
boolean checkMoth(int range) {
  //float deg = map(degrees(handRAngle), -180, 180, 0, 360);
  //println("moth HR: " + ( deg) + " should be 45");
  return (withinRange(degrees(handRAngle), 55, range) && withinRange(degrees(handLAngle), 145, range));
}

// 
boolean checkOrchid(int range) {
  //float deg = map(degrees(handRAngle), -180, 180, 0, 360);
  //float deg2 = map(degrees(elbowRAngle), -180, 180, 0, 360);
  //print("hand: " + deg + " " + withinRange(degrees(handLAngle), 250, range) + "|||| elbow: " + deg2 + " " + withinRange(degrees(elbowLAngle), 340, range));
  //println("---" + "hand: " + deg + " " + withinRange(degrees(handRAngle), 300, range) + "|||| elbow: " + deg2 + " " + withinRange(degrees(elbowRAngle), 150, range));
  return (withinRange(degrees(handRAngle), 300, range) && withinRange(degrees(elbowRAngle), 180, range)
    && withinRange(degrees(handLAngle), 250, range) && withinRange(degrees(elbowLAngle), 340, range));
}

// good
boolean checkHand(int range) {
  return (withinRange(degrees(handRAngle), 260, range) && withinRange(degrees(handLAngle), 180, range));
}

// good
boolean checkOwl(int range) {
  return (withinRange(degrees(handRAngle), 250, range) && withinRange(degrees(handLAngle), 290, range));
}

// good
boolean checkWhale(int range) {
  //float deg = map(degrees(handRAngle), -180, 180, 0, 360);
  //float deg2 = map(degrees(elbowRAngle), -180, 180, 0, 360);
  //println("handR: " + deg + " " + withinRange(degrees(handRAngle), 90, range) + "|||| handL: " + deg2 + " " + withinRange(degrees(handLAngle), 180, range));

  return (withinRange(degrees(handRAngle), 300, range) && withinRange(degrees(handLAngle), 315, range));
}

boolean withinRange(float actual, float ideal, float range) {
  actual = map(actual, -180, 180, 0, 360);
  if (ideal - range/2 < 0) {
    if (actual < ideal + range/2 || actual > ideal + 360 - range/2) return true;
    return false;
  } else if (ideal + range/2 > 360) {
    if (actual > ideal - range/2 || actual < ideal + range/2 - 360) return true;
    return false;
  } else {
    if (actual > ideal - range/2 && actual < ideal + range/2) return true;
    return false;
  }
}


//void airBenderZ() {
//  int band = constrain(int(map(handRZ, 0, 50, 0, 8)), 0, 8);

//  for (int i = 0; i < lines.size(); i++) {
//    lines.get(i).displayBandZ(band, color(255));
//  }
//}

// old?
void airBenderY() {
  float rhBrightness = 0;
  if (handRAngle > -90 && handRAngle < 90) {
    rhBrightness = map(handRAngle, -90, 90, 0, 255);
  } else if (handRAngle > 90) {
    rhBrightness = map(handRAngle, 90, 180, 255, 255/2.0);
  } else if (handRAngle < -90) {
    rhBrightness = map(handRAngle, -180, -90, 255/2.0, 0);
  }

  displayLines(int(rhBrightness));
}

void testConstellations() {
  if (triggered > -1) {
    if (millis() - triggeredTime > 1000) {
      triggered = -1;
      triggeredTime = millis();
    } else {
      if (triggered == 0) {
        image(owl, 0, 0);
        println("whale!!");
      } else if (triggered == 1) {
        image(hand, 0, 0);
        println("hand!");
      } else if (triggered == 2) {
        image(owl, 0, 0);
        println("owl");
      } else if (triggered == 3) {
        image(moth, 0, 0);
        println ("moth");
      } else if (triggered == 4) {
        image(orchid, 0, 0);
        println("orchid");
      }
    }
  } else {
    if (checkWhale(20)) {
      triggered = 0;
      triggeredTime = millis();
    } else if (checkHand(20)) {
      triggered = 1;
      triggeredTime = millis();
    } else if (checkOwl(20)) {
      triggered = 2;
      triggeredTime = millis();
    } else if (checkMoth(20)) {
      triggered = 3;
      triggeredTime = millis();
    } else if (checkOrchid(20)) {
      triggered = 4;
      triggeredTime = millis();
    }
  }
}