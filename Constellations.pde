import processing.net.*;
Server myServer;


int pulseIndex = 0;
int lastCheckedPulse = 0;


/*
  Thomas Sanchez Lengeling.
 http://codigogenerativo.com/
 KinectPV2, Kinect for Windows v2 library for processing
 */

import java.util.ArrayList;
import KinectPV2.KJoint;
import KinectPV2.*;
KinectPV2 kinect;


GraphList graphL;

int VISUALIZE = 0;
int ADD_NODES = 1;
int ADD_EDGES = 2;
int MOVE_NODES = 3;
int KINECT_TIMESHOT = 4;
int SET_LINEZ = 5;
int SET_CONST = 6;
int mode = VISUALIZE;

int stringMode = 0;
long stringChecked = 0;

int timesFile = 0;

BodyPoint [] bodyPoints;

ArrayList<Line> lines;

PVector offset;
PVector nodeOffset;
float sc = 1.0;
int lineIndex = 0;

float elbowLAngle = 0;
float elbowRAngle = 0;
float handRAngle = 0;
float handLAngle = 0;
float kneeLAngle = 0;
float kneeRAngle = 0;
float footLAngle = 0;
float footRAngle = 0;
float spineAngle = 0;
float handRDist = 0;

int triggered = -1;
int triggeredTime = 0;


PImage whale, hand, orchid, moth, owl;

int kinectMode = 0; 
// airbenderX
// airbenderY
// percent of total line
// brightness - up to down, left to right
// painting the lines (open, closed hand)
// radially control light

void setup() {
  fullScreen();
  graphL = new GraphList(100);

  initFFT();

  lines = new ArrayList<Line>();
  graphL.loadGraph();

  //initKinect();
  //initBodyPoints();

  //myServer = new Server(this, 5204);

  //resetConstellationG();
  //resetZIndex();


  whale = loadImage("whale.png");
  hand = loadImage("handeye.png");
  orchid = loadImage("orchid.png");
  moth = loadImage("moth.png");
  owl = loadImage("owl.png");
}


//--------------------------------------------------------------
void draw() {
  background(0);
  updateFFT();

  if (mode == VISUALIZE) {
    cycleModes(3000);
    //drawBody();
    //pulsing(9);
    //drawConstellation();
    //testConstellations();
    //myServer.write(stringMode);
  } else {
    settingFunctions();
  }
}

//--------------------------------------------------------------
void keyPressed() {
  if (key == 's') {
    graphL.saveGraph();
    graphL.printGraph();
  } else if (key == 'r') graphL.loadGraph();
  else if (key == 'a') mode = ADD_NODES;
  else if (key == 'e') mode = ADD_EDGES;
  else if (key == 'm') mode = MOVE_NODES;
  else if (key == 'z') {
    println("set lines");
    mode = SET_LINEZ;
  } else if (key == 'c') {
    mode = SET_CONST;
    println("set constellations");
  } else if (key == 'v') {
    mode = VISUALIZE;
  } else if (key == 'p') {
    graphL.printGraph();
    for (int i = 0; i < bandMax.length; i++) {
      println(bandMax[i]);
    }
  } else if (key == 't') {
    mode = KINECT_TIMESHOT;
    // TODO ?
  } else if (mode == MOVE_NODES) {
    if (graphL.hasCurrentNode()) {
      if (keyCode == UP) graphL.moveCurrentNode(0, -1);
      else if (keyCode == DOWN) graphL.moveCurrentNode(0, 1);
      else if (keyCode == RIGHT) graphL.moveCurrentNode(1, 0);
      else if (keyCode == LEFT) graphL.moveCurrentNode(-1, 0);
    }
  } else if (mode == SET_LINEZ) {
    println(parseInt(key));
    int k = parseInt(key) - 48;
    if (k > 0 && k < 9) {
      lines.get(lineIndex).setZIndex(k);
    }
  } else if (mode == SET_CONST) {
    int k = parseInt(key) - 48;
    if (k > 0 && k < 9) {
      lines.get(lineIndex).setConstellationG(k);
    }
  }
}

//--------------------------------------------------------------
void keyReleased() {
}

//--------------------------------------------------------------
void mousePressed() {
}

//--------------------------------------------------------------
void mouseReleased() {
  if (mode == ADD_NODES) {
    graphL.addNode(mouseX, mouseY);
  } else if (mode == MOVE_NODES) {
    graphL.checkNodeClick(mouseX, mouseY);
  } else if (mode == ADD_EDGES) {
    graphL.checkEdgeClick(mouseX, mouseY);
  } else if (mode == SET_LINEZ || mode == SET_CONST) {
    for (int i = 0; i < lines.size(); i++) {
      if (lines.get(i).mouseOver()) {
        lineIndex = i;
        println("l index " + lineIndex + " " + lines.get(i).id);
        break;
      }
    }
  }
}

//--------------------------------------------------------------
void initKinect() {
  kinect = new KinectPV2(this);

  //Enables depth and Body tracking (mask image)
  kinect.enableDepthMaskImg(true);
  kinect.enableSkeletonDepthMap(true);

  kinect.init();
}

