import java.util.*;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

class GraphList {

  int graphSize;
  int currentNodeIndex = -1;
  ArrayList<Node> nodes;
  Map<Integer, List<Integer>> nodeList;


  GraphList(int num) {
    graphSize = num;
    nodes = new ArrayList<Node>();
    nodeList = new HashMap<Integer, List<Integer>>();
    for (int i = 0; i < graphSize; i++) {
      nodeList.put(i, new LinkedList<Integer>());
    }
  }


  public void setEdge(int to, int from) 
  {
    if (to > nodeList.size() || from > nodeList.size()) {
      //System.out.println("The vertices does not exists");
    } else {
      List<Integer> sls = nodeList.get(to);
      sls.add(from);
      List<Integer> dls = nodeList.get(from);
      dls.add(to);
    }
  }

  void removeEdges(int index) {
    List<Integer> adjacentNodes = nodeList.get(index);
    if (adjacentNodes != null) {
      for (int j = 0; j < adjacentNodes.size(); j++) {
        int adjNodeID = adjacentNodes.get(j);
        List<Integer> secondAdjacentNodes = nodeList.get(adjNodeID);  // list of nodes of an adjacent node (adjacent to one being removed)
        for (int k = secondAdjacentNodes.size() - 1; k >= 0; k--) {    // go through second list; if one of the items is the original index, remove it
          if (secondAdjacentNodes.get(k) == index) {
            nodeList.get(adjNodeID).remove(k);
            //println("removing " + index + " from " + k);
          }
        }
        //println(adjNodeID + " size: " + nodeList.get(adjNodeID).size());
      }
    }
    // reset node list
    nodeList.put(index, new LinkedList<Integer>());
  }

  // use this for loading graph to prevent duplicates
  void setDirectedEdge(int to, int from) {
    //println(to + " " + from);
    if (to > nodeList.size() || from > nodeList.size()) {
      //System.out.println("The vertices does not exists");
    } else {
      List<Integer> sls = nodeList.get(to);
      sls.add(from);
    }
  }

  List<Integer> getEdge(int to) {
    if (to > nodeList.size()) {
      //println("The vertices does not exists");
      return null;
    }
    return nodeList.get(to);
  }

  void display() {
    for (int v = 0; v < nodes.size(); ++v) {
      int x1, y1;
      Node n = nodes.get(v); // could get to the point where this call isn't necessary- just tmp->x, tmp->y (that x, y is saved 2x)
      n.display();
      x1 = n.getX();
      y1 = n.getY();



      //fill(255);
      //stroke(255);
      strokeWeight(2);
      nodes.get(v).display();
      // draw lines between nodes

      List<Integer> edgeList = getEdge(v);
      if (edgeList != null) {
        for (int j = 0; j < edgeList.size(); j++) {
          //println("edge " + j + " " + edgeList.get(j) + " " + edgeList.size());
          Node n2 = nodes.get(edgeList.get(j));
          line(x1, y1, n2.getX(), n2.getY());
        }
      }
    }
  }

  void displayNodes() {
    for (int i = 0; i < nodes.size(); i++) {
      nodes.get(i).display();
    }
  }
  
  void displayNodeLabels() {
     for (int i = 0; i < nodes.size(); i++) {
      nodes.get(i).displayLabel();
    }
  }

  //void displayNodes() {
  //  for (int v = 0; v < nodes.size(); ++v) {
  //    int x1, y1;
  //    Node n = nodes.get(v); // could get to the point where this call isn't necessary- just tmp->x, tmp->y (that x, y is saved 2x)
  //    n.display();
  //    x1 = n.getX();
  //    y1 = n.getY();
  //    strokeWeight(2);
  //    nodes.get(v).display();
  //  }
  //}

  void printGraph() {
    for (int v = 0; v < nodes.size(); ++v) {
      fill(255);
      // draw lines between nodes
      System.out.print(v + "->");
      List<Integer> edgeList = getEdge(v);
      if (edgeList != null) {
        for (int j = 0; j<edgeList.size(); j++) 
        {
          if (j != edgeList.size() -1) {
            System.out.print(edgeList.get(j) + " -> ");
          } else {
            System.out.print(edgeList.get(j));
            break;
          }
        }
      }
      println();
    }
  }

