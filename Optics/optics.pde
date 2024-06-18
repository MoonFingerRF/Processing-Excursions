/*
Author: Ashley Robles
Year: 2018

This code simulates an entire optical table using fourier optics. In this
example, a schlieren imaging setup is simulated for a gaussian phase
perturbation along the x axis. A light source illuminates the phase perturbation,
then that light is reflected through a parabolic reflector. The light at the
focal point of the reflector is then cut by a knife edge to cause phase
perturbations to be visible as amplitude variations. Then the image plane is
placed one more focal length further back to obtain the schlieren image.

The optical components and propagation through free space are all modeled as
filters on a complex field. The final image is obtained by propagating the light
source through these filters, and the amplitude squared ends up as the detected image.

*/

int N = 512;

int width = N*2;
int height = N + 128;

OTable table = new OTable(N, 8, width/2, 64, width, 128); //optical table 8 meters in length

complex heat[][] = new complex[N][N]; //phase shifts caused by changes in desnity;

float w = 0.015;

float reflectorD = 0.014; //reflector aperture

float lambda = 0.0000005; //cyan

float light_r = 0.00002;

float phasefunc(double x)  {
  return exp(-200000.0*(float)sq(x));
}

PImage phaseImage;

void setup()  {
  size(width, height);
  randomSeed(0);
  noiseSeed(1);
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      double x = (((double)n/N) - 0.5)*w;
      double y = (((double)m/N) - 0.5)*w;
      heat[n][m] = new complex(-4*PI*phasefunc(x));  //generate phase distortion
      if (sq(x)+sq(y) > sq(reflectorD/2))
        heat[n][m] = new complex();
    }
  }
  complex tmp[][] = new complex[N][N]; //temporary phase shifter
  tmp = sphereReflect(N, w, lambda, reflectorD, 1.08);
  Filter2D(tmp, heat, N);
  Filter2D(tmp, heat, N); //apply heat twice, once for pre reflection, again for post reflection
  table.add(new OElement(0, N, 128, tmp));
  complex tmp2[][] = new complex[N][N]; //temporary phase shifter
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      tmp2[n][m] = new complex(0);
    }
  }
  knifeEdgeX(tmp2);
  table.add(new OElement(1.08, N, 32, tmp2));
  complex tmp3[][] = sphereReflect(N, w, lambda, reflectorD, 1.5); //imaging lens
  table.add(new OElement(1.83, N, 64, tmp3)); //lens 1f away from knife edge
  table.addS(new OSource(-1.08, lambda/4.0));
  table.addP(new OPlane(2.58)); //image plane slightly behind the 1f focal length of the imaging lens to make a sharp image of the reflector
  table.sort();
}

void draw()  {
  background(64);
  table.hover(mouseX, mouseY);
  table.draw();
  PImage heatim = complexImage(heat, N);
  image(heatim, 0, 128, N, N);
  PImage propagatedim = complexImageIntensity(table.getImage(0, w, lambda), N);
  image(propagatedim, N, 128, N, N);
  if(frameCount == 1)
    save("schl_img.png");
}

void mousePressed()  {
  table.grab(mouseX, mouseY);
}

void mouseDragged()  {
  table.move(mouseX, mouseY);
  table.sort();
}

void mouseReleased()  {
  table.resetGrab();
}