//--------------------------------------------------------------
void updateKinect() {
  //kinect.update();
  //setBody();
}

//--------------------------------------------------------------
void drawKinect() {
  //get the skeletons as an Arraylist of KSkeletons
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();

  //individual joints
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    //if the skeleton is being tracked compute the skleton joints
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      //setBody(joints);
      setBodyAngles(joints);
    }
  }
}

void readKinect() {
}

//void saveKinect() {
//  bonesFile.open("bones" + std::to_string(timesFile) + ".txt", ofFile::WriteOnly);

//  for (int i = 0; i < bones.size(); i++) {
//    //cout << bones[i].firstX << endl;
//    bonesFile << bones[i].firstX << " " << bones[i].firstY << " " << bones[i].secondX << " " << bones[i].secondY << std::endl;
//  }
//  bonesFile.close();
//}

//void audioReceived(float* input, int bufferSize, int nChannels) {
//  beat.audioReceived(input, bufferSize, nChannels);
//}

void drawBody() {
  for (int i = 0; i < bodyPoints.length; i++) {
    bodyPoints[i].display();
  }
}





//draw the body
void setBody(KJoint[] joints) {
  // body
  if (graphL.nodes.size() >= 11) {
    offset.set(joints[KinectPV2.JointType_ShoulderLeft].getX(), joints[KinectPV2.JointType_ShoulderLeft].getY());
    sc = 2;
    nodeOffset.set(graphL.nodes.get(11).getX(), graphL.nodes.get(11).getY());
  }
  bodyPoints[0].set(joints[KinectPV2.JointType_ShoulderLeft], joints[KinectPV2.JointType_ShoulderRight]);
  bodyPoints[1].set(joints[KinectPV2.JointType_ShoulderRight], joints[KinectPV2.JointType_SpineMid]);
  bodyPoints[2].set(joints[KinectPV2.JointType_SpineMid], joints[KinectPV2.JointType_HipRight]);
  bodyPoints[3].set(joints[KinectPV2.JointType_HipRight], joints[KinectPV2.JointType_HipLeft]);
  bodyPoints[4].set(joints[KinectPV2.JointType_HipLeft], joints[KinectPV2.JointType_SpineMid]);
  bodyPoints[5].set( joints[KinectPV2.JointType_SpineMid], joints[KinectPV2.JointType_ShoulderLeft]);
  // left arm
  bodyPoints[6].set(joints[KinectPV2.JointType_ShoulderLeft], joints[ KinectPV2.JointType_ElbowLeft]);
  bodyPoints[7].set( joints[ KinectPV2.JointType_ElbowLeft], joints[KinectPV2.JointType_WristLeft]);
  // right arm
  bodyPoints[8].set(joints[KinectPV2.JointType_ShoulderRight], joints[ KinectPV2.JointType_ElbowRight]);
  bodyPoints[9].set( joints[ KinectPV2.JointType_ElbowRight], joints[KinectPV2.JointType_WristRight]);

  // left leg
  bodyPoints[10].set(joints[KinectPV2.JointType_HipLeft], joints[ KinectPV2.JointType_KneeLeft]);
  bodyPoints[11].set( joints[ KinectPV2.JointType_KneeLeft], joints[KinectPV2.JointType_AnkleLeft]);

  // right leg
  bodyPoints[12].set(joints[KinectPV2.JointType_HipRight], joints[ KinectPV2.JointType_KneeRight]);
  bodyPoints[13].set( joints[ KinectPV2.JointType_KneeRight], joints[KinectPV2.JointType_AnkleRight]);

  //drawJoint(joints, KinectPV2.JointType_Head);
}

void initBodyPoints() {
  offset = new PVector(0, 0);
  nodeOffset = new PVector(0, 0);
  bodyPoints = new BodyPoint[14];
  for (int i = 0; i < bodyPoints.length; i++) {
    bodyPoints[i] = new BodyPoint();
  }
}


void setBodyAngles(KJoint[] joints) {
  elbowLAngle = getJointAngle(joints[KinectPV2.JointType_ElbowLeft], joints[ KinectPV2.JointType_ShoulderLeft]);

  elbowRAngle = getJointAngle(joints[KinectPV2.JointType_ElbowRight], joints[ KinectPV2.JointType_ShoulderRight]);

  handRAngle = getJointAngle(joints[KinectPV2.JointType_ElbowRight], joints[ KinectPV2.JointType_WristRight]);
  handLAngle = getJointAngle(joints[KinectPV2.JointType_ElbowLeft], joints[ KinectPV2.JointType_WristLeft]);
  kneeLAngle = getJointAngle(joints[KinectPV2.JointType_HipLeft], joints[ KinectPV2.JointType_KneeLeft]);
  kneeRAngle = getJointAngle(joints[KinectPV2.JointType_HipRight], joints[ KinectPV2.JointType_KneeRight]);
  footLAngle = getJointAngle(joints[KinectPV2.JointType_KneeLeft], joints[ KinectPV2.JointType_AnkleLeft]);
  footRAngle = getJointAngle(joints[KinectPV2.JointType_KneeRight], joints[ KinectPV2.JointType_AnkleRight]);
  spineAngle = getJointAngle(joints[KinectPV2.JointType_SpineMid], joints[ KinectPV2.JointType_SpineShoulder]);

  handRDist = joints[KinectPV2.JointType_ShoulderRight].getZ() - joints[KinectPV2.JointType_WristRight].getZ();
}