  void saveGraph() {
    processing.data.JSONObject json;
    json = new processing.data.JSONObject();
    json.setInt("nodeNum", nodes.size());
    saveJSONObject(json, "data/graph/graph.json");

    int h = 0;

    Iterator<Node> it = nodes.iterator();
    while (it.hasNext()) {
      Node n = it.next();
      processing.data.JSONObject json2;
      json2 = new processing.data.JSONObject();

      json2.setString("ID", n.ID);
      json2.setInt("x", n.x);
      json2.setInt("y", n.y);

      // adjacent node names
      processing.data.JSONArray adjacentNodes = new processing.data.JSONArray();      
      List<Integer> edgeList = getEdge(h);
      if (edgeList != null) {
        for (int j = 0; j < edgeList.size(); j++) 
        {
          adjacentNodes.setString(j, edgeList.get(j) + "");
        }
      }
      json2.setJSONArray("adjacentNodes", adjacentNodes);
      saveJSONObject(json2, "data/graph/" + n.ID + ".json");
      h++;
    }
    saveLines();
  }

  void createNewLines() {
    lines = new ArrayList<Line>();
    addLines();
  }

  void loadGraph() {

    processing.data.JSONObject graphJson;
    graphJson = loadJSONObject("data/graph/graph.json");
    int numNodes = graphJson.getInt("nodeNum");
    //println(numNodes);
    resetList();

    // create the nodes from JSON file
    ArrayList<Node> tempNodes = new ArrayList<Node>();
    for (int i = 0; i < numNodes; i++) {
      processing.data.JSONObject nodeJson = loadJSONObject("data/graph/" + i + ".json");
      String name = nodeJson.getString("ID");
      int x = nodeJson.getInt("x");
      int y = nodeJson.getInt("y");

      tempNodes.add(new Node(name, x, y));
    }

    // create the edges from JSON file
    for (int i = 0; i < tempNodes.size(); i++) {
      processing.data.JSONObject nodeJson = loadJSONObject("data/graph/" + i + ".json");
      processing.data.JSONArray adjNodes = nodeJson.getJSONArray("adjacentNodes");
      for (int j = 0; j < adjNodes.size(); j++) {
        setDirectedEdge(i, parseInt(adjNodes.getString(j)));
        //tempNodes.get(i).addDestination(tempNodes.get(parseInt(adjNodes.getString(j))));
      }
    }

    for (int i = 0; i < tempNodes.size(); i++) {
      nodes.add(tempNodes.get(i));
    }
    //addLines();
    loadLines();
  }

  void addNode(int mx, int my) {
    nodes.add(new Node(nodes.size() + "", mx, my));
  }

  void removeNode(int index) {
    removeEdges(index);
    nodes.get(index).hide = true;
    deleteLines(index);
    printGraph();
  }


  boolean hasCurrentNode() {
    return (currentNodeIndex > -1);
  }

  void moveCurrentNode(int dx, int dy) {
    nodes.get(currentNodeIndex).move(dx, dy);
  }

  int getClickedNode(int mx, int my) {
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i).mouseOver(mx, my)) {
        return i;
      }
    }
    return -1;
  }

  void checkEdgeClick(int mx, int my) {
    int prevNodeIndex = currentNodeIndex;
    currentNodeIndex = getClickedNode(mx, my);
    //cout << currentNodeIndex << " " << prevNodeIndex << std::endl;
    // if we actually clicked on a star to create an edge
    if (currentNodeIndex >= 0) {
      // if we've already selected a star
      if (prevNodeIndex >= 0) {
        // oops, clicked on the same star
        if (prevNodeIndex == currentNodeIndex) {
          currentNodeIndex = -1;
        }
        // clicked a new star! let's add an edge
        else {
          // add link in adjacency matrix
          setEdge(prevNodeIndex, currentNodeIndex);
          Node n2 = nodes.get(prevNodeIndex);
          Node n1 = nodes.get(currentNodeIndex);
          lines.add(new Line(n1.getX(), n1.getY(), n2.getX(), n2.getY(), prevNodeIndex, currentNodeIndex));
        }
      }
    }
  }


  void checkNodeClick(int mx, int my) {
    currentNodeIndex = getClickedNode(mx, my);
  }

  void checkDeleteNodeClick(int mx, int my) {
    currentNodeIndex = getClickedNode(mx, my);
    if (currentNodeIndex > -1) {
      removeNode(currentNodeIndex);
      currentNodeIndex = -1;
    }
  }

  int getCurrentNode() {
    //cout << currentNodeIndex << std::endl;
    return currentNodeIndex;
  }

  void setCurrentNode(int num) {
    this.currentNodeIndex = num;
  }

  void drawLineToCurrent(int x, int y) {
    stroke(255);
    if (currentNodeIndex > -1 && currentNodeIndex < nodes.size()) {
      line(nodes.get(currentNodeIndex).getX(), nodes.get(currentNodeIndex).getY(), x, y);
    }
  }

  void resetList() {
    nodes = new ArrayList<Node>();
    lines = new ArrayList<Line>();
    nodeList = new HashMap<Integer, List<Integer>>();
    for (int i = 0; i < graphSize; i++) {
      nodeList.put(i, new LinkedList<Integer>());
    }
  }



  float getAngle(int x0, int y0, int x1, int y1) {
    return atan2((y1 - y0)*1.0, (x1 - x0)*1.0);
  }

  void addLines() {
    int l = 0;
    for (int i = 0; i < nodes.size(); i++) {
      Node n = nodes.get(i);
      List<Integer> edgeList = getEdge(i);
      if (edgeList != null) {
        for (int j = 0; j < edgeList.size(); j++) 
        {
          int nextEdge = edgeList.get(j);
          if (nextEdge > i) {
            //println(i + " " + nextEdge);
            Node n2 = nodes.get(nextEdge);
            // i, nextEdge
            lines.add(new Line(n.getX(), n.getY(), n2.getX(), n2.getY(), i, nextEdge));
            l++;
          }
        }
      }
      // only add adjnodes if they have a greater id than the current node (nodes.get(i).hasAdjacent
    }
  }

  // returns the ID of the edge that is closest in distance to starting (index)
  // node; returns -1 if the current node is closer than its edges to the goal
  int getClosestNode(int index, PVector goal) {
    int closest = -1;
    Node n = nodes.get(index);
    float dis = n.getDistance(goal);
    List<Integer> edgeList = getEdge(index);
    if (edgeList != null) {
      for (int j = 0; j < edgeList.size(); j++) {
        Node n2 = nodes.get(edgeList.get(j));
        float dis2 = n2.getDistance(goal);
        if (dis2 < dis) {
          dis = dis2;
          closest = edgeList.get(j);
        }
      }
    }
    return closest;
  }


  // returns the ID of the edge that is closest in distance to starting (index)
  // node; returns -1 if the current node is closer than its edges to the goal
  int getClosestForcedNode(int index, int previous, PVector goal) {
    int closest = -1;
    float dis = 99999999;
    List<Integer> edgeList = getEdge(index);
    if (edgeList != null) {
      for (int j = 0; j < edgeList.size(); j++) {
        if (edgeList.get(j) != previous) {
          Node n2 = nodes.get(edgeList.get(j));
          float dis2 = n2.getDistance(goal);
          if (dis2 < dis) {
            dis = dis2;
            closest = edgeList.get(j);
          }
        }
      }
    }
    return closest;
  }

  ArrayList<Node> getConstellationPath(Node n, PVector goal) {
    int index = parseInt(n.ID);
    ArrayList<Node> path = new ArrayList<Node>();
    int closest = getClosestNode(index, goal);
    while (closest > -1) {
      path.add(nodes.get(closest));
      closest = getClosestNode(closest, goal);
    }
    return path;
  }

  ArrayList<Node> getConstellationPath(int index, PVector goal) {
    //int index = parseInt(n.ID);
    ArrayList<Node> path = new ArrayList<Node>();
    //ArrayList<Integer> path2 = new ArrayList<Integer>();
    int closest = getClosestNode(index, goal);
    while (closest > -1) {
      //path2.add(closest);
      path.add(nodes.get(closest));
      closest = getClosestNode(closest, goal);
    }
    return path;
  }

  ArrayList<Node> getConstellationForcedPath(int index, PVector goal) {
    ArrayList<Node> path = new ArrayList<Node>();
    path.add(nodes.get(index));
    int closest = getClosestForcedNode(index, -1, goal);
    int previous = index;
    int numJumps = 0;
    while (closest > -1 && numJumps < 4) {
      numJumps++;
      path.add(nodes.get(closest));
      int next = getClosestForcedNode(closest, previous, goal);
      previous = closest;
      closest = next;
    }
    return path;
  }

  ArrayList<Integer> getConstellationForcedIDs(int index, PVector goal) {
    ArrayList<Integer> path = new ArrayList<Integer>();
    path.add(index);
    int closest = getClosestForcedNode(index, -1, goal);
    int previous = index;
    int numJumps = 0;
    while (closest > -1 && numJumps < 4) {
      numJumps++;
      path.add(closest);
      int next = getClosestForcedNode(closest, previous, goal);
      previous = closest;
      closest = next;
    }
    return path;
  }


  void drawPathIDs(ArrayList<Integer> path) {
    for (int i = 0; i < path.size()-1; i++) {
      int p1 = path.get(i);
      int p2 = path.get(i+1);
      for (int j = 0; j < lines.size(); j++) {
        lines.get(j).displayByIDs(p1, p2);
      }
    }
  }
  void drawPathLines(ArrayList<Node> path) {
    for (int i = 0; i < path.size()-1; i++) {
      line(path.get(i).getX(), path.get(i).getY(), path.get(i+1).getX(), path.get(i+1).getY());
    }
  }

  void drawOrganicPath(int start, PVector goal) {
    ArrayList<Integer> path = getConstellationForcedIDs(start, goal);
    //drawPathLines(path);
    drawPathIDs(path);
    //int end = getClosestForcedNode(start, 0, goal);
    //drawLine(start, end);
    ellipse(nodes.get(start).getX(), nodes.get(start).getY(), 20, 20);
  }

  void drawIDLine(ArrayList<Integer> path) {
    for (int i = 0; i < path.size()-1; i++) {
      line(nodes.get(path.get(i)).getX(), nodes.get(path.get(i)).getY(), nodes.get(path.get(i+1)).getX(), nodes.get(path.get(i+1)).getY());
    }
  }

  void drawLine(int n1, int n2) {
    if (n1 >=0 && n2 >= 0) 
      line(nodes.get(n1).getX(), nodes.get(n1).getY(), nodes.get(n2).getX(), nodes.get(n2).getY());
  }

  //void setLineValues() {
  //  processing.data.JSONObject json;
  //  json = loadJSONObject("data/graph/lines.json");

  //  processing.data.JSONArray lineZs = json.getJSONArray("lineZs");
  //  processing.data.JSONArray constellationG = json.getJSONArray("constellationG");
  //  for (int j = 0; j < lines.size(); j++) {
  //    if (j >= lineZs.size()) {
  //      lines.get(j).zIndex = 0;
  //      lines.get(j).constellationG = 0;
  //    } else {
  //      lines.get(j).zIndex = lineZs.getInt(j);
  //      lines.get(j).constellationG = constellationG.getInt(j);
  //    }
  //  }
  //}

  void saveLines() {
    processing.data.JSONObject json;
    json = new processing.data.JSONObject();
    json.setInt("linesNum", lines.size());
    saveJSONObject(json, "data/graph/lines.json");

    for (int i = 0; i < lines.size(); i++) {
      processing.data.JSONObject json2;
      json2 = new processing.data.JSONObject();
      Line l = lines.get(i);
      json2.setInt("id1", l.id1);
      json2.setInt("id2", l.id2);
      json2.setInt("x1", l.getX1());
      json2.setInt("y1", l.getY1());
      json2.setInt("x2", l.getX2());
      json2.setInt("y2", l.getY2());
      json2.setInt("z", l.zIndex);
      json2.setInt("cg", l.constellationG);

      saveJSONObject(json2, "data/graph/line" + i + ".json");
    }
  }

  void loadLines() {
    processing.data.JSONObject json;
    json = loadJSONObject("data/graph/lines.json");
    int linesNum = json.getInt("linesNum");

    for (int i = 0; i < linesNum; i++) {
      processing.data.JSONObject lineJson = loadJSONObject("data/graph/line" + i + ".json");
      int id1 = lineJson.getInt("id1");
      int id2 = lineJson.getInt("id2");
      int x1 = lineJson.getInt("x1");
      int y1 = lineJson.getInt("y1");
      int x2 = lineJson.getInt("x2");
      int y2 = lineJson.getInt("y2");
      int z = lineJson.getInt("z");
      int cg = lineJson.getInt("cg");

      lines.add(new Line(x1, y1, x2, y2, id1, id2));
      lines.get(i).zIndex = z;
      lines.get(i).constellationG = cg;
    }
  }

  void saveLineValues() {
    processing.data.JSONObject json;
    json = new processing.data.JSONObject();
    processing.data.JSONArray lineZs = new processing.data.JSONArray(); 
    //processing.data.JSONArray lineXs = new processing.data.JSONArray(); 
    //processing.data.JSONArray lineYs = new processing.data.JSONArray(); 
    processing.data.JSONArray constellationG = new processing.data.JSONArray();  

    if (lines.size() == 0) {
      addLines();
    }
    for (int j = 0; j < lines.size(); j++) {
      lineZs.setInt(j, lines.get(j).zIndex);
      constellationG.setInt(j, lines.get(j).constellationG);
    }
    json.setJSONArray("lineZs", lineZs);
    json.setJSONArray("constellationG", constellationG);
    saveJSONObject(json, "data/graph/lines.json");
  }
}