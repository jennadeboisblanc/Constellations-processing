class ConstellationLine {

  ArrayList<PVector> points;
  int x, y;
  float angle;

  ConstellationLine(int x, int y) {
    this.x = x;
    this.y = y;
    this.angle = random(2 * PI);
    points = new ArrayList<PVector>();
    points.add(new PVector(0, 0));
    randomPoints();
  }

  void display() {
    int dotS = 10;
    o.pushMatrix();
    o.stroke(255);
    o.strokeWeight(3);
    o.fill(255);
    o.translate(x, y);
    o.rotateZ(this.angle);
    angle += .01;
    for (int i = 0; i < points.size()-1; i++) {
      o.ellipse(points.get(i).x, points.get(i).y, dotS, dotS);
      o.line(points.get(i).x, points.get(i).y, points.get(i+1).x, points.get(i+1).y);
    }
    o.ellipse(points.get(points.size()-1).x, points.get(points.size()-1).y, dotS, dotS);
    o.popMatrix();
  }

  void move(int speed) {
    this.x += speed;
    if (this.x > width + 300) this.x = -300;
    else if (this.x < -300) this.x = width + 300;
  }

  void randomPoints() {
    int numPoints = int(random(3, 5));
    int p = 1;
    float xp = 0;
    float yp = 0;
    float ang = 0;
    while (p <= numPoints) {
      p++;
      float len = random(100, 200);
      if (p == 3) {
        int join = millis()%3;
        if (join == 0) {
          xp = points.get(1).x;
          yp = points.get(1).y;
        } else if (join == 1) {
          xp = points.get(0).x;
          yp = points.get(0).y;
        } else {
          int num = int(random(1, 8));
          float newAng = num * (2 * PI) / 8;
          xp += len * cos(newAng);
          yp += len * sin(newAng);
        }
      } else {
        int num = int(random(1, 8));
        float newAng = num * (2 * PI) / 8;
        xp += len * cos(newAng);
        yp += len * sin(newAng);
      }
      points.add(new PVector(xp, yp));
    }
  }
}