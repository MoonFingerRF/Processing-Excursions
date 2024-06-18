class OTable {
  ArrayList<OElement> elements;
  ArrayList<OSource> sources;
  ArrayList<OPlane> planes;
  int res, eGrabbed = -1, sGrabbed = -1, pGrabbed = -1;
  float tableY, tableX, tableW, tableH; //table size and position on screen
  float tableL;//table length in meters
  OTable(int res, float L, float xx, float yy, float ww, float hh) {
    tableX = xx;
    tableY = yy;
    tableW = ww;
    tableH = hh;
    tableL = L;
    this.res = res;
    elements = new ArrayList<OElement>();
    sources = new ArrayList<OSource>();
    planes = new ArrayList<OPlane>();
  }
  void add(OElement a) {
    elements.add(a);
  }
  void addS(OSource a) {
    sources.add(a);
  }
  void addP(OPlane a) {
    planes.add(a);
  }
  void grab(float x_, float y_) {
    float y = y_ - tableY;
    float x = x_ - tableX;
    boolean found = false;
    for (int n = 0; n < elements.size (); n++) {
      if (elements.get(n).grab(tableW/tableL, x, y)) {
        eGrabbed = n;
        found = true;
        break;
      }
    }
    if (!found) {
      for (int n = 0; n < sources.size (); n++) {
        if (sources.get(n).grab(tableW/tableL, x, y)) {
          sGrabbed = n;
          found = true;
          break;
        }
      }
    }
    if (!found) {
      for (int n = 0; n < planes.size (); n++) {
        if (planes.get(n).grab(tableW/tableL, x, y)) {
          pGrabbed = n;
          found = true;
          break;
        }
      }
    }
  }
  void resetGrab() {
    eGrabbed = -1;
    sGrabbed = -1;
    pGrabbed = -1;
  }
  void move(float x_, float y_) {
    float y = y_ - tableY;
    float x = x_ - tableX;
    if (eGrabbed >= 0) {
      elements.get(eGrabbed).move(tableW/tableL, x, y);
    } else if (sGrabbed >= 0) {
      sources.get(sGrabbed).move(tableW/tableL, x, y);
    } else if (pGrabbed >= 0) {
      planes.get(pGrabbed).move(tableW/tableL, x, y);
    }
  }
  void hover(float x_, float y_) {
    float y = y_ - tableY;
    float x = x_ - tableX;
    boolean found = false;
    for (int n = 0; n < elements.size (); n++) {
      if (elements.get(n).hover(tableW/tableL, x, y)) {
        found = true;
        break;
      }
    }
    if (!found) {
      for (int n = 0; n < sources.size (); n++) {
        if (sources.get(n).hover(tableW/tableL, x, y)) {
          found = true;
          break;
        }
      }
    }
    if (!found) {
      for (int n = 0; n < planes.size (); n++) {
        if (planes.get(n).hover(tableW/tableL, x, y)) {
          found = true;
          break;
        }
      }
    }
  }
  void sort() {
    for (int n = 0; n < elements.size (); n++) {
      float z1 = elements.get(n).z;
      float z2 = z1;
      int m2 = n;
      for (int m = n+1; m < elements.size (); m++) {
        if (elements.get(m).z < z2) {
          z2 = elements.get(m).z;
          m2 = m;
        }
      }
      if (n != m2) {
        OElement tmp = elements.get(n);
        elements.set(n, elements.get(m2));
        elements.set(m2, tmp);
        if (eGrabbed == n) {
          eGrabbed = m2;
        } else if (eGrabbed == m2) {
          eGrabbed = n;
        }
      }
    }
    for (int n = 0; n < sources.size (); n++) {
      if (sources.get(n).z < elements.get(0).z) {
        sources.get(n).n = -1;
      } 
      else if (sources.get(n).z > elements.get(elements.size()-1).z) {
        sources.get(n).n = elements.size()-1;
      } 
      else {
        for (int m = 0; m < elements.size ()-1; m++) {
          if(elements.get(m).z < sources.get(n).z && elements.get(m+1).z > sources.get(n).z)  {
            sources.get(n).n = m;
          }
        }
      }
    }
    for (int n = 0; n < planes.size (); n++) {
      if (planes.get(n).z < elements.get(0).z) {
        planes.get(n).n = -1;
      } 
      else if (planes.get(n).z > elements.get(elements.size()-1).z) {
        planes.get(n).n = elements.size()-1;
      } 
      else {
        for (int m = 0; m < elements.size ()-1; m++) {
          if(elements.get(m).z < planes.get(n).z && elements.get(m+1).z > planes.get(n).z)  {
            planes.get(n).n = m;
          }
        }
      }
    }
  }
  complex[][] getImage(int n, float w, float lambda) { //get image from plane n
    complex out[][] = new complex[res][res];
    for (int i = 0; i < res; i++) {
      for (int j = 0; j < res; j++) {
        out[i][j] = new complex();
      }
    }
    int n1 = planes.get(n).n;
    for (int m = 0; m < sources.size (); m++) {
      int n2 = sources.get(m).n;
      if(n1 > n2)  {
        complex tmp[][] = sources.get(m).propagateSource(res, w, lambda, elements.get(n2+1).z);
        Filter2D(tmp, elements.get(n2+1).image, res);
        for(int o = n2+2; o <= n1; o++)  {
          tmp = diffractor(tmp, res, lambda, w, elements.get(o).z - elements.get(o-1).z);
          Filter2D(tmp, elements.get(o).image, res);
        }
        tmp = diffractor(tmp, res, lambda, w, planes.get(n).z - elements.get(n1).z);
        Add2D(out, tmp, res);
      }
      if(n2 > n1)  {
        //for now the source always has to be before the imaging plane
      }
      if(n1 == n2)  {
        complex tmp[][] = sources.get(m).propagateSource(res, w, lambda, planes.get(n).z);
        Add2D(out, tmp, res);
      }
    }
    return out;
  }
  void draw() {
    pushMatrix();
    translate(tableX, tableY);
    for (int n = elements.size () - 1; n >= 0; n--) {
      elements.get(n).draw(tableW/tableL);
    }
    for (int n = sources.size () - 1; n >= 0; n--) {
      sources.get(n).draw(tableW/tableL);
    }
    for (int n = planes.size () - 1; n >= 0; n--) {
      planes.get(n).draw(tableW/tableL);
    }
    popMatrix();
  }
}

