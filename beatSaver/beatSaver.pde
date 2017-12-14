

//////////////////////////////////////////////////////////////////////////////////////////////////
boolean ADD_ON = false;
String file = "song";

import java.util.*;
import java.util.LinkedList;
import java.util.List;


boolean playing = false;
int currentBeat = 0;


ArrayList<Beat> beats;

void setup() {
  size(800, 500);
  beats = new ArrayList<Beat>();
  
  initFFT();
  
  if (ADD_ON) loadBeats();
  
  myAudio.play();
}

void draw() {
  background(0);
  updateFFT();
  if (millis() > 2000 && !playing) {
    //myAudio.play();
  }
  
  if (ADD_ON) playBeats();
  drawFFT();
}

void playBeats() {
  if (currentBeat < beats.size()) {
    if (beats.get(currentBeat).isPlaying(myAudio.position())) {
      fill(beats.get(currentBeat).getColor());
      rect(width/2 - 50, height/2 - 50, 100, 100);
      currentBeat++;
    }
  }
}

int getTime() {
  //int songMinutes = myAudio.position() / 1000 / 60;
  //int songSeconds = myAudio.position() / 1000 % 60;
  //float songReading = songMinutes + (songSeconds / 100.0);
  return myAudio.position();
}

void keyPressed() {
  if (key == 'p') {
    bubbleSort();
    saveToFile();
  } else beats.add(new Beat(getTime(), key));
}


void sortByTime() {
  bubbleSort();
}

void bubbleSort() {
  int n = beats.size();

  for (int i=0; i < n; i++) {
    for (int j=1; j < (n-i); j++) {

      if (beats.get(j-1).songT > beats.get(j).songT) {
        //swap the elements!
        Collections.swap(beats, j, j-1);
      }
    }
  }
}

void saveToFile() {
  processing.data.JSONObject json;
  json = new processing.data.JSONObject();
  json.setInt("numBeats", beats.size());
  saveJSONObject(json, "data/beats_" + file + ".json");

  processing.data.JSONArray beatList = new processing.data.JSONArray();      

  for (int i = 0; i < beats.size(); i++) {
    processing.data.JSONObject beatJSON = new processing.data.JSONObject();
    Beat b = beats.get(i);
    beatJSON.setInt("time", b.songT);
    beatJSON.setString("beatType", str(b.beatType));

    beatList.setJSONObject(i, beatJSON);
  }

  json.setJSONArray("beatList", beatList);


  saveJSONObject(json, "data/beats_" + file + ".json");
}


void loadBeats() {
  processing.data.JSONObject beatsJson;
  beatsJson = loadJSONObject("data/beats_" + file + ".json");
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

void resetBeats() {
  beats = new ArrayList<Beat>();
}