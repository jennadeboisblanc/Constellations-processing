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

  float getAngle(float x1, float x2, float y1, float y2) {
    // angle to actual point
    float dot = x1*x2 + y1*y2;      // dot product
    float det = x1*y2 - y1*x2;      // determinant
    float angle = atan2(det, dot);  // atan2(y, x) or atan2(sin, cos)
    return angle;
  }

  String getID() {
    return this.ID;
  }

  int getX() {
    return this.x;
  }
  int getY() {
    return this.y;
  }

  //--------------------------------------------------------------
  // display
  void display() {
    fill(255);
    if (mouseOver()) {
      fill(255, 0, 0);
    }
    strokeWeight(2);
    ellipse(x, y, 5, 5);
    text(ID, x, y-15);
  }

  void displayEdge(Node n) {
  }

  boolean mouseOver() {
    int mx = mouseX;
    int my = mouseY;
    int x = mx - this.getX();
    int y = my - this.getY();
    float d = sqrt(x*x + y*y);
    return (d < diam);
  }

  boolean mouseOver(int mx, int my) {
    int x = mx - this.getX();
    int y = my - this.getY();
    float d = sqrt(x*x + y*y);
    return (d < diam);
  }

  //--------------------------------------------------------------
  // update
  void move(int dx, int dy) {
    this.x +=dx;
    this.y += dy;
  }

  void set(String s, int x, int y) {
    this.ID = s;
    this.x = x;
    this.y = y;
  }

  void set(int x, int y) {
    this.x = x;
    this.y = y;
  }

  //--------------------------------------------------------------
  // save
  String printData() {
    String s = ID + " " + getX() + " " + getY();
    return s;
  }

}