class Line {

  PVector p1;
  PVector p2;
  int zIndex = 0;
  int z1 = 0;
  int z2 = 0;
  float zAve = 0;
  float ang;
  int id1, id2;
  int constellationG = 0;
  int twinkleT;
  int twinkleRange = 0;
  long lastChecked = 0;

  Line(PVector p1, PVector p2, int id1, int id2) {
    this.p1 = p1;
    this.p2 = p2;
    initLine();
    this.id1 = id1;
    this.id2 = id2;
    updateZ();
  }

  Line(Node n1, Node n2, int id1, int id2) {
    this.p1.set(n1.getX(), n1.getY());
    this.p2.set(n2.getX(), n2.getY());
    initLine();
    this.id1 = id1;
    this.id2 = id2;
    updateZ();
  }

  Line(int x1, int y1, int x2, int y2, int id1, int id2) {
    this.p1 = new PVector(x1, y1);
    this.p2 = new PVector(x2, y2);
    initLine();
    this.id1 = id1;
    this.id2 = id2;
    updateZ();
  }

  void updateZ() {
    z1 = graphL.nodes.get(id1).z;
    z2 = graphL.nodes.get(id2).z;
    zAve = (z1 *1.0 + z2)/2.0;
  }

  void initLine() {
    leftToRight();
    ang = atan2(this.p1.y - this.p2.y, this.p1.x - this.p2.x);
    if (ang > PI/2) ang -= 2*PI;
    twinkleT = int(random(50, 255));
    twinkleRange = int(dist(p1.x, p1.y, p2.x, p2.y)/100);
  }

  void display() {
    line(p1.x, p1.y, p2.x, p2.y);
  }

  void display(color c) {
    fill(c);
    stroke(c);
    display();
  }

  void displayCenterPulse(float per) {
    per = constrain(per, 0, 1.0);
    float midX = (p1.x + p2.x)/2;
    float midY = (p1.y + p2.y)/2;
    float x1 = map(per, 0, 1.0, midX, p1.x);
    float x2 = map(per, 0, 1.0, midX, p2.x);
    float y1 = map(per, 0, 1.0, midY, p1.y);
    float y2 = map(per, 0, 1.0, midY, p2.y);
    line(x1, y1, x2, y2);
  }



  void moveP1(int x, int y) {
    p1.x += x;
    p1.y += y;
  }

  void moveP2(int x, int y) {
    p2.x += x;
    p2.y += y;
  }

  void displayZDepth() {
    colorMode(HSB, 255);
    stroke(map(zAve, 0, 9, 0, 255), 255, 255);
    display();
    colorMode(RGB, 255);
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

  void twinkle(int wait) {
    int num = int(dist(p1.x, p1.y, p2.x, p2.y)/100);

    if (millis() - lastChecked > wait) {
      twinkleT = int(random(100, 255));
      lastChecked = millis();
      //if (twinkleT > 220) twinkleRange = num + int(random(3));
    }

    noStroke();
    fill(twinkleT);
    for (int i = 0; i < num; i++) {
      float x = map(i, -.5, twinkleRange, p1.x, p2.x);
      float y = map(i, -.5, twinkleRange, p1.y, p2.y);
      ellipse(x, y, 10, 10);
    }
  }

  void randomSegment() {
    //float len = random(
  }

  void displayBandX(int start, int end) {
    if (p1.x > start && p1.x < end) {
      display(color(255));
    } else {
      display(color(0));
    }
  }

  void displayBandY(int start, int end) {
    if (p1.y > start && p1.y < end) {
      display(color(255));
    } else {
      display(color(0));
    }
  }

  void displayBandZ(int start, int end) {
    if (z1 >= start && z1 < end) {
      display(color(255));
    } else {
      display(color(0));
    }
  }

  void displayBandZ(int band) {
    if (z1 == band) {
      display(color(255));
    } else {
      display(color(0));
    }
  }

  void displayConstellation(int num) {
    if (constellationG == num) {
      display(color(255));
    } else {
      display(color(0));
    }
  }

  void displayAngle(int start, int end) {
    if (end < -360) {
      if (ang >= radians(start) || ang < end + 360) {
        display(color(255));
      } else {
        display(color(0));
      }
    } else if (ang >= radians(start) && ang < radians(end)) {
      display(color(255));
    } else {
      display(color(0));
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

  void displayPointX(int x) {
    float ym;

    if (x > p1.x && x < p2.x) {
      ym = map(x, p1.x, p2.x, p1.y, p2.y);
      ellipse(x, ym, 10, 10);
    } else if (x > p2.x && x < p1.x) {
      ym = map(x, p2.x, p1.x, p2.y, p1.y);
      ellipse(x, ym, 10, 10);
    }
  }

  void displayPointY(int y) {
    float xm;
    if ( (y > p1.y && y < p2.y) ) {
      xm = map(y, p1.y, p2.y, p1.x, p2.x);
      ellipse(xm, y, 10, 10);
      //println(y + " " + xm);
    } else if (y > p2.y && y < p1.y) {
      xm = map(y, p2.y, p1.y, p2.x, p1.x);
      ellipse(xm, y, 10, 10);
      //println(y + " " + xm);
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
    if (findByID(id1, id2)) {
      display();
    }
  }

  void displayByIDsPercent(int id1, int id2, float per) {
    if (findByID(id1, id2)) {
      displayPercent(per);
    }
  }

  void handLight(int x, int y, int rad) {
    float i = 0.0;
    float startX = p1.x;
    float startY = p1.y;
    boolean started = false;
    while (i < 1.0) {
      i+= .1;
      if (!started) {
        float dx = map(i, 0, 1.0, p1.x, p2.x);
        float dy = map(i, 0, 1.0, p1.y, p2.y);
        float dis = dist(x, y, dx, dy);
        if (dis < rad) {
          startX = dx;
          startY = dy;
          started = true;
        }
      } else {
        float dx = map(i, 0, 1.0, p1.x, p2.x);
        float dy = map(i, 0, 1.0, p1.y, p2.y);
        float dis = dist(x, y, dx, dy);
        if (dis > rad) {
          line(startX, startY, dx, dy);
          break;
        }
      }
    }
  }

  void displaySegment(float startPer, float sizePer) {
    PVector pTemp = PVector.lerp(p1, p2, startPer);
    PVector pTempEnd = PVector.lerp(pTemp, p2, startPer + sizePer);
    line(pTemp.x, pTemp.y, pTempEnd.x, pTempEnd.y);
  }

  boolean findByID(int id1, int id2) {
    return (this.id1 == id1 && this.id2 == id2) || (this.id2 == id1 && this.id1 == id2);
  }

  boolean findByID(int id) {
    return (this.id1 == id || this.id2 == id);
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