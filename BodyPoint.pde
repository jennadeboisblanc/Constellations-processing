class BodyPoint {

  PVector point;
  PVector next;
  int distToNext;

  void set(PVector p1, PVector p2) {
    point.set(p1);
    next.set(p2);
  }

  void set(PVector p1, PVector p2, int d) {
    point.set(p1);
    next.set(p2);
    distToNext = d;
  }

  void set(KJoint j1, KJoint j2) {
    point.set(j1.getX(), j1.getY());
    next.set(j2.getX(), j2.getY());
  }

  void set(KJoint j1, KJoint j2, int d) {
    point.set(j1.getX(), j1.getY());
    next.set(j2.getX(), j2.getY());
    distToNext = d;
  }
}