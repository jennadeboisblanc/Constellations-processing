class BlackShape {
  
 ArrayList<PVector> points;
 
 BlackShape() {
   points = new ArrayList<PVector>();
 }
 
 void addPoint(PVector p) {
   points.add(p);
 }
 
 void display() {
   fill(0);
   beginShape();
   for (int i =0; i < points.size(); i++) {
     vertex(points.get(i).x, points.get(i).y);
   }
   endShape();
 }
}