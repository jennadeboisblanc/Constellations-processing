
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


void setup() {
  graphL = new GraphList(100);
  size(640, 480);

  initFFT();


  lines = new ArrayList<Line>();
  graphL.loadGraph();

  initKinect();
  initBodyPoints();

  //resetConstellationG();
  //resetZIndex();
}


//--------------------------------------------------------------
void draw() {
  background(0);
  updateFFT();
  //drawFFT();
  //graphL.display();
  //drawKinect();

  fill(0, 0, 255);
  stroke(0, 0, 255);
  //graphL.display();

  colorMode(RGB);
  stroke(255);
  fill(255);

  if (mode == ADD_EDGES) {
    graphL.display();
    graphL.drawLineToCurrent(mouseX, mouseY);
  } else if (mode == ADD_NODES) {
    graphL.display();
    fill(255, 0, 0);
    ellipse(mouseX, mouseY, 20, 20);
  } else if (mode == KINECT_TIMESHOT) {
    // text of time remaining?
  } else if (mode == VISUALIZE) {
    cycleModes(3000);
  } else if (mode == SET_LINEZ) {
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
  } else if (mode == SET_CONST) {
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

  //drawBody();

  //drawConstellation();
  fill(255);
  text(frameRate, 100, 100);
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