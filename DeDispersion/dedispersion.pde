/*
Author: Ashley Robles
Year: 2022

Dedispersion is a data analysis technique used to detect fast radio bursts.
The amount of dispersion in the signal correlates to the amount of space the signal
had to pass through to get to the detector. This technique will be useful for the
future of radio astronomy. Developing a faster method of performing this technique
is crucial as this implementation has a complexity of N^3.
*/

int width = 1024;
int height = 1024;

Matrix mat, dedisp;

void setup() {
  size(width, height);
  
  mat = new Matrix("pulse.csv"); //Import example data of a fast radio burst detection.
  
  dedisp = slowDM(mat, 0.0, 2000.0, 200, 1500.0, 1200.0, 0.001*mat.N);
  
  image(dedisp.toSTDImage(), 0, 0, width, height/2);
  image(mat.toImage(), 0, height/2, width, height/2);
}
