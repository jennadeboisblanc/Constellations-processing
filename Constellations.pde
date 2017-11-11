import processing.net.*;
Server myServer;
import java.util.ArrayList;
import KinectPV2.KJoint;
import KinectPV2.*;  // Thomas Sanchez Lengeling http://codigogenerativo.com/
KinectPV2 kinect;
GraphList graphL;

///////////////////////////////////////
// MODES
int VISUALIZE = 0;
int ADD_NODES = 1;
int ADD_EDGES = 2;
int MOVE_NODES = 3;
int KINECT_TIMESHOT = 4;
int SET_LINEZ = 5;
int SET_CONST = 6;
int mode = VISUALIZE;

int currentScene = -1;
int visualMode = -1;
int kinectMode = -1; 
int panelMode = -1;
///////////////////////////////////////

long stringChecked = 0;
ArrayList<Line> lines;
PVector offset;
PVector nodeOffset;
float sc = 1.0;
int lineIndex = 0;
int triggered = -1;
int triggeredTime = 0;
PImage whale, hand, orchid, moth, owl;




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

  initDeltaWaves();
}


//--------------------------------------------------------------
void draw() {
  background(0);
  updateFFT();

  if (mode == VISUALIZE) {
    checkScene();
    playMode();
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
  } else if (mode == MOVE_NODES) {
    graphL.display();
    fill(0, 255, 0);
    //ellipse(mouseX, mouseY, 20, 20);
  } else if (mode == SET_LINEZ) setLines();
  else if (mode == SET_CONST) setConst();
}