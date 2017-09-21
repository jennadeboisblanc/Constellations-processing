void drawConstellationFirst() {
  if (graphL.nodes.size() > 20) {
    stroke(255, 0, 0);
    fill(255, 0, 0);
    ArrayList<Node> bodyNodes = new ArrayList<Node>(); 

    for (int j = 0; j < 5; j++) {
      if (j == 0) bodyNodes = graphL.getConstellationPath(graphL.nodes.get(11), bodyPoints[0].next);
      else {
        if (bodyNodes.size() > 0) bodyNodes = graphL.getConstellationPath(bodyNodes.get(bodyNodes.size()-1), bodyPoints[j].next);
      }
      for (int i = 0; i < bodyNodes.size()-1; i++) {
        line(bodyNodes.get(i).getX(), bodyNodes.get(i).getY(), bodyNodes.get(i+1).getX(), bodyNodes.get(i+1).getY());
      }
    }
  }
}