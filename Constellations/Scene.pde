class Scene {

  float startPoint;
  int visualM;
  int kinectM;
  PanelMode panelM;

  Scene(float sp,int vm, int km, PanelMode pm) {
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
    println(visualMode, kinectMode, panelMode);
  }

  void setKinectMode() {
  }
}