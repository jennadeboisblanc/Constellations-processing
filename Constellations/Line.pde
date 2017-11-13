class Line {

  PVector p1;
  PVector p2;
  int zIndex = 0;
  float ang;
  int id1, id2;
  int constellationG = 0;

  Line(PVector p1, PVector p2, int id1, int id2) {
    this.p1 = p1;
    this.p2 = p2;
    initLine();
    this.id1 = id1;
    this.id2 = id2;
  }

  Line(Node n1, Node n2, int id1, int id2) {
    this.p1.set(n1.getX(), n1.getY());
    this.p2.set(n2.getX(), n2.getY());
    initLine();
    this.id1 = id1;
    this.id2 = id2;
  }

  Line(int x1, int y1, int x2, int y2, int id1, int id2) {
    this.p1 = new PVector(x1, y1);
    this.p2 = new PVector(x2, y2);
    initLine();
    this.id1 = id1;
    this.id2 = id2;
  }

  void initLine() {
    leftToRight();
    ang = atan2(this.p1.y - this.p2.y, this.p1.x - this.p2.x);
    if (ang > PI/2) ang -= 2*PI;
  }

  void display() {
    line(p1.x, p1.y, p2.x, p2.y);
  }

  void moveP1(int x, int y) {
    p1.x += x;
    p1.y += y;
  }

  void moveP2(int x, int y) {
    p2.x += x;
    p2.y += y;
  }

  void leftToRight() {
    if (p1.x > p2.x) {
      PVector temp = new PVector(p1.x, p1.y);
      p1.set(p2);
      p2.set(temp);
    }
  }

  void rightToLeft() {
    if (p1.x < p2.x) {
      PVector temp = p1;
      p1.set(p2);
      p2.set(temp);
    }
  }

  void displayPercent(float per) {
    per*= 2;
    float p = constrain(per, 0, 1.0);
    PVector pTemp = PVector.lerp(p1, p2, p);
    line(p1.x, p1.y, pTemp.x, pTemp.y);
  }

  void displayPercentWid(float per) {
    per = constrain(per, 0, 1.0);
    int sw = int(map(per, 0, 1.0, 0, 5));
    strokeWeight(sw);
    line(p1.x, p1.y, p2.x, p2.y);
  }

  void fftConstellation(float c, float per) {
    per = constrain(per, 0, 1.0);
    int sw = int(map(per, 0, 1.0, 0, 5));
    sw = constrain(sw, 0, 5);
    if (sw < 1) noStroke();
    else {
      strokeWeight(sw);
    }
    if (constellationG == c)line(p1.x, p1.y, p2.x, p2.y);
  }

  void twinkle() {
    float ang = PVector.angleBetween(p2, p1);
    for (int i = 0; i < PVector.dist(p1, p2); i+=15) {
      ellipse(p1.x+i*cos(ang), p1.y+i*sin(ang), 8, 8);
    }
  }

  void displayBandX(int start, int end) {
    if (p1.x > start && p1.x < end) {
      display();
    }
  }

  void displayBandY(int start, int end) {
    if (p1.y > start && p1.y < end) {
      display();
    }
  }

  void displayBandZ(int start, int end) {
    if (zIndex >= start && zIndex < end) {
      display();
    }
  }

  void displayBandZ(int band) {
    if (zIndex == band) {
      display();
    }
  }

  void displayConstellation(int num) {
    if (constellationG == num) {
      display();
    }
  }

  void displayAngle(int start, int end) {
    if (end < -360) {
      if (ang >= radians(start) || ang < end + 360) {
        display();
      }
    } else if (ang >= radians(start) && ang < radians(end)) {
      display();
    }
  }

  void displayEqualizer(int[] bandH) {
    if (p1.x >= 0 && p1.x < width/4) {
      displayBandY(0, bandH[0]);
    } else if (p1.x >= width/4 && p1.x < width/2) {
      displayBandY(0, bandH[1]);
    } else if (p1.x >= width/2 && p1.x < width*3.0/4) {
      displayBandY(0, bandH[2]);
    } else {
      displayBandY(0, bandH[3]);
    }
  }

  // www.jeffreythompson.org/collision-detection/line-point.php
  boolean mouseOver() {
    float x1 = p1.x;
    float y1 = p1.y;
    float x2 = p2.x;
    float y2 = p2.y;
    float px = mouseX;
    float py = mouseY;
    float d1 = dist(px, py, x1, y1);
    float d2 = dist(px, py, x2, y2);
    float lineLen = dist(x1, y1, x2, y2);
    float buffer = 0.2;    // higher # = less accurate
    if (d1+d2 >= lineLen-buffer && d1+d2 <= lineLen+buffer) {
      return true;
    }
    return false;
  }

  void setConstellationG(int k) {
    constellationG = k;
    println("constellation of " + id1 + "" + id2 + " is now " + k);
  }

  void setZIndex(int k) {
    zIndex = k;
    println("zIndex of " + id1 + "" + id2 + " is now " + k);
  }

  void displayByIDs(int id1, int id2) {
    if ((this.id1 == id1 && this.id2 == id2) || (this.id2 == id1 && this.id1 == id2)) {
      display();
    }
  }
  
  int getX1() {
    return int(p1.x);
  }
  
  int getX2() {
    return int(p2.x);
  }
  
  int getY1() {
    return int(p1.y);
  }
  
  int getY2() {
    return int(p2.y);
  }
}