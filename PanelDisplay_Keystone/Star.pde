class Star {
  int x, y;

  Star(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  void display() {
    o.pushMatrix();
    o.translate(0, 0, -2);
    float r = random(50, 255);
    o.fill(255, r);
    o.stroke(r);
    o.ellipse(x, y, 5,5);
    o.popMatrix();
  }
  
  void displaySymbol(int i, float sc) {
    o.image(symbolImages[i], x, y, symbolImages[i].width *sc, 
      symbolImages[i].height *sc);
  }
  
  void move(int x, int y) {
    this.x += x;
    this.y += y;
    if (this.x > canvasW + 300) this.x = canvasW - 300;
    else if (this.x < -300) this.x = canvasW + 300;
    if (this.y > canvasH) this.y -= canvasH;
    else if (this.y < 0) this.y += canvasH;
  }
}