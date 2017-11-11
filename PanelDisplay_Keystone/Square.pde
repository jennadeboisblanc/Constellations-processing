class Square {
 
  int x, y, wid;
  float angle;
  
  Square(int x, int y, int wid) {
    this.x = x;
    this.y = y;
    this.wid = wid;
    angle = random(2 * PI);
  }
  
  void displayStriped(int lineW) {
    o.pushMatrix();
    o.translate(x, y);
    o.rotateZ(angle);
    
    o.fill(0);
    o.noStroke();
    o.rect(0, 0, wid, wid);
    o.fill(255);
    for (int i = 0; i < wid; i+= lineW) {
      o.rect(0, 0 + i, wid, lineW);
      i += lineW;
    }
    o.popMatrix();
    angle += .01;
  }
}