class OElement {
  float z; //table location in meters
  boolean hovering, grabbed;
  int w = 16, h = 128; //width/height on screen
  complex image[][]; //holds the E field phasors
  OElement(float z, int res, int h, complex data[][]) {
    this.h = h;
    this.z = z;
    image = data;
  }
  boolean hover(float conv, float x, float y) { //all coordinates are from the top left corner, positive towards the bottom right
    if (abs(x-(conv*z)) < w/2.0 && abs(y) < h/2.0) {
      hovering = true;
      return true;
    }
    return false;
  }
  boolean grab(float conv, float x, float y) { //conv converts meters to pixels
    if (abs(x-(conv*z)) < w/2.0 && abs(y) < h/2.0) {
      hovering = true;
      return true;
    }
    return false;
  }
  void move(float conv, float x, float y) {
    grabbed = true;
    z = x/conv;
  }
  void draw(float conv) {
    stroke(0, 0, 0, 128);
    fill(64, 200, 64, 128);
    if (hovering) {
      fill(190, 200, 64, 128);
    }
    rectMode(CENTER);
    rect(z*conv, 0, w, h);
    stroke(0);
    line(z*conv, -h/2.0, z*conv, h/2.0);
    grabbed = false;
    hovering = false;
  }
}

class OSource {
  float z;
  int n;
  boolean hovering, grabbed, moved;
  int diam = 32; //width/height on screen
  float intensity;
  OSource(float z, float intensity) {
    this.z = z;
    this.intensity = intensity;
  }
  boolean hover(float conv, float x, float y) { //all coordinates are from the top left corner, positive towards the bottom right
    if (sq(x-(conv*z)) + sq(y) < sq(diam/2.0)) {
      hovering = true;
      return true;
    }
    return false;
  }
  boolean grab(float conv, float x, float y) {
    if (sq(x-(conv*z)) + sq(y) < sq(diam/2.0)) {
      hovering = true;
      return true;
    }
    return false;
  }
  void move(float conv, float x, float y) {
    grabbed = true;
    moved = true;
    z = x/conv;
  }
  complex[][] propagateSource(int N, float w, float lambda, float z_) {
    return pointSource(N, w, lambda, z_ - z, intensity);
  }
  void draw(float conv) {
    ellipseMode(CENTER);
    stroke(0, 0, 0, 128);
    fill(64, 64, 200, 128);
    if (hovering) {
      fill(190, 200, 64, 128);
    }
    ellipse(z*conv, 0, diam, diam);
    stroke(0);
    line(z*conv, -diam/2.0, z*conv, diam/2.0);
    grabbed = false;
    hovering = false;
    moved = false;
  }
}

class OPlane {
  float z; //table location in meters
  int n;
  boolean hovering, grabbed;
  int w = 16, h = 128; //width/height on screen
  OPlane(float z) {
    this.z = z;
  }
  boolean hover(float conv, float x, float y) { //all coordinates are from the top left corner, positive towards the bottom right
    if (abs(x-(conv*z)) < w/2.0 && abs(y) < h/2.0) {
      hovering = true;
      return true;
    }
    return false;
  }
  boolean grab(float conv, float x, float y) { //conv converts meters to pixels
    if (abs(x-(conv*z)) < w/2.0 && abs(y) < h/2.0) {
      hovering = true;
      return true;
    }
    return false;
  }
  void move(float conv, float x, float y) {
    grabbed = true;
    z = x/conv;
  }
  void draw(float conv) {
    stroke(0, 0, 0, 128);
    fill(200, 64, 64, 128);
    if (hovering) {
      fill(190, 200, 64, 128);
    }
    rectMode(CENTER);
    rect(z*conv, 0, w, h);
    stroke(0);
    line(z*conv, -h/2.0, z*conv, h/2.0);
    grabbed = false;
    hovering = false;
  }
}

