class BodyPoint {

  PVector point;
  PVector next;
  int distToNext;

  BodyPoint() {
    point = new PVector(0,0);
    next = new PVector(0, 0);
    distToNext = 0;
  }

  void set(PVector p1, PVector p2) {
    point.set(p1);
    next.set(p2);
    normalize();
  }

  void set(PVector p1, PVector p2, int d) {
    point.set(p1);
    next.set(p2);
    distToNext = d;
    normalize();
  }

  void set(KJoint j1, KJoint j2) {
    point.set(j1.getX(), j1.getY());
    next.set(j2.getX(), j2.getY());
    normalize();
  }

  void set(KJoint j1, KJoint j2, int d) {
    point.set(j1.getX(), j1.getY());
    next.set(j2.getX(), j2.getY());
    distToNext = d;
    normalize();
  }
  
  void normalize() {
    // first minus shoulder left, then scale, then add back to node point
    point.sub(offset);
    next.sub(offset);
    point.mult(sc);
    next.mult(sc);
    point.add(nodeOffset);
    next.add(nodeOffset);
  }
  
  void display() {
    stroke(255, 0, 0);
    line(point.x, point.y, next.x, next.y);
  }
  
  float angleBetween() {
    return atan2((next.y - point.y),(next.x - point.x));
  }
}