
class BlackShape {

  ArrayList<PVector> points;
  String type;
  boolean hidden = false;

  BlackShape(String type) {
    points = new ArrayList<PVector>();
    this.type = type;
  }

  void addPoint(PVector p) {
    points.add(p);
  }

  void display() {
    if (!hidden) {
      beginShape();
      for (int i =0; i < points.size(); i++) {
        vertex(points.get(i).x, points.get(i).y);
      }
      endShape();
      if (movingOn) {
        fill(0, 255, 0);
        if (type.equals("top")) {
          
          ellipse(points.get(2).x, points.get(2).y, 40, 40);
          ellipse(points.get(3).x, points.get(3).y, 40, 40);
        } else if (type.equals("left")) {
          ellipse(points.get(1).x, points.get(1).y, 40, 40);
          ellipse(points.get(2).x, points.get(2).y, 40, 40);
        } else if (type.equals("right")) {
          ellipse(points.get(0).x, points.get(0).y, 40, 40);
          ellipse(points.get(3).x, points.get(3).y, 40, 40);
        } else {
          ellipse(points.get(1).x, points.get(1).y, 40, 40);
          ellipse(points.get(0).x, points.get(0).y, 40, 40);
        }
      }
    }
  }

  void mouseOver() {
    for (int i =0; i < points.size(); i++) {
      float d = dist(points.get(i).x, points.get(i).y, mouseX, mouseY);
      if (d < 40) {
        movingPoint = points.get(i);
        draggingOn = true;
        return;
      }
    }
  }

  void saveShape() {
    processing.data.JSONObject json;

    json = new processing.data.JSONObject();
    json.setString("type", type);
    if (type.equals("top")) {
      json.setFloat("p1x", points.get(2).x);
      json.setFloat("p1y", points.get(2).y);
      json.setFloat("p2x", points.get(3).x);
      json.setFloat("p2y", points.get(3).y);
    } else if (type.equals("left")) {
      json.setFloat("p1x", points.get(1).x);
      json.setFloat("p1y", points.get(1).y);
      json.setFloat("p2x", points.get(3).x);
      json.setFloat("p2y", points.get(3).y);
    } else if (type.equals("right")) {
      json.setFloat("p1x", points.get(0).x);
      json.setFloat("p1y", points.get(0).y);
      json.setFloat("p2x", points.get(3).x);
      json.setFloat("p2y", points.get(3).y);
    } else {
      json.setFloat("p1x", points.get(0).x);
      json.setFloat("p1y", points.get(0).y);
      json.setFloat("p2x", points.get(1).x);
      json.setFloat("p2y", points.get(1).y);
    }
    saveJSONObject(json, "data/shapes/" + type + ".json");
  }

  void loadshape() {
    processing.data.JSONObject json;
    json = loadJSONObject("data/shapes/" + type + ".json");

    float x1 = json.getFloat("p1x");
    float y1 = json.getFloat("p1y");
    float x2 = json.getFloat("p2x");
    float y2 = json.getFloat("p2y");

    if (type.equals("top")) {
      points.set(2, new PVector(x1, y1));
      points.set(3, new PVector(x2, y2));
    } else if (type.equals("left")) {
      points.set(1, new PVector(x1, y1));
      points.set(3, new PVector(x2, y2));
    } else if (type.equals("right")) {
      points.set(0, new PVector(x1, y1));
      points.set(3, new PVector(x2, y2));
    } else {
      points.set(0, new PVector(x1, y1));
      points.set(1, new PVector(x2, y2));
    }
  }
}

void displayBlackShapes() {
  if (movingOn) {
    stroke(255);
    fill(255, 0, 0);
  } else {
    fill(0);
    stroke(0);
  }
  topS.display();
  bottomS.display();
  leftS.display();
  rightS.display();
}

void checkPoints() {
  draggingOn = false;
  topS.mouseOver();
  bottomS.mouseOver();
  leftS.mouseOver();
  rightS.mouseOver();
}

void saveBlackShapes() {
  rightS.saveShape();
  topS.saveShape();
  bottomS.saveShape();
  leftS.saveShape();
}

void loadBlackShapes() {
  rightS.loadshape();
  topS.loadshape();
  bottomS.loadshape();
  leftS.loadshape();
}

void dragPoint() {
  if (movingOn) {
    if (draggingOn) {
      movingPoint.x = mouseX;
      movingPoint.y = mouseY;
    }
  }
}

void initBlackShapes() {
  topS = new BlackShape("top");
  topS.addPoint(new PVector(0, 0));
  topS.addPoint(new PVector(width, 0));
  topS.addPoint(new PVector(width, 100));
  topS.addPoint(new PVector(0, 100));

  bottomS = new BlackShape("bottom");
  bottomS.addPoint(new PVector(0, height - 100));
  bottomS.addPoint(new PVector(width, height - 100));
  bottomS.addPoint(new PVector(width, height));
  bottomS.addPoint(new PVector(0, height));

  leftS = new BlackShape("left");
  leftS.addPoint(new PVector(0, 0));
  leftS.addPoint(new PVector(100, 150));
  leftS.addPoint(new PVector(100, height-150));
  leftS.addPoint(new PVector(0, height));

  rightS = new BlackShape("right");
  rightS.addPoint(new PVector(width-100, 150));
  rightS.addPoint(new PVector(width, 0));
  rightS.addPoint(new PVector(width, height));
  rightS.addPoint(new PVector(width-100, height-150));
}