class Line {
  
  int x1, y1, x2, y2, sw;
  
  Line(int x1, int y1, int x2, int y2) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
    sw = int(random(2, 8));
  }
  
  void display() {
    o.strokeWeight(sw);
    o.line(x1, y1, x2, y2);
  }
  
  void display(int strokew) {
    o.strokeWeight(strokew);
    o.line(x1, y1, x2, y2);
  }
  
  void move(int dx, int dy) {
    this.x1 += dx;
    this.x2 += dx;
    this.y1 += dy;
    this.y2 += dy;
    
    if (this.x1 < 0) {
      this.x1 = width;
      this.x2 = width;
    }
    else if (this.x1 > width) {
      this.x1 = 0;
      this.x2 = 0;
    }
  }
  
}