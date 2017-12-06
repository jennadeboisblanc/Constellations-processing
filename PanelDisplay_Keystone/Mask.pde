class Mask {

  PVector [] points;
  int numPoints = 4;
  boolean [] isMoving;

  Mask() {
    points = new PVector[4];
    isMoving = new boolean[4];
    load();
    float h = points[1].y - points[0].y;
    float w = points[3].x - points[0].x;
  }

  void save() {
    processing.data.JSONObject json;
    json = new processing.data.JSONObject();

    json.setFloat("x0", points[0].x);
    json.setFloat("y0", points[0].y);
    json.setFloat("x1", points[1].x);
    json.setFloat("y1", points[1].y);
    json.setFloat("x2", points[2].x);
    json.setFloat("y2", points[2].y);
    json.setFloat("x3", points[3].x);
    json.setFloat("y3", points[3].y);

    saveJSONObject(json, "data/mask4.json");
  }

  void load() {
    processing.data.JSONObject json;
    json = loadJSONObject("data/mask4.json");

    //JSONObject sty = json.getJSONObject("points");

    float x = json.getFloat("x0");
    float y = json.getFloat("y0");
    points[0] = new PVector(x, y);

    x = json.getInt("x1");
    y = json.getInt("y1");
    points[1] = new PVector(x, y);

    x = json.getInt("x2");
    y = json.getInt("y2");
    points[2] = new PVector(x, y);

    x = json.getInt("x3");
    y = json.getInt("y3");
    points[3] = new PVector(x, y);
  }

  void display() {
    noStroke();
    fill(0);
    rectMode(CORNER);
    pushMatrix();
    translate(0, 0, 3);
    rect(0, 0, points[0].x, points[0].y);
    rect(0, points[1].y, points[1].x, height-points[1].y);
    rect(points[2].x, points[2].y, width-points[2].x, height-points[2].y);
    rect(points[3].x, 0, width-points[3].x, points[3].y);

    quad(points[0].x, 0, points[0].x, points[0].y, points[3].x, points[3].y, points[3].x, 0);
    quad(points[3].x, points[3].y, points[2].x, points[2].y, width, points[2].y, width, points[3].y);
    quad(points[1].x, points[1].y, points[1].x, height, points[2].x, height, points[2].x, points[2].y);
    quad(0, points[0].y, 0, points[1].y, points[1].x, points[1].y, points[0].x, points[0].y);

    if (movingMaskMode) {
      for (int i = 0; i < points.length; i++) {
        fill(255, 0, 0);
        ellipse(points[i].x, points[i].y, 50, 50);
      }
    }
    popMatrix();
    rectMode(CENTER);
   checkMoving();
  }
  
  void checkMoving() {
    for (int i = 0; i < points.length; i++) {
      if (isMoving[i]) {
        points[i].x = mouseX;
        points[i].y = mouseY;
      }
    }
  }

  int checkPoints() {
    for (int i = 0; i < points.length; i++) {
      if (dist(mouseX, mouseY, points[i].x, points[i].y) < 50) {
        isMoving[i] = true;
        return i;
      }
    }
    return -1;
  }

  void reset() {
    for (int i = 0; i < points.length; i++) {
      isMoving[i] = false;
    }
  }
}