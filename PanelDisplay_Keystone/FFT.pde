import ddf.minim.*;
import ddf.minim.analysis.*;

Minim       minim;
AudioPlayer myAudio;
FFT         myAudioFFT;

int         myAudioRange     = 256;
int         myNumBands       = 11;
int         myAudioMax       = 100;
int[]       bandBreaks       = {20, 50, 60, 80, 100, 150, 175, 200, 225, 255};
int[]       bands;
int[]       bandMax          = {141, 132, 265, 208, 197, 282, 214, 119, 120, 76};
int[]       fourBandsMax     = {averageBands(bandMax[0], bandMax[1], bandMax[2]), averageBands(bandMax[3], bandMax[4]), averageBands(bandMax[5], bandMax[6]), averageBands(bandMax[7], bandMax[8], bandMax[9])};

float       myAudioAmp       = 170.0;
float       myAudioIndex     = 0.2;
float       myAudioIndexAmp  = myAudioIndex;
float       myAudioIndexStep = 0.55;

float       myAudioAmp2       = 30.0;
float       myAudioIndex2     = 0.05;
float       myAudioIndexAmp2  = 0.05;
float       myAudioIndexStep2 = 0.025;

boolean     showSpectrum     = true;
boolean     transparentMode  = false;
// ************************************************************************************

int         stageMargin      = 100;
int         stageWidth       = (880) - (2*stageMargin);
int         stageHeight      = 700;

int         rectSize         = stageWidth/(bandBreaks.length);
float       rect2Size        = stageWidth/256.0;

float       xStart           = stageMargin;
float       yStart           = stageMargin;
int         xSpacing         = rectSize;
float       x2Spacing        = rect2Size;


// ************************************************************************************

String songs[] = {"deltaWaves", "cycles", "kirasu"};
int currentSong = 0;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FFT

void stop() {
  myAudio.close();
  minim.stop();  
  super.stop();
}


void initFFT() {
  minim   = new Minim(this);
  myAudio = minim.loadFile("deltaWaves.mp3");

  myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
  myAudioFFT.linAverages(myAudioRange);
  myAudioFFT.window(FFT.GAUSS);
  bands = new int[bandBreaks.length];
  //bandMax =  new int[bandBreaks.length];
}

void restartFFT(int num) {
  myAudio = minim.loadFile(songs[num] + ".mp3");
  myAudio.play();
}

void checkNextSong(int next) {
  if (currentSong != next) {
    currentSong = next;
    restartFFT(currentSong);
    updateSong();
  }
}


void updateFFT() {
  myAudioFFT.forward(myAudio.mix);

  int bandIndex = 0;
  while (bandIndex < bands.length) {
    float temp = 0;
    int startB = 0; 
    int endB = 0;
    if (bandIndex == 0) {
      startB = -1;
      endB = bandBreaks[bandIndex];
    } else if (bandIndex < bandBreaks.length) {
      startB = bandBreaks[bandIndex-1];
      endB = bandBreaks[bandIndex];
    }
    for (int j = startB+1; j <= endB; j++) {
      temp += myAudioFFT.getAvg(j);
    }
    temp /= endB - startB;
    temp *= myAudioAmp*myAudioIndexAmp;
    bands[bandIndex] = int(temp*(bandIndex+.5));

    //if (bands[bandIndex] > bandMax[bandIndex]) {
    //  bandMax[bandIndex] = bands[bandIndex];
    //}
    //if (equalizer) {
    //  fourBands[0] = bands[0];
    //  fourBands[3] = bands[bands.length -1];
    //  for (int i = 1; i < 4; i++) {
    //    fourBands[i-1] = 0;
    //    fourBands[i-1] += bands[2*i-1];
    //    fourBands[i-1] += bands[2*i];
    //    fourBands[i-1] /= 2;
    //}
    bandIndex++;
  }
  myAudioIndexAmp = myAudioIndex;
  myAudioIndexAmp2 = myAudioIndex2;
}


int averageBands(int v1, int v2, int v3) {
  return (v1 + v2 + v3) /3;
}

int averageBands(int v1, int v2) {
  return (v1 + v2) / 2;
}



/////////////////////////////////////////////////

ArrayList<Beat> beats;
int currentBeat = 0;
int[] currentBeats = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int[] oldBeats = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

void initBeat() {
  beats = new ArrayList<Beat>();
  loadBeats();
}

void updateBeats() {
  if (currentBeat < beats.size()) {
    for (int i = 0; i < currentBeats.length; i++) {
      if (beats.get(currentBeat).hasStarted(myAudio.position())) {
        if(beats.get(currentBeat).beatType < 10) currentBeats[beats.get(currentBeat).beatType]++;
        currentBeat++;
        if (currentBeat >= beats.size()) return;
      }
    }
  }
}

class Beat {

  int songT;
  int beatType;

  Beat(int t, char b) {
    songT = t;
    beatType = parseInt(b);
  }
  Beat(int t, String b) {
    songT = t;
    beatType = parseInt(b);
  }

  boolean isPlaying(float startT) {
    return (startT > songT && startT < songT + 100);
  }

  boolean hasStarted(float startT) {
    return startT > songT;
  }

  color getColor() {
    if (beatType == '9') return color(255, 0, 0);
    return color(0, 255, 0);
  }
}



void loadBeats() {
  processing.data.JSONObject beatsJson;
  beatsJson = loadJSONObject("data/beats.json");
  int numBeats = beatsJson.getInt("numBeats");
  println(numBeats);
  //resetBeats();

  processing.data.JSONArray beatsArray = beatsJson.getJSONArray("beatList");
  for (int i = 0; i < numBeats; i++) {
    processing.data.JSONObject b = beatsArray.getJSONObject(i);
    String beatType = b.getString("beatType");
    int t = b.getInt("time");
    beats.add(new Beat(t, beatType));
  }
}