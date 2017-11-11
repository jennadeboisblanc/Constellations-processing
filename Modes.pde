/////////////////////
// VISUAL MODES
int NONE = -1;
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

/////////////////////
// KINECT MODES
int K_AIRBENDER_X = 0;
int K_AIRBENDER_Y = 1;
// airbenderX
// airbenderY
// percent of total line
// brightness - up to down, left to right
// painting the lines (open, closed hand)
// radially control light

/////////////////////
// PANEL MODES
int INTRO = 0;


///////////////////////
// OTHER VARIABLES
int pulseIndex = 0;
int lastCheckedPulse = 0;
Scene[] deltaScenes;

/////////////////////////////////////////////////////////////////////////////////////////////
// SCENES
void initDeltaWaves() {
  deltaScenes = new Scene[15];
  deltaScenes[0] = new Scene(0.0, V_PULSING, NONE, INTRO);
  deltaScenes[1] = new Scene(0.06, V_LINE_EQUALIZER, NONE, INTRO);
  deltaScenes[2] = new Scene(0.13, V_PULSING, NONE, INTRO);
  deltaScenes[3] = new Scene(0.27, V_PULSE_LINE_DOWN, NONE, INTRO);
  deltaScenes[4] = new Scene(0.35, V_PULSING, NONE, INTRO);
  deltaScenes[5] = new Scene(0.49, V_FFT_CONST, NONE, INTRO);
  deltaScenes[6] = new Scene(1.11, V_PULSING, NONE, INTRO);
  deltaScenes[7] = new Scene(1.25, V_ROTATE_ANGLE, NONE, INTRO);
  deltaScenes[8] = new Scene(1.4, V_PULSING, NONE, INTRO);
  deltaScenes[9] = new Scene(1.54, V_ROTATE_ANGLE_COUNT, NONE, INTRO);
  deltaScenes[10] = new Scene(2.16, V_PULSING, NONE, INTRO);
  deltaScenes[11] = new Scene(2.3, V_CYCLE_CONST, NONE, INTRO);
  deltaScenes[12] = new Scene(2.45, V_PULSING, NONE, INTRO);
  deltaScenes[13] = new Scene(3.0, V_PULSE_LINE_BACK, NONE, INTRO);
  deltaScenes[14] = new Scene(3.1, V_PULSING, NONE, INTRO);
}


void checkScene() {
  if (currentScene+1 < deltaScenes.length) {
    int songMinutes = myAudio.position() / 1000 / 60;
    int songSeconds = myAudio.position() / 1000 % 60;
    float songReading = songMinutes + (songSeconds / 100.0);
    println(songReading + " " + currentScene);
    if (deltaScenes[currentScene + 1].hasStarted(songReading)) {
      currentScene++;
      deltaScenes[currentScene].setModes();
    }
  }
}

void playMode() {
  stroke(200);
  fill(200);
  strokeWeight(2);
  if (visualMode == V_LINE_PERCENT) linePercentW();
  else if (visualMode == V_LINE_EQUALIZER) lineEqualizer();
  else if (visualMode == V_ROTATE_ANGLE_COUNT) rotateAngleCounter(100, 20);
  else if (visualMode == V_ROTATE_ANGLE) rotateAngle(100, 20);
  else if (visualMode == V_PULSE_LINE_BACK) pulseLineBack(500);
  else if (visualMode == V_PULSE_LINE_RIGHT) pulseLineRight(90, 80);
  else if (visualMode == V_PULSE_LINE_LEFT)  pulseLineLeft(90, 80);
  else if (visualMode == V_PULSE_LINE_UP) pulseLineUp(90, 80);
  else if (visualMode == V_PULSE_LINE_DOWN) pulseLineDown(90, 80);
  else if (visualMode == V_CYCLE_CONST) cycleConstellation(150);
  else if (visualMode == V_FFT_CONST) fftConstellations(650);
  else if (visualMode == V_PULSING) pulsing(9);
}

////////////////////////////////////////////////////////////////////////////////
void rotateAngle(int rate, int angleGap) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex+= angleGap;
    if (pulseIndex > -70 ) {
      pulseIndex = -280;
    }
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayAngle(pulseIndex, pulseIndex+angleGap);
  }
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
    lines.get(i).displayAngle(pulseIndex, pulseIndex+angleGap);
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
    lines.get(i).displayBandY(pulseIndex, pulseIndex+bandSize);
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
    lines.get(i).displayBandZ(pulseIndex);
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
    lines.get(i).displayConstellation(l);
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
    lines.get(i).displayEqualizer(fourBands);
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

// good
boolean checkMoth(int range) {
  //float deg = map(degrees(handRAngle), -180, 180, 0, 360);
  //println("moth HR: " + ( deg) + " should be 45");
  return (withinRange(degrees(handRAngle), 55, range) && withinRange(degrees(handLAngle), 145, range));
}

// 
boolean checkOrchid(int range) {
  float deg = map(degrees(handRAngle), -180, 180, 0, 360);
  float deg2 = map(degrees(elbowRAngle), -180, 180, 0, 360);
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


void airBenderZ() {
  int band = constrain(int(map(handRDist, 0, 50, 0, 8)), 0, 8);

  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayBandZ(band);
  }
}

void airBenderY() {
  float rhBrightness = 0;
  if (handRAngle > -90 && handRAngle < 90) {
    rhBrightness = map(handRAngle, -90, 90, 0, 255);
  } else if (handRAngle > 90) {
    rhBrightness = map(handRAngle, 90, 180, 255, 255/2.0);
  } else if (handRAngle < -90) {
    rhBrightness = map(handRAngle, -180, -90, 255/2.0, 0);
  }

  linesDisplay(int(rhBrightness));
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