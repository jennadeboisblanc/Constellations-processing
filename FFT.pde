
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FFT

void stop() {
  myAudio.close();
  minim.stop();  
  super.stop();
}

// modified from Adafruit Industries Neopixel Library
color Wheel(int WheelPos) {
  WheelPos = 255 - WheelPos;
  if (WheelPos < 85) {
    return color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else if (WheelPos < 170) {
    WheelPos -= 85;
    return color(0, WheelPos * 3, 255 - WheelPos * 3);
  } else {
    WheelPos -= 170;
    return color(WheelPos * 3, 255 - WheelPos * 3, 0);
  }
}  

void initFFT() {
  minim   = new Minim(this);
  myAudio = minim.loadFile("song.wav");
  myAudio.play();

  myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
  myAudioFFT.linAverages(myAudioRange);
  myAudioFFT.window(FFT.GAUSS);
  bands = new int[bandBreaks.length];
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
    bandIndex++;
  }
  myAudioIndexAmp = myAudioIndex;
  myAudioIndexAmp2 = myAudioIndex2;
}

void drawFFT() {
  int bandIndex = 0;
  while (bandIndex < bandBreaks.length) {
    fill(255, 5);
    if (!transparentMode) fill (Wheel(int(bandIndex*(255.0/bandBreaks.length))));
    else fill (Wheel(int(bandIndex*(255.0/bandBreaks.length))), 5);
    rect( xStart + (bandIndex*xSpacing), yStart+200, rectSize, bands[bandIndex]);
    bandIndex++;
  }

  //stroke(#FF3300); noFill();
  //line(stageMargin, stageMargin+myAudioMax+200, 880-stageMargin, stageMargin+myAudioMax+200);

  //if(mouseX > stageMargin && mouseX < stageWidth+stageMargin) {
  //  stroke(0);
  //  fill(0);
  //  text((int)map(mouseX, stageMargin, stageWidth+stageMargin, 0, 256), mouseX, mouseY);
  //}
}