void drawConstellation() {
  // draw skirt
  fill(0, 255, 255);
  stroke(0, 255, 255);
  graphL.drawLine(new int[]{17, 25, 24, 23, 17});

  // draw top
  // lean right
  if (degrees(spineAngle) > 105) {
    graphL.drawLine(new int[]{17, 9, 19, 17});
  } else if (degrees(spineAngle) < 80) {
    graphL.drawLine(new int[]{17, 11, 15, 17});
  } else {
    graphL.drawLine(new int[]{17, 11, 10, 9, 17});
    graphL.drawLine(9, getRElbowNode(9));
    graphL.drawLine(11, getLElbowNode(11));
  }
}

int getRElbowNode(int shoulder) {
  if (shoulder == 9) {
    float deg = degrees(elbowRAngle);
    if (deg < 0) deg += 360;
    if (deg > 300 && deg < 330) return 5;
    else if (deg > 250) return 4;
    else if (deg < 60 && deg > 20) return 19;
    else if (deg > 330 || deg < 20) return 6;
    else return -1;
  }
  return -1;
}

int getLElbowNode(int shoulder) {
  if (shoulder == 11) {
    float deg = degrees(elbowLAngle);
    if (deg < 0) deg += 360;
    if (deg > 300 && deg < 330) return 3;
    else if (deg > 250) return 2;
    else if (deg < 250 && deg > 190) return 1;
    else if (deg > 90) return 15;
    else return -1;
  }
  return -1;
}

void drawSkirt() {
  // 3 nodes
}

float getJointAngle(KJoint j1, KJoint j2) {
  return atan2((j1.getY() - j2.getY()), (j1.getX() - j2.getX()));
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
    lines.get(i).displayBandY(pulseIndex, pulseIndex+bandSize);
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
    stringMode = int(random(0, 11));
    stringChecked = millis();
  }
  stroke(200);
  fill(200);
  strokeWeight(2);
  switch(stringMode) {
  case 0:
    linePercentW();
    break;
  case 1:
    lineEqualizer();
    break;
  case 2:
    rotateAngleCounter(100, 20);
    break;
  case 3:
    rotateAngle(100, 20);
    break;
  case 4:
    pulseLineBack(500);
    break;
  case 5:
    pulseLineRight(90, 80);
    break;
  case 6:
    pulseLineLeft(90, 80);
    break;
  case 7:
    pulseLineUp(90, 80);
    break;
  case 8:
    pulseLineDown(90, 80);
    break;
  case 9:
    cycleConstellation(150);
    break;
  case 10:
    fftConstellations(650);
    break;
  case 11:
    pulsing(9);
    break;
  }
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

void setLines() {
  for (int i = 0; i < lines.size(); i++) {
    strokeWeight(4);
    Line l = lines.get(i);
    if (l.mouseOver()) {
      stroke(255);
      fill(255);
    } else if (i == lineIndex) {
      colorMode(RGB);
      stroke(0, 255, 255);
      fill(0, 255, 255);
    } else {
      colorMode(HSB);
      stroke(map(l.zIndex, 0, 9, 0, 255), 255, 255);
      fill(map(l.zIndex, 0, 9, 0, 255), 255, 255);
    }
    l.display();
  }
}


void setConst() {
  background(50);
  for (int i = 0; i < lines.size(); i++) {
    strokeWeight(4);
    Line l = lines.get(i);
    if (l.mouseOver()) {
      stroke(255);
      fill(255);
    } else if (i == lineIndex) {
      colorMode(RGB);
      stroke(0, 255, 255);
      fill(0, 255, 255);
    } else {
      colorMode(HSB);
      stroke(map(l.constellationG, 0, 9, 0, 255), 255, 255);
      fill(map(l.constellationG, 0, 9, 0, 255), 255, 255);
    }
    l.display();
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

void linesDisplay(int brightness) {
  for (int i = 0; i < lines.size(); i++) {
    stroke(brightness);
    fill(brightness);
    lines.get(i).display();
  }
}

void settingFunctions() {

  if (mode == ADD_EDGES) {
    graphL.display();
    graphL.drawLineToCurrent(mouseX, mouseY);
  } else if (mode == ADD_NODES) {
    graphL.display();
    fill(255, 0, 0);
    ellipse(mouseX, mouseY, 20, 20);
  }  else if (mode == MOVE_NODES) {
    graphL.display();
    fill(0, 255, 0);
    //ellipse(mouseX, mouseY, 20, 20);
  }else if (mode == SET_LINEZ) setLines();
  else if (mode == SET_CONST) setConst();
}