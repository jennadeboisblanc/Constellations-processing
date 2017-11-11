class Star {
  int x, y;

  Star(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  void display() {
    float r = random(50, 255);
    o.fill(255, r);
    o.stroke(r);
    o.ellipse(x, y, 5,5);
  }
  
  void move(int x, int y) {
    this.x += x;
    this.y += y;
    if (this.x > canvasW) this.x -= canvasW;
    else if (this.x < 0) this.x += canvasW;
    if (this.y > canvasH) this.y -= canvasH;
    else if (this.y < 0) this.y += canvasH;
  }
}