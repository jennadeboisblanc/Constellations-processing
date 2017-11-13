boolean NEW_GRAPH = false;

//////////////////////////////////////////////////////////
import processing.net.*;
Server myServer;
import java.util.ArrayList;
GraphList graphL;

///////////////////////////////////////
// MODES
int VISUALIZE = 0;
int ADD_NODES = 1;
int ADD_EDGES = 2;
int MOVE_NODES = 3;
int MOVE_LINES = 4;
int SET_LINEZ = 5;
int SET_CONST = 6;
int mode = MOVE_LINES;

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
int currentString;



void setup() {
  //fullScreen();
  size(1200, 800);
  lines = new ArrayList<Line>();
  graphL = new GraphList(100);
  if (!NEW_GRAPH) graphL.loadGraph();
  //else {
  //  resetConstellationG();
  //  resetZIndex();
  //}


  initFFT();

  //initKinect();
  //initBodyPoints();

 // myServer = new Server(this, 5204);




  whale = loadImage("assets/whale.png");
  hand = loadImage("assets/handeye.png");
  orchid = loadImage("assets/orchid.png");
  moth = loadImage("assets/moth.png");
  owl = loadImage("assets/owl.png");

  initDeltaWaves();
}


//--------------------------------------------------------------
void draw() {
  background(0);
  //updateFFT();

  if (mode == VISUALIZE) {
    //airBenderY();
    checkScene();
    playMode();
  } else {
    settingFunctions();
  }

  //stroke(255);
  //fill(255);
  //graphL.display();
  stroke(0, 255, 255);
  fill(0, 255, 255);
  //graphL.drawOrganicPath(17, new PVector(mouseX, mouseY));
  //sendPanel();
  //drawKinect();
  //testKinect();
}

void sendPanel() {
  byte b = byte(constrain(map(bands[0], 0, bandMax[0], 0, 255), 0, 255));
  byte[] sendArray = {47, byte(panelMode), getHandPanelX(), getHandPanelY(), getHandPanelZ(), b, b, b, b, b};
  myServer.write(sendArray);
  //println(sendArray);
}

//--------------------------------------------------------------
void keyPressed() {
  if (key == 's') {
    graphL.saveGraph();
    graphL.printGraph();
  } else if (key == 'r') graphL.loadGraph();
  else if (key == 'a') mode = ADD_NODES;
  else if (key == 'e') mode = ADD_EDGES;
  else if (key == 'm') mode = MOVE_LINES;
  else if (key == 'n') mode = MOVE_NODES;
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
  } else if (mode == MOVE_LINES) {
    if (lineIndex >= 0) {
      Line l = lines.get(lineIndex);
      if (keyCode == UP) l.moveP1(0, -1);
      else if (keyCode == DOWN) l.moveP1(0, 1);
      else if (keyCode == RIGHT) l.moveP1(1, 0);
      else if (keyCode == LEFT) l.moveP1(-1, 0);
      else if (keyCode == 73) l.moveP2(0, -1);     
      else if (keyCode == 75) l.moveP2(0, 1);     
      else if (keyCode == 76) l.moveP2(1, 0);
      else if (keyCode == 74) l.moveP2(-1, 0);
    }
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

// get a string
// up, down, left, right -> p1
// i, k, j, l -> p2
boolean hasCurrentStringPoint() {
  return true;
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
    graphL.display();
    graphL.addNode(mouseX, mouseY);
  } 
  else if (mode == MOVE_NODES) {
    graphL.display();
    graphL.checkNodeClick(mouseX, mouseY);
  } 
  else if (mode == ADD_EDGES) {
    graphL.checkEdgeClick(mouseX, mouseY);
  } else if (mode == SET_LINEZ || mode == SET_CONST || mode == MOVE_LINES) {
    for (int i = 0; i < lines.size(); i++) {
      if (lines.get(i).mouseOver()) {
        lineIndex = i;
        println("l index " + lineIndex);
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
    graphL.displayNodes();
    linesDisplay(255);
    graphL.drawLineToCurrent(mouseX, mouseY);
  } else if (mode == ADD_NODES) {
    graphL.displayNodes();
    linesDisplay(255);
    stroke(255, 255, 0);
    fill(255);
    ellipse(mouseX, mouseY, 20, 20);
  } else if (mode == MOVE_NODES || mode == MOVE_LINES) {
    graphL.displayNodes();
    linesDisplay(255);
  } else if (mode == SET_LINEZ) setLines();
  else if (mode == SET_CONST) setConst();
}