boolean NEW_GRAPH = false;

//////////////////////////////////////////////////////////
import java.nio.ByteBuffer;
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
int DELETE_NODES = 8;
int SET_NODES_Z = 7;
int SET_LINEZ = 5;
int SET_CONST = 6;
int mode = VISUALIZE;

int currentScene = -1;
int visualMode = -1;
int kinectMode = -1; 
long sendTime = 0;
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
  size(400, 400);
  lines = new ArrayList<Line>();
  graphL = new GraphList(100);
  if (!NEW_GRAPH) graphL.loadGraph();
  //else {
  //  resetConstellationG();
  //  resetZIndex();
  //}


  initFFT(0);
  myAudio.skip(1000*60*3);
  initBeat();

  //initKinect();
  //initBodyPoints();

  myServer = new Server(this, 5204);




  whale = loadImage("assets/whale.png");
  hand = loadImage("assets/handeye.png");
  orchid = loadImage("assets/orchid.png");
  moth = loadImage("assets/moth.png");
  owl = loadImage("assets/owl.png");

  initDeltaWaves();
  initCycles();
  initKirasu();
}


//--------------------------------------------------------------
void draw() {
  background(0);
  updateFFT();
  updateBeats();
  checkNextSong();
  if (mode == VISUALIZE) {
    checkScene();
    playMode();
    //cycleModes(2000);
    //displayThirdsBeat();
    //twinkleLines();
  } else {
    settingFunctions();
  }

  //graphL.drawOrganicPath3D(11, new PVector(mouseX, mouseY, 0));
  //drawKinect();
  //testKinect();
  
  if (millis() - sendTime > 100) {
    sendPanel();
    sendTime = millis();
  }
}

void sendPanel() {
  //byte b = byte(constrain(map(bands[0], 0, bandMax[0], 0, 255), 0, 255));
  byte songNum = 0;
  int duration = myAudio.position();
  byte byteDuration[] = ByteBuffer.allocate(4).putInt(duration).array();
  byte[] sendArray = {47, panelMode.getPanelByte(), getHandPanelX(), getHandPanelY(), getHandPanelZ(), 
    songNum, byteDuration[0], byteDuration[1], byteDuration[2], byteDuration[3]};
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
  else if (key == 'd') mode = DELETE_NODES;
  else if (key == 'z') mode = SET_NODES_Z;
  else if (key == 'c') {
    mode = SET_CONST;
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
  } else if (mode == SET_NODES_Z) {
    if (graphL.hasCurrentNode()) {
      println(parseInt(key));
      int k = parseInt(key) - 48;
      if (k > 0 && k < 9) {
        graphL.setCurrentNodeZ(k);
      }
    }
  } else if (mode == SET_CONST) {
    int k = parseInt(key) - 48;
    if (k > 0 && k < 9) {
      lines.get(lineIndex).setConstellationG(k);
    }
  } else if (mode == VISUALIZE) {
    if (key == '9') currentBeat++;
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
  } else if (mode == MOVE_NODES) {
    graphL.display();
    graphL.checkNodeClick(mouseX, mouseY);
  } else if (mode == ADD_EDGES) {
    graphL.checkEdgeClick(mouseX, mouseY);
  } else if (mode == DELETE_NODES) {
    graphL.checkDeleteNodeClick(mouseX, mouseY);
  } else if (mode == SET_LINEZ || mode == SET_CONST || mode == MOVE_LINES) {
    for (int i = 0; i < lines.size(); i++) {
      if (lines.get(i).mouseOver()) {
        lineIndex = i;
        println("l index " + lineIndex);
        break;
      }
    }
  } else if (mode == SET_NODES_Z) {
    graphL.checkNodeClick(mouseX, mouseY);
    updateLineZs();
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

void updateLineZs() {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).updateZ();
  }
}

void displayLineZDepth() {
  for (Line line : lines) {
    line.displayZDepth();
  }
}

void linesDisplay(int brightness) {
  for (int i = 0; i < lines.size(); i++) {
    stroke(brightness);
    fill(brightness);
    lines.get(i).display();
  }
}

void deleteLines(int index) {
  for (int i = lines.size() - 1; i >=0; i--) {
    if (lines.get(i).findByID(index)) {
      lines.remove(i);
    }
  }
}

void displayBox(int hue, String title) {
  colorMode(HSB, 255);
  fill(hue, 255, 255);
  noStroke();
  rect(0, height-50, width, 50);
  fill(255);
  stroke(255);
  textSize(30);
  text(title, 30, height-15);
  colorMode(RGB, 255);
}

void settingFunctions() {
  graphL.displayNodes();
  graphL.displayNodeLabels();
  linesDisplay(255);
  
  if (mode == ADD_EDGES) {
    graphL.drawLineToCurrent(mouseX, mouseY);
    displayBox(0, "ADD EDGES");
  } 
  else if (mode == ADD_NODES) {
    ellipse(mouseX, mouseY, 20, 20);
    displayBox(20, "ADD NODES");
  } 
  else if (mode == DELETE_NODES) {
    graphL.display();
    displayBox(50, "DELETE NODES");
  } 
  else if (mode == MOVE_NODES || mode == MOVE_LINES) {
    graphL.displayCurrentNode();
    displayBox(70, "MOVE");
  } else if (mode == SET_NODES_Z) {
    displayLineZDepth();
    displayBox(100, "SET NODES Z");
    graphL.displayCurrentNode();
  } else if (mode == SET_CONST) {
    setConst();
    displayBox(140, "SET CONSTELLATIONS");
  }
}