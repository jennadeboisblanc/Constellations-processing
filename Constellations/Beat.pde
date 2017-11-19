
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
}