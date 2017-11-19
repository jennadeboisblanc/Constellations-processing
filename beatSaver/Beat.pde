
class Beat {
 
  int songT;
  char beatType;
  
  Beat(int t, char b) {
    songT = t;
    beatType = b;
  }
   Beat(int t, String b) {
    songT = t;
    beatType = b.charAt(0);
  }
  
  boolean isPlaying(float startT) {
    return (startT > songT && startT < songT + 200);
  }

  color getColor() {
    if (beatType == '9') return color(255, 0, 0);
    return color(0, 255, 0);
  }
}