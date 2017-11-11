class Scene {

  float startPoint;
  int visualM;
  int kinectM;
  int panelM;

  Scene(float sp,int vm, int km, int pm) {
    startPoint = sp;
    visualM = vm;
    kinectM = km;
    panelM = pm;
  }

  boolean hasStarted(float startT) {
    return startT > startPoint;
  }

  void setModes() {
    visualMode = visualM;
    kinectMode = kinectM;
    panelMode = panelM;
    sendPanel();
  }

  void sendPanel() {
    byte[] sendArray = {byte(visualM), byte(kinectM), byte(panelM)};
    //myServer.write(sendArray);
  }

  void setKinectMode() {
  }
}