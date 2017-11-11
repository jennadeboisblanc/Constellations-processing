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
        for (int j = 0; j < edgeList.size(); j++) 
        {
          Node n2 = nodes.get(edgeList.get(j));
          line(x1, y1, n2.getX(), n2.getY());
        }
      }
    }
  }

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
    saveJSONObject(json, "data/graph.json");

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
      saveJSONObject(json2, "data/" + n.ID + ".json");
      h++;
    }
    saveLineValues();
  }

  void createNewLines() {
    lines = new ArrayList<Line>();
    addLines();
  }

  void loadGraph() {

    processing.data.JSONObject graphJson;
    graphJson = loadJSONObject("data/graph.json");
    int numNodes = graphJson.getInt("nodeNum");
    //println(numNodes);
    resetList();

    // create the nodes from JSON file
    ArrayList<Node> tempNodes = new ArrayList<Node>();
    for (int i = 0; i < numNodes; i++) {
      processing.data.JSONObject nodeJson = loadJSONObject("data/" + i + ".json");
      String name = nodeJson.getString("ID");
      int x = nodeJson.getInt("x");
      int y = nodeJson.getInt("y");

      tempNodes.add(new Node(name, x, y));
    }

    // create the edges from JSON file
    for (int i = 0; i < tempNodes.size(); i++) {
      processing.data.JSONObject nodeJson = loadJSONObject("data/" + i + ".json");
      processing.data.JSONArray adjNodes = nodeJson.getJSONArray("adjacentNodes");
      for (int j = 0; j < adjNodes.size(); j++) {
        setDirectedEdge(i, parseInt(adjNodes.getString(j)));
        //tempNodes.get(i).addDestination(tempNodes.get(parseInt(adjNodes.getString(j))));
      }
    }

    for (int i = 0; i < tempNodes.size(); i++) {
      nodes.add(tempNodes.get(i));
    }
    addLines();
    setLineValues();
  }

  void addNode(int mx, int my) {
    nodes.add(new Node(nodes.size() + "", mx, my));
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
        }
      }
    }
  }


  void checkNodeClick(int mx, int my) {
    currentNodeIndex = getClickedNode(mx, my);
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
            lines.add(new Line(n.getX(), n.getY(), n2.getX(), n2.getY(), l));
            l++;
          }
        }
      }
      // only add adjnodes if they have a greater id than the current node (nodes.get(i).hasAdjacent
    }
  }

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


  void drawLine(int[] path) {
    for (int i = 0; i < path.length-1; i++) {
      line(nodes.get(path[i]).getX(), nodes.get(path[i]).getY(), nodes.get(path[i+1]).getX(), nodes.get(path[i+1]).getY());
    }
  }

  void drawLine(int n1, int n2) {
    if (n1 >=0 && n2 >= 0) 
      line(nodes.get(n1).getX(), nodes.get(n1).getY(), nodes.get(n2).getX(), nodes.get(n2).getY());
  }

  void setLineValues() {
    processing.data.JSONObject json;
    json = loadJSONObject("data/lines.json");

    processing.data.JSONArray lineZs = json.getJSONArray("lineZs");
    processing.data.JSONArray constellationG = json.getJSONArray("constellationG");
    for (int j = 0; j < lines.size(); j++) {
      if (j >= lineZs.size()) {
        lines.get(j).zIndex = 0;
        lines.get(j).constellationG = 0;
      } else {
        lines.get(j).zIndex = lineZs.getInt(j);
        lines.get(j).constellationG = constellationG.getInt(j);
      }
    }
  }


  void saveLineValues() {
    processing.data.JSONObject json;
    json = new processing.data.JSONObject();
    processing.data.JSONArray lineZs = new processing.data.JSONArray();  
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
    saveJSONObject(json, "data/lines.json");
  }
}