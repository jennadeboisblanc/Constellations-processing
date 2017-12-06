
// Blackout variables
float smallSideActualH = 8.0;
float bigSideActualH = 20.0*12;
float sideRatio;

float bigSideH;
float smallGap;
float smallSideH;
int canvasW = 1920;
int canvasH = 1200;
boolean trim = false;
boolean outline = false;

void init() {
  rectMode(CENTER);
  ellipseMode(CENTER);
  imageMode(CENTER);

 
  
  stars = new Star[150];
  for (int i = 0; i < stars.length; i++) {
    stars[i] = new Star(int(random(canvasW)), int(random(canvasH)));
  }
  squares = new Square[10];
  for (int i = 0; i < squares.length; i++) {
    squares[i] = new Square(i * 200, int(startH), 900);//int(random(100, 300)));
  }
  constellationImages = new PImage[6];
  for (int i = 0; i < 5; i++) {
    constellationImages[i] = loadImage("constellations/" + 
      constellationNames[i] + ".png");
  }
  constellationLines = new ConstellationLine[10];
  for (int i = 0; i < constellationLines.length; i++) {
    constellationLines[i] = new ConstellationLine(i*200, int(startH));//int(random(100, 300)));
  }
  constellations = new Star[5];
  for (int i = 0; i < constellations.length; i++) {
    constellations[i] = new Star(i * 400, int (startH));
  }

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(canvasW, canvasH, 20);
  o = createGraphics(canvasW, canvasH, P3D);

  sideRatio = canvasW/(22.0*12);
  bigSideH = sideRatio * bigSideActualH;
  smallSideH = sideRatio * smallSideActualH;
  smallGap = (bigSideH -smallSideH) / 2;

  symbols = new Star[6];
  symbolImages = new PImage[6];
  for (int i = 0; i < 6; i++) {
    symbolImages[i] = loadImage("symbols/c" + i + ".png");
    symbols[i] = new Star(i * 200 + 200, int(startH) + 170);
  }
  
  lines = new Line[10];
  for (int i = 0; i < 10; i++) {
    int x = int(i * 160 + random(50));
    lines[i] = new Line(x, 0, x, height);
  }
}