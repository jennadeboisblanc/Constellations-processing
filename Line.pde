class Line {

  PVector p1;
  PVector p2;

  Line(PVector p1, PVector p2) {
    this.p1 = p1;
    this.p2 = p2;
    leftToRight();
  }
  
   Line(Node n1, Node n2) {
    this.p1.set(n1.getX(), n1.getY());
    this.p2.set(n2.getX(), n2.getY());
    leftToRight();
  }
  
  Line(int x1, int y1, int x2, int y2) {
    this.p1 = new PVector(x1, y1);
    this.p2 = new PVector(x2, y2);
    leftToRight();
  }

  void display() {
    strokeWeight(2);
    fill(255);
    stroke(255);
    line(p1.x, p1.y, p2.x, p2.y);
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
    strokeWeight(2);
    fill(200);
    stroke(200);
    float p = constrain(per, 0, 1.0);
    PVector pTemp = PVector.lerp(p1, p2, p);
    line(p1.x, p1.y, pTemp.x, pTemp.y);
  }
  
  void twinkle() {
    float ang = PVector.angleBetween(p2,p1);
    for (int i = 0; i < PVector.dist(p1, p2); i+=15) {
      ellipse(p1.x+i*cos(ang), p1.y+i*sin(ang), 8,8);
    }
  }
  
  void pulseLeftToRight(int start, int end) {
    if (p1.x > start && p1.x < end) {
      display();
    }
  }
}