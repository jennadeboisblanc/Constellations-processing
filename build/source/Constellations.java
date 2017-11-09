import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.ArrayList; 
import KinectPV2.KJoint; 
import KinectPV2.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 
import java.util.*; 
import java.util.LinkedList; 
import java.util.List; 
import java.util.Map; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Constellations extends PApplet {


int pulseIndex = 0;
int lastCheckedPulse = 0;

/*
  Thomas Sanchez Lengeling.
 http://codigogenerativo.com/
 KinectPV2, Kinect for Windows v2 library for processing
 */




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
float sc = 1.0f;
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

int triggered = -1;
int triggeredTime = 0;

public void setup() {
  graphL = new GraphList(100);
  

  initFFT();


  lines = new ArrayList<Line>();
  graphL.loadGraph();

  initKinect();
  initBodyPoints();

  //resetConstellationG();
  //resetZIndex();
}


//--------------------------------------------------------------
public void draw() {
  background(0);
  updateFFT();
  //drawFFT();
  //graphL.display();
  drawKinect();

  fill(0, 0, 255);
  stroke(0, 0, 255);
  //graphL.display();

  colorMode(RGB);
  stroke(255);
  fill(255);

  if (mode == ADD_EDGES) {
    graphL.display();
    graphL.drawLineToCurrent(mouseX, mouseY);
  }
  else if (mode == ADD_NODES) {
    graphL.display();
    fill(255, 0, 0);
    ellipse(mouseX, mouseY, 20, 20);
  }
  else if (mode == VISUALIZE) {
    //cycleModes(3000);
    //pulsing(3);
    testConstellations();
  }
  else if (mode == SET_LINEZ) setLines();
  else if (mode == SET_CONST) setConst();

  //drawBody();

  //drawConstellation();

  if (triggered >  -1) {

  }
  fill(255);
  text(frameRate, 100, 100);
}

//--------------------------------------------------------------
public void keyPressed() {
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
public void keyReleased() {
}

//--------------------------------------------------------------
public void mousePressed() {
}

//--------------------------------------------------------------
public void mouseReleased() {
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
public void initKinect() {
  kinect = new KinectPV2(this);

  //Enables depth and Body tracking (mask image)
  kinect.enableDepthMaskImg(true);
  kinect.enableSkeletonDepthMap(true);

  kinect.init();
}

//--------------------------------------------------------------
public void updateKinect() {
  //kinect.update();
  //setBody();
}

//--------------------------------------------------------------
public void drawKinect() {
  //get the skeletons as an Arraylist of KSkeletons
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();

  //individual joints
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    //if the skeleton is being tracked compute the skleton joints
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      int col  = skeleton.getIndexColor();
      //setBody(joints);
      setBodyAngles(joints);
    }
  }
}

public void readKinect() {
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

public void drawBody() {
  for (int i = 0; i < bodyPoints.length; i++) {
    bodyPoints[i].display();
  }
}





//draw the body
public void setBody(KJoint[] joints) {
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

public void initBodyPoints() {
  offset = new PVector(0, 0);
  nodeOffset = new PVector(0, 0);
  bodyPoints = new BodyPoint[14];
  for (int i = 0; i < bodyPoints.length; i++) {
    bodyPoints[i] = new BodyPoint();
  }
}


public void setBodyAngles(KJoint[] joints) {
  elbowLAngle = getJointAngle(joints[KinectPV2.JointType_ElbowLeft], joints[ KinectPV2.JointType_ShoulderLeft]);

  elbowRAngle = getJointAngle(joints[KinectPV2.JointType_ElbowRight], joints[ KinectPV2.JointType_ShoulderRight]);

  handRAngle = getJointAngle(joints[KinectPV2.JointType_ElbowRight], joints[ KinectPV2.JointType_WristRight]);
  handLAngle = getJointAngle(joints[KinectPV2.JointType_ElbowLeft], joints[ KinectPV2.JointType_WristLeft]);
  kneeLAngle = getJointAngle(joints[KinectPV2.JointType_HipLeft], joints[ KinectPV2.JointType_KneeLeft]);
  kneeRAngle = getJointAngle(joints[KinectPV2.JointType_HipRight], joints[ KinectPV2.JointType_KneeRight]);
  footLAngle = getJointAngle(joints[KinectPV2.JointType_KneeLeft], joints[ KinectPV2.JointType_AnkleLeft]);
  footRAngle = getJointAngle(joints[KinectPV2.JointType_KneeRight], joints[ KinectPV2.JointType_AnkleRight]);
  spineAngle = getJointAngle(joints[KinectPV2.JointType_SpineMid], joints[ KinectPV2.JointType_SpineShoulder]);
}

public void drawConstellation() {
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

public int getRElbowNode(int shoulder) {
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

public int getLElbowNode(int shoulder) {
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

public void drawSkirt() {
  // 3 nodes
}

public float getJointAngle(KJoint j1, KJoint j2) {
  return atan2((j1.getY() - j2.getY()), (j1.getX() - j2.getX()));
}

public void pulseLineRight(int rate, int bandSize) {
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

public void pulseLineLeft(int rate, int bandSize) {
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

public void pulseLineUp(int rate, int bandSize) {
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

public void rotateAngle(int rate, int angleGap) {
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

public void rotateAngleCounter(int rate, int angleGap) {
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

public void pulseLineDown(int rate, int bandSize) {
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

public void pulseLineBack(int rate) {
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

public void cycleConstellation(int rate) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex++;
    if (pulseIndex > 9) {
      pulseIndex = 1;
    }
    lastCheckedPulse = millis();
  }
  showConstellationLine(pulseIndex);
}

public void fftConstellations(int rate) {
  if (millis() - lastCheckedPulse > rate) {
    pulseIndex = PApplet.parseInt(random(0, 9));
    lastCheckedPulse = millis();
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).fftConstellation(pulseIndex, bands[0]*1.0f/bandMax[0]);
  }
}

public void pulsing(int rate) {
  pulseIndex += rate;
  pulseIndex %= 510;
  int b = pulseIndex;
  if (pulseIndex > 255) b = PApplet.parseInt(map(pulseIndex, 255, 510, 255, 0));
  for (int i = 0; i < lines.size(); i++) {
    stroke(b);
    fill(b);
    lines.get(i).display();
  }

}

public void showConstellationLine(int l) {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayConstellation(l);
  }
}

public void linePercentW() {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayPercentWid(bands[i%bands.length]*1.0f/bandMax[i%bands.length]);
  }
}

public void lineEqualizer() {
  int [] fourBands = new int[4];
  fourBands[0] = averageBands(bands[0], bands[1], bands[2]);
  fourBands[1] = averageBands(bands[3], bands[4]);
  fourBands[2] = averageBands(bands[5], bands[6]);
  fourBands[3] = averageBands(bands[7], bands[8], bands[9]);

  for (int i = 0; i < 4; i++) {
    fourBands[i] = PApplet.parseInt(map(fourBands[i]*1.0f/fourBandsMax[i], 0, .5f, 0, height));
  }
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).displayEqualizer(fourBands);
  }
}

public void cycleModes(int rate) {
   if (millis() - stringChecked > rate) {
    stringMode = PApplet.parseInt(random(0, 11));
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
  }
}

public void resetZIndex() {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).setZIndex(0);
  }
}

public void resetConstellationG() {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).setConstellationG(0);
  }
}

public boolean checkMoth(int range) {
  float deg = map(degrees(handRAngle), -180, 180, 0, 360);
  //println("moth HR: " + ( deg) + " should be 45");
  return (withinRange(degrees(handRAngle), 55, range) && withinRange(degrees(handLAngle), 145, range));
}

public boolean checkOrchid(int range) {
  return (withinRange(degrees(handRAngle), 90, range) && withinRange(degrees(elbowRAngle), 180, range)
    && withinRange(degrees(handLAngle), 90, range) && withinRange(degrees(elbowLAngle), 180, range));
}

public boolean checkHand(int range) {
  println((withinRange(degrees(handRAngle), 270, range) + " " + withinRange(degrees(elbowRAngle), 270, range)));
  return (withinRange(degrees(handRAngle), 270, range) && withinRange(degrees(elbowRAngle), 270, range)
    && withinRange(degrees(handLAngle), 180, range) && withinRange(degrees(elbowLAngle), 180, range));
}

public boolean checkOwl(int range) {
    return (withinRange(degrees(handRAngle), 225, range) && withinRange(degrees(elbowRAngle), 315, range)
      && withinRange(degrees(handLAngle), 315, range) && withinRange(degrees(elbowLAngle), 225, range));
}

public boolean checkWhale(int range) {
    return (withinRange(degrees(handRAngle), 0, range) && withinRange(degrees(elbowRAngle), 0, range)
      && withinRange(degrees(handLAngle), 315, range) && withinRange(degrees(elbowLAngle), 315, range));
}

public boolean withinRange(float actual, float ideal, float range) {
  actual = map(actual, -180, 180, 0, 360);
  if (ideal - range/2 < 0) {
    if (actual < ideal + range/2 || actual > ideal + 360 - range/2) return true;
    return false;
  }
  else if (ideal + range/2 > 360) {
    if (actual > ideal - range/2 || actual < ideal + range/2 - 360) return true;
    return false;
  }
  else {
    if (actual > ideal - range/2 && actual < ideal + range/2) return true;
    return false;
  }
}

public void setLines() {
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


public void setConst() {
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

public void testConstellations() {
  if (triggered > -1) {
    if (millis() - triggeredTime > 1000) {
      triggered = -1;
      triggeredTime = millis();
    }
    else {
      if (triggered == 0) {
        background(255, 0, 0);
        println("whale!!");
      }
      else if (triggered == 1) {
        background(0, 255, 0);
        println("hand!");
      }
      else if (triggered == 2) {
        background(0, 0, 255);
        println("owl");
      }
      else if (triggered == 3) {
        background(0, 255, 255);
        println ("moth");
      }
      else if (triggered == 4) {
          println("orchid");
          background(255, 0, 255);
      }
    }
  }
  else {
    if (checkWhale(20)) {
      triggered = 0;
      triggeredTime = millis();
    }
    else if (checkHand(20)) {
      triggered = 1;
      triggeredTime = millis();
    }
    else if (checkOwl(20)) {
      triggered = 2;
      triggeredTime = millis();
    }
    else if (checkMoth(20)) {
      triggered = 3;
      triggeredTime = millis();
    }
    else if (checkOrchid(20)) {
      triggered = 4;
      triggeredTime = millis();
    }
  }
}
class BodyPoint {

  PVector point;
  PVector next;
  int distToNext;

  BodyPoint() {
    point = new PVector(0,0);
    next = new PVector(0, 0);
    distToNext = 0;
  }

  public void set(PVector p1, PVector p2) {
    point.set(p1);
    next.set(p2);
    normalize();
  }

  public void set(PVector p1, PVector p2, int d) {
    point.set(p1);
    next.set(p2);
    distToNext = d;
    normalize();
  }

  public void set(KJoint j1, KJoint j2) {
    point.set(j1.getX(), j1.getY());
    next.set(j2.getX(), j2.getY());
    normalize();
  }

  public void set(KJoint j1, KJoint j2, int d) {
    point.set(j1.getX(), j1.getY());
    next.set(j2.getX(), j2.getY());
    distToNext = d;
    normalize();
  }
  
  public void normalize() {
    // first minus shoulder left, then scale, then add back to node point
    point.sub(offset);
    next.sub(offset);
    point.mult(sc);
    next.mult(sc);
    point.add(nodeOffset);
    next.add(nodeOffset);
  }
  
  public void display() {
    stroke(255, 0, 0);
    line(point.x, point.y, next.x, next.y);
  }
  
  public float angleBetween() {
    return atan2((next.y - point.y),(next.x - point.x));
  }
}



Minim       minim;
AudioPlayer myAudio;
FFT         myAudioFFT;

int         myAudioRange     = 256;
int         myNumBands       = 11;
int         myAudioMax       = 100;
int[]       bandBreaks       = {20, 50, 60, 80, 100, 150, 175, 200, 225, 255};
int[]       bands;
int[]       bandMax          = {141, 132, 265, 208, 197, 282, 214, 119, 120, 76};
int[]       fourBandsMax     = {averageBands(bandMax[0], bandMax[1], bandMax[2]), averageBands(bandMax[3], bandMax[4]), averageBands(bandMax[5], bandMax[6]), averageBands(bandMax[7], bandMax[8], bandMax[9])};

float       myAudioAmp       = 170.0f;
float       myAudioIndex     = 0.2f;
float       myAudioIndexAmp  = myAudioIndex;
float       myAudioIndexStep = 0.55f;

float       myAudioAmp2       = 30.0f;
float       myAudioIndex2     = 0.05f;
float       myAudioIndexAmp2  = 0.05f;
float       myAudioIndexStep2 = 0.025f;

boolean     showSpectrum     = true;
boolean     transparentMode  = false;
// ************************************************************************************

int         stageMargin      = 100;
int         stageWidth       = (880) - (2*stageMargin);
int         stageHeight      = 700;

int         rectSize         = stageWidth/(bandBreaks.length);
float       rect2Size        = stageWidth/256.0f;

float       xStart           = stageMargin;
float       yStart           = stageMargin;
int         xSpacing         = rectSize;
float       x2Spacing        = rect2Size;


// ************************************************************************************

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FFT

public void stop() {
  myAudio.close();
  minim.stop();  
  super.stop();
}

// modified from Adafruit Industries Neopixel Library
public int Wheel(int WheelPos) {
  WheelPos = 255 - WheelPos;
  if (WheelPos < 85) {
    return color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else if (WheelPos < 170) {
    WheelPos -= 85;
    return color(0, WheelPos * 3, 255 - WheelPos * 3);
  } else {
    WheelPos -= 170;
    return color(WheelPos * 3, 255 - WheelPos * 3, 0);
  }
}  

public void initFFT() {
  minim   = new Minim(this);
  myAudio = minim.loadFile("song.wav");
  myAudio.play();

  myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
  myAudioFFT.linAverages(myAudioRange);
  myAudioFFT.window(FFT.GAUSS);
  bands = new int[bandBreaks.length];
  //bandMax =  new int[bandBreaks.length];
}


public void updateFFT() {
  myAudioFFT.forward(myAudio.mix);

  int bandIndex = 0;
  while (bandIndex < bands.length) {
    float temp = 0;
    int startB = 0; 
    int endB = 0;
    if (bandIndex == 0) {
      startB = -1;
      endB = bandBreaks[bandIndex];
    } else if (bandIndex < bandBreaks.length) {
      startB = bandBreaks[bandIndex-1];
      endB = bandBreaks[bandIndex];
    }
    for (int j = startB+1; j <= endB; j++) {
      temp += myAudioFFT.getAvg(j);
    }
    temp /= endB - startB;
    temp *= myAudioAmp*myAudioIndexAmp;
    bands[bandIndex] = PApplet.parseInt(temp*(bandIndex+.5f));
    //if (bands[bandIndex] > bandMax[bandIndex]) {
    //  bandMax[bandIndex] = bands[bandIndex];
    //}
    //if (equalizer) {
    //  fourBands[0] = bands[0];
    //  fourBands[3] = bands[bands.length -1];
    //  for (int i = 1; i < 4; i++) {
    //    fourBands[i-1] = 0;
    //    fourBands[i-1] += bands[2*i-1];
    //    fourBands[i-1] += bands[2*i];
    //    fourBands[i-1] /= 2;
    //}
    bandIndex++;
  }
  myAudioIndexAmp = myAudioIndex;
  myAudioIndexAmp2 = myAudioIndex2;
}

public void drawFFT() {
  int bandIndex = 0;
  while (bandIndex < bandBreaks.length) {
    fill(255, 5);
    if (!transparentMode) fill (Wheel(PApplet.parseInt(bandIndex*(255.0f/bandBreaks.length))));
    else fill (Wheel(PApplet.parseInt(bandIndex*(255.0f/bandBreaks.length))), 5);
    rect( xStart + (bandIndex*xSpacing), yStart+200, rectSize, bands[bandIndex]);
    bandIndex++;
  }

  //stroke(#FF3300); noFill();
  //line(stageMargin, stageMargin+myAudioMax+200, 880-stageMargin, stageMargin+myAudioMax+200);

  //if(mouseX > stageMargin && mouseX < stageWidth+stageMargin) {
  //  stroke(0);
  //  fill(0);
  //  text((int)map(mouseX, stageMargin, stageWidth+stageMargin, 0, 256), mouseX, mouseY);
  //}
}

public int averageBands(int v1, int v2, int v3) {
  return (v1 + v2 + v3) /3;
}

public int averageBands(int v1, int v2) {
  return (v1 + v2) / 2;
}





class GraphList {

  int graphSize;
  int currentNodeIndex = -1;
  ArrayList<Node> nodes;
  Map<Integer, List<Integer>> nodeList;


  GraphList(int num) {
    graphSize = num;
    nodes = new ArrayList<Node>();
    nodeList = new HashMap<Integer, List<Integer>>();
    for (int i = 0; i < graphSize; i++) {
      nodeList.put(i, new LinkedList<Integer>());
    }
  }


  public void setEdge(int to, int from) 
  {
    if (to > nodeList.size() || from > nodeList.size()) {
      //System.out.println("The vertices does not exists");
    } else {
      List<Integer> sls = nodeList.get(to);
      sls.add(from);
      List<Integer> dls = nodeList.get(from);
      dls.add(to);
    }
  }

  // use this for loading graph to prevent duplicates
  public void setDirectedEdge(int to, int from) {
    //println(to + " " + from);
    if (to > nodeList.size() || from > nodeList.size()) {
      //System.out.println("The vertices does not exists");
    } else {
      List<Integer> sls = nodeList.get(to);
      sls.add(from);
    }
  }

  public List<Integer> getEdge(int to) {
    if (to > nodeList.size()) {
      //println("The vertices does not exists");
      return null;
    }
    return nodeList.get(to);
  }

  public void display() {
    for (int v = 0; v < nodes.size(); ++v) {
      int x1, y1;
      Node n = nodes.get(v); // could get to the point where this call isn't necessary- just tmp->x, tmp->y (that x, y is saved 2x)
      n.display();
      x1 = n.getX();
      y1 = n.getY();



      //fill(255);
      //stroke(255);
      strokeWeight(2);
      nodes.get(v).display();
      // draw lines between nodes

      List<Integer> edgeList = getEdge(v);
      if (edgeList != null) {
        for (int j = 0; j < edgeList.size(); j++) 
        {
          Node n2 = nodes.get(edgeList.get(j));
          line(x1, y1, n2.getX(), n2.getY());
        }
      }
    }
  }

  public void printGraph() {
    for (int v = 0; v < nodes.size(); ++v) {
      fill(255);
      // draw lines between nodes
      System.out.print(v + "->");
      List<Integer> edgeList = getEdge(v);
      if (edgeList != null) {
        for (int j = 0; j<edgeList.size(); j++) 
        {
          if (j != edgeList.size() -1) {
            System.out.print(edgeList.get(j) + " -> ");
          } else {
            System.out.print(edgeList.get(j));
            break;
          }
        }
      }
      println();
    }
  }

  public void saveGraph() {
    processing.data.JSONObject json;
    json = new processing.data.JSONObject();
    json.setInt("nodeNum", nodes.size());
    saveJSONObject(json, "data/graph.json");

    int h = 0;

    Iterator<Node> it = nodes.iterator();
    while (it.hasNext()) {
      Node n = it.next();
      processing.data.JSONObject json2;
      json2 = new processing.data.JSONObject();

      json2.setString("ID", n.ID);
      json2.setInt("x", n.x);
      json2.setInt("y", n.y);

      // adjacent node names
      processing.data.JSONArray adjacentNodes = new processing.data.JSONArray();      
      List<Integer> edgeList = getEdge(h);
      if (edgeList != null) {
        for (int j = 0; j < edgeList.size(); j++) 
        {
          adjacentNodes.setString(j, edgeList.get(j) + "");
        }
      }
      json2.setJSONArray("adjacentNodes", adjacentNodes);
      saveJSONObject(json2, "data/" + n.ID + ".json");
      h++;
    }
    saveLineValues();
  }


  public void loadGraph() {

    processing.data.JSONObject graphJson;
    graphJson = loadJSONObject("data/graph.json");
    int numNodes = graphJson.getInt("nodeNum");
    resetList();

    // create the nodes from JSON file
    ArrayList<Node> tempNodes = new ArrayList<Node>();
    for (int i = 0; i < numNodes; i++) {
      processing.data.JSONObject nodeJson = loadJSONObject("data/" + i + ".json");
      String name = nodeJson.getString("ID");
      int x = nodeJson.getInt("x");
      int y = nodeJson.getInt("y");

      tempNodes.add(new Node(name, x, y));
    }

    // create the edges from JSON file
    for (int i = 0; i < tempNodes.size(); i++) {
      processing.data.JSONObject nodeJson = loadJSONObject("data/" + i + ".json");
      processing.data.JSONArray adjNodes = nodeJson.getJSONArray("adjacentNodes");
      for (int j = 0; j < adjNodes.size(); j++) {
        setDirectedEdge(i, parseInt(adjNodes.getString(j)));
        //tempNodes.get(i).addDestination(tempNodes.get(parseInt(adjNodes.getString(j))));
      }
    }

    for (int i = 0; i < tempNodes.size(); i++) {
      nodes.add(tempNodes.get(i));
    }
    addLines();
    setLineValues();
  }

  public void addNode(int mx, int my) {
    nodes.add(new Node(nodes.size() + "", mx, my));
  }


  public boolean hasCurrentNode() {
    return (currentNodeIndex > -1);
  }

  public void moveCurrentNode(int dx, int dy) {
    nodes.get(currentNodeIndex).move(dx, dy);
  }

  public int getClickedNode(int mx, int my) {
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i).mouseOver(mx, my)) {
        return i;
      }
    }
    return -1;
  }

  public void checkEdgeClick(int mx, int my) {
    int prevNodeIndex = currentNodeIndex;
    currentNodeIndex = getClickedNode(mx, my);
    //cout << currentNodeIndex << " " << prevNodeIndex << std::endl;
    // if we actually clicked on a star to create an edge
    if (currentNodeIndex >= 0) {
      // if we've already selected a star
      if (prevNodeIndex >= 0) {
        // oops, clicked on the same star
        if (prevNodeIndex == currentNodeIndex) {
          currentNodeIndex = -1;
        }
        // clicked a new star! let's add an edge
        else {
          // add link in adjacency matrix
          setEdge(prevNodeIndex, currentNodeIndex);
        }
      }
    }
  }


  public void checkNodeClick(int mx, int my) {
    currentNodeIndex = getClickedNode(mx, my);
  }

  public int getCurrentNode() {
    //cout << currentNodeIndex << std::endl;
    return currentNodeIndex;
  }

  public void setCurrentNode(int num) {
    this.currentNodeIndex = num;
  }

  public void drawLineToCurrent(int x, int y) {
    stroke(255);
    if (currentNodeIndex > -1 && currentNodeIndex < nodes.size()) {
      line(nodes.get(currentNodeIndex).getX(), nodes.get(currentNodeIndex).getY(), x, y);
    }
  }

  public void resetList() {
    nodes = new ArrayList<Node>();
    lines = new ArrayList<Line>();
    nodeList = new HashMap<Integer, List<Integer>>();
    for (int i = 0; i < graphSize; i++) {
      nodeList.put(i, new LinkedList<Integer>());
    }
  }


  //void setAngles() {
  //  int v;
  //  for (v = 0; v < vertexCount; ++v) {
  //    int x0 = nodes.get(v).getX();
  //    int y0 = nodes.get(v).getY();
  //    // TODO
  //    AdjListNode* tmp = nodeList[v].head;    //tmp has the address of (0,1..)vertex head
  //    while (tmp)
  //    {
  //      int n = tmp->data;
  //      int x1 = nodes.get(n).getX();
  //      int y1 = nodes.get(n).getY();
  //      tmp->angle = getAngle(x0, y0, x1, y1);
  //      tmp = tmp->next;
  //    }
  //  }
  //}

  //void setPoints() {
  //  int v;
  //  for (v = 0; v < vertexCount; ++v) {
  //    // TODO
  //    AdjListNode* tmp = nodeList[v].head;    //tmp has the address of (0,1..)vertex head
  //    while (tmp)
  //    {
  //      int n = tmp->data;
  //      tmp->pt = ofVec2f(nodes.get(n).getX(), nodes.get(n).getY());
  //      tmp = tmp->next;
  //    }
  //    cout << endl;
  //  }
  //}

  public float getAngle(int x0, int y0, int x1, int y1) {
    return atan2((y1 - y0)*1.0f, (x1 - x0)*1.0f);
  }

  public void addLines() {
    int l = 0;
    for (int i = 0; i < nodes.size(); i++) {
      Node n = nodes.get(i);
      List<Integer> edgeList = getEdge(i);
      if (edgeList != null) {
        for (int j = 0; j < edgeList.size(); j++) 
        {
          int nextEdge = edgeList.get(j);
          if (nextEdge > i) {
            //println(i + " " + nextEdge);
            Node n2 = nodes.get(nextEdge);
            lines.add(new Line(n.getX(), n.getY(), n2.getX(), n2.getY(), l));
            l++;
          }
        }
      }
      // only add adjnodes if they have a greater id than the current node (nodes.get(i).hasAdjacent
    }
  }

  public int getClosestNode(int index, PVector goal) {
    int closest = -1;
    Node n = nodes.get(index);
    float dis = n.getDistance(goal);
    List<Integer> edgeList = getEdge(index);
    if (edgeList != null) {
      for (int j = 0; j < edgeList.size(); j++) {
        Node n2 = nodes.get(edgeList.get(j));
        float dis2 = n2.getDistance(goal);
        if (dis2 < dis) {
          dis = dis2;
          closest = edgeList.get(j);
        }
      }
    }
    return closest;
  }

  public ArrayList<Node> getConstellationPath(Node n, PVector goal) {
    int index = parseInt(n.ID);
    ArrayList<Node> path = new ArrayList<Node>();
    int closest = getClosestNode(index, goal);
    while (closest > -1) {
      path.add(nodes.get(closest));
      closest = getClosestNode(closest, goal);
    }
    return path;
  }


  public void drawLine(int[] path) {
    for (int i = 0; i < path.length-1; i++) {
      line(nodes.get(path[i]).getX(), nodes.get(path[i]).getY(), nodes.get(path[i+1]).getX(), nodes.get(path[i+1]).getY());
    }
  }

  public void drawLine(int n1, int n2) {
    if (n1 >=0 && n2 >= 0) 
      line(nodes.get(n1).getX(), nodes.get(n1).getY(), nodes.get(n2).getX(), nodes.get(n2).getY());
  }

  public void setLineValues() {
    processing.data.JSONObject json;
    json = loadJSONObject("data/lines.json");

    processing.data.JSONArray lineZs = json.getJSONArray("lineZs");
    processing.data.JSONArray constellationG = json.getJSONArray("constellationG");
    println("settin line z- size is " + lines.size());
    for (int j = 0; j < lines.size(); j++) {
      lines.get(j).zIndex = lineZs.getInt(j);
      lines.get(j).constellationG = constellationG.getInt(j);
    }
  }

  public void saveLineValues() {
    processing.data.JSONObject json;
    json = new processing.data.JSONObject();
    processing.data.JSONArray lineZs = new processing.data.JSONArray();  
    processing.data.JSONArray constellationG = new processing.data.JSONArray();  

    for (int j = 0; j < lines.size(); j++) {
      lineZs.setInt(j, lines.get(j).zIndex);
      constellationG.setInt(j, lines.get(j).constellationG);
    }
    json.setJSONArray("lineZs", lineZs);
    json.setJSONArray("constellationG", constellationG);
    saveJSONObject(json, "data/lines.json");
  }
}
public void drawConstellationFirst() {
  if (graphL.nodes.size() > 20) {
    stroke(255, 0, 0);
    fill(255, 0, 0);
    ArrayList<Node> bodyNodes = new ArrayList<Node>(); 

    for (int j = 0; j < 5; j++) {
      if (j == 0) bodyNodes = graphL.getConstellationPath(graphL.nodes.get(11), bodyPoints[0].next);
      else {
        if (bodyNodes.size() > 0) bodyNodes = graphL.getConstellationPath(bodyNodes.get(bodyNodes.size()-1), bodyPoints[j].next);
      }
      for (int i = 0; i < bodyNodes.size()-1; i++) {
        line(bodyNodes.get(i).getX(), bodyNodes.get(i).getY(), bodyNodes.get(i+1).getX(), bodyNodes.get(i+1).getY());
      }
    }
  }
}
class Line {

  PVector p1;
  PVector p2;
  int zIndex = 0;
  float ang;
  int id;
  int constellationG = 0;

  Line(PVector p1, PVector p2, int id) {
    this.p1 = p1;
    this.p2 = p2;
    initLine();
    this.id = id;
  }

  Line(Node n1, Node n2, int id) {
    this.p1.set(n1.getX(), n1.getY());
    this.p2.set(n2.getX(), n2.getY());
    initLine();
    this.id = id;
  }

  Line(int x1, int y1, int x2, int y2, int id) {
    this.p1 = new PVector(x1, y1);
    this.p2 = new PVector(x2, y2);
    initLine();
    this.id = id;
  }

  public void initLine() {
    leftToRight();
    ang = atan2(this.p1.y - this.p2.y, this.p1.x - this.p2.x);
    if (ang > PI/2) ang -= 2*PI;
  }

  public void display() {
    line(p1.x, p1.y, p2.x, p2.y);
  }

  public void leftToRight() {
    if (p1.x > p2.x) {
      PVector temp = new PVector(p1.x, p1.y);
      p1.set(p2);
      p2.set(temp);
    }
  }

  public void rightToLeft() {
    if (p1.x < p2.x) {
      PVector temp = p1;
      p1.set(p2);
      p2.set(temp);
    }
  }

  public void displayPercent(float per) {
    per*= 2;
    float p = constrain(per, 0, 1.0f);
    PVector pTemp = PVector.lerp(p1, p2, p);
    line(p1.x, p1.y, pTemp.x, pTemp.y);
  }

  public void displayPercentWid(float per) {
    per = constrain(per, 0, 1.0f);
    int sw = PApplet.parseInt(map(per, 0, 1.0f, 0, 5));
    strokeWeight(sw);
    line(p1.x, p1.y, p2.x, p2.y);
  }
  
  public void fftConstellation(float c, float per) {
    per = constrain(per, 0, 1.0f);
    int sw = PApplet.parseInt(map(per, 0, 1.0f, 0, 5));
    sw = constrain(sw, 0, 5);
    if (sw < 1) noStroke();
    else {
      strokeWeight(sw);
    }
    if (constellationG == c)line(p1.x, p1.y, p2.x, p2.y);
  }

  public void twinkle() {
    float ang = PVector.angleBetween(p2, p1);
    for (int i = 0; i < PVector.dist(p1, p2); i+=15) {
      ellipse(p1.x+i*cos(ang), p1.y+i*sin(ang), 8, 8);
    }
  }

  public void displayBandX(int start, int end) {
    if (p1.x > start && p1.x < end) {
      display();
    }
  }

  public void displayBandY(int start, int end) {
    if (p1.y > start && p1.y < end) {
      display();
    }
  }
  
  public void displayBandZ(int start, int end) {
    if (zIndex >= start && zIndex < end) {
      display();
    }
  }
  
  public void displayBandZ(int band) {
    if (zIndex == band) {
      display();
    }
  }
  
  public void displayConstellation(int num) {
    if (constellationG == num) {
      display();
    }
  }
  
  public void displayAngle(int start, int end) {
    if (end < -360) {
      if (ang >= radians(start) || ang < end + 360) {
        display();
      }
    }
    else if (ang >= radians(start) && ang < radians(end)) {
      display();
    }
  }
  
  public void displayEqualizer(int[] bandH) {
    if (p1.x >= 0 && p1.x < width/4) {
      displayBandY(0, bandH[0]);
    }
    else if (p1.x >= width/4 && p1.x < width/2) {
      displayBandY(0, bandH[1]);
    }
    else if (p1.x >= width/2 && p1.x < width*3.0f/4) {
      displayBandY(0, bandH[2]);
    }
    else {
      displayBandY(0, bandH[3]);
    }
  }

  // www.jeffreythompson.org/collision-detection/line-point.php
  public boolean mouseOver() {
    float x1 = p1.x;
    float y1 = p1.y;
    float x2 = p2.x;
    float y2 = p2.y;
    float px = mouseX;
    float py = mouseY;
    float d1 = dist(px, py, x1, y1);
    float d2 = dist(px, py, x2, y2);
    float lineLen = dist(x1, y1, x2, y2);
    float buffer = 0.2f;    // higher # = less accurate
    if (d1+d2 >= lineLen-buffer && d1+d2 <= lineLen+buffer) {
      return true;
    }
    return false;
  }
  
  public void setConstellationG(int k) {
    constellationG = k;
    println("constellation of " + id + " is now " + k);
  }
  
  public void setZIndex(int k) {
    zIndex = k;
    println("zIndex of " + id + " is now " + k); 
  }
}
class Node {
  int x, y, diam;
  String ID;


  //--------------------------------------------------------------
  Node() {
    // default
  }

  Node(String ID, int x, int y) {
    this.ID = ID;
    this.x = x;
    this.y = y;
    this.diam = 15;
  }

  //void addDestination(Node destination) {
  //    adjacentNodes.push_back(destination);
  //}

  // problem??
  //void setAdjacentNodePointers(vector<Node*> adjNodePointers) {
  //    adjacentNodes = adjNodePointers;
  //}

  //--------------------------------------------------------------
  // get

  public float getAngle(float x1, float x2, float y1, float y2) {
    // angle to actual point
    float dot = x1*x2 + y1*y2;      // dot product
    float det = x1*y2 - y1*x2;      // determinant
    float angle = atan2(det, dot);  // atan2(y, x) or atan2(sin, cos)
    return angle;
  }

  public String getID() {
    return this.ID;
  }

  public int getX() {
    return this.x;
  }
  public int getY() {
    return this.y;
  }
  
  public float getDistance(PVector goal) {
    PVector myPt = new PVector(x, y);
    return myPt.dist(goal);
  }

  //--------------------------------------------------------------
  // display
  public void display() {
    fill(255);
    if (mouseOver()) {
      fill(255, 0, 0);
    }
    strokeWeight(2);
    ellipse(x, y, this.diam, this.diam);
    text(ID, x, y-15);
  }

  public void displayEdge(Node n) {
  }

  public boolean mouseOver() {
    int mx = mouseX;
    int my = mouseY;
    int x = mx - this.getX();
    int y = my - this.getY();
    float d = sqrt(x*x + y*y);
    return (d < diam);
  }

  public boolean mouseOver(int mx, int my) {
    int x = mx - this.getX();
    int y = my - this.getY();
    float d = sqrt(x*x + y*y);
    return (d < diam);
  }

  //--------------------------------------------------------------
  // update
  public void move(int dx, int dy) {
    this.x +=dx;
    this.y += dy;
  }

  public void set(String s, int x, int y) {
    this.ID = s;
    this.x = x;
    this.y = y;
  }

  public void set(int x, int y) {
    this.x = x;
    this.y = y;
  }

  //--------------------------------------------------------------
  // save
  public String printData() {
    String s = ID + " " + getX() + " " + getY();
    return s;
  }
  


}
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Constellations" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
