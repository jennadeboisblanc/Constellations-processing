class Star {
  int x, y, rad;

  Star(int x, int y) {
    this.x = x;
    this.y = y;
    rad = int (random(2, 5));
  }

  void display() {
    o.pushMatrix();
    o.translate(0, 0, -2);
    float r = random(50, 255);
    o.fill(255, r);
    o.stroke(r);
    o.ellipse(x, y, rad, rad);
    o.popMatrix();
  }

  void displaySymbol(int i, float sc) {
    o.image(symbolImages[i], x-symbolImages[i].width/2*sc, y-symbolImages[i].height/2*sc, symbolImages[i].width *sc, 
      symbolImages[i].height *sc);
  }
  
   void displayConstellation(int i, float sc) {
     PImage c = constellationImages[i];
    o.image(c, x-c.width/2*sc, y-c.height/2*sc, c.width *sc, c.height *sc);
  }

  void moveBuffer(int x, int y, int buffer) {
    this.x += x;
    this.y += y;
    if (this.x > canvasW + buffer) this.x = - buffer;
    else if (this.x < -buffer) this.x = canvasW + buffer;
    if (this.y > canvasH) this.y -= canvasH;
    else if (this.y < 0) this.y += canvasH;
  }
  
  void move(int x, int y) {
    moveBuffer(x, y, 0);
  }

  void pulseStar() {
    int w = 200;
    o.noStroke();
    o.fill(255, 30);
    float wid = w*sin(millis()/100);
    o.ellipse(this.x, this.y, wid, wid);
    
    o.fill(255, 50);
    wid = w*sin(millis()/100)*.75;
    o.ellipse(this.x, this.y, wid, wid);
    
    o.fill(255, 70);
    wid = w*sin(millis()/100)*.5;
    o.ellipse(this.x, this.y, wid, wid);
    
    o.fill(255, 90);
    wid = w*sin(millis()/100)*.25;
    o.ellipse(this.x, this.y, wid, wid);
    
  }
}