class complex {
  float r, i;
  complex() {
    r = 0;
    i = 0;
  }
  complex(float r, float i) {
    this.r = r;
    this.i = i;
  }
  complex(float w) {
    this.r = cos(w);
    this.i = sin(w);
  }
  complex(double w) {
    this.r = (float)Math.cos(w);
    this.i = (float)Math.sin(w);
  }
  complex add(complex in) {
    complex out = new complex();
    out.r = r+in.r;
    out.i = i+in.i;
    return out;
  }
  complex sub(complex in) {
    complex out = new complex();
    out.r = r-in.r;
    out.i = i-in.i;
    return out;
  }
  complex mul(complex in) {
    complex out = new complex();
    out.r = r*in.r - i*in.i;
    out.i = r*in.i + i*in.r;
    return out;
  }
  complex mul(float in) {
    return new complex(r*in, i*in);
  }
  complex div(complex in) {
    return mul(in.conjugate()).div(in.mag2());
  }
  complex div(float in) {
    return new complex(r/in, i/in);
  }
  complex conjugate() {
    return new complex(r, -i);
  }
  float mag() {
    return sqrt(sq(r)+sq(i));
  }
  float mag2() {
    return sq(r)+sq(i);
  }
  float arg() {
    return atan2(i, r);
  }
}

int bitLocation(int N) {
  for (int n = 0; n < 32; n++) {
    if (N>>n == 1)
      return n;
  }
  return 0;
}

int bitReverse(int in, int N) {
  int out = 0;
  for (int n = 0; n < N; n++) {
    out |= ((in>>n)&1)<<(N-n-1);
  }
  return out;
}

complex[] FFT(complex data[], int N) {
  complex[] out = new complex[N];
  int NN = bitLocation(N);
  for (int n = 0; n < N; n++) {
    out[n] = data[bitReverse(n, NN)];
  }
  int jump = 1;
  complex even = new complex();
  complex odd = new complex();
  for (int o = 0; o < NN; o++) {
    complex theta = new complex(1, 0);
    complex phi = new complex(cos(PI/float(jump)), -sin(PI/float(jump)));
    for (int n = 0; n < jump; n++) {
      for (int m = n; m < N; m+=jump<<1) {
        even = out[m];
        odd = theta.mul(out[m+(jump)]);
        out[m] = even.add(odd);
        out[m+(jump)] = even.sub(odd);
      }
      theta = phi.mul(theta);
    }
    jump = jump<<1;
  }
  return out;
}

complex[] IFFT(complex data[], int N) {
  complex[] out = new complex[N];
  int NN = bitLocation(N);
  for (int n = 0; n < N; n++) {
    out[n] = data[bitReverse(n, NN)].div(N);
  }
  int jump = 1;
  complex even = new complex();
  complex odd = new complex();
  for (int o = 0; o < NN; o++) {
    complex theta = new complex(1, 0);
    complex phi = new complex(cos(PI/float(jump)), sin(PI/float(jump)));
    for (int n = 0; n < jump; n++) {
      for (int m = n; m < N; m+=jump<<1) {
        even = out[m];
        odd = theta.mul(out[m+jump]);
        out[m] = even.add(odd);
        out[m+jump] = even.sub(odd);
      }
      theta = phi.mul(theta);
    }
    jump = jump<<1;
  }
  return out;
}

complex[][] FFT2D(complex data[][], int N) {
  complex tmp2[][] = new complex[N][N];
  complex out[][] = new complex[N][N];
  for (int n = 0; n < N; n++) {
    tmp2[n] = FFT(data[n], N);
  }
  complex tmp[] = new complex[N];
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      tmp[m] = tmp2[m][n];
    }
    tmp = FFT(tmp, N);
    for (int m = 0; m < N; m++) {
      out[m][n] = tmp[m];
    }
  }
  return out;
}

complex[][] IFFT2D(complex data[][], int N) {
  complex tmp2[][] = new complex[N][N];
  complex out[][] = new complex[N][N];
  for (int n = 0; n < N; n++) {
    tmp2[n] = IFFT(data[n], N);
  }
  complex tmp[] = new complex[N];
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      tmp[m] = tmp2[m][n];
    }
    tmp = IFFT(tmp, N);
    for (int m = 0; m < N; m++) {
      out[m][n] = tmp[m];
    }
  }
  return out;
}

void Filter(complex data[], complex filter[], int N) {
  for (int n = 0; n < N; n++) {
    data[n] = data[n].mul(filter[n]);
  }
}

void Filter2D(complex data[][], complex filter[][], int N) {
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      data[n][m] = data[n][m].mul(filter[n][m]);
    }
  }
}

void Add2D(complex data[][], complex filter[][], int N) {
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      data[n][m] = data[n][m].add(filter[n][m]);
    }
  }
}

double sq(double in) {
  return in*in;
}

complex[][] diffractor(complex E[][], int N, float lambda, float w, float z) {
  complex data[][] = FFT2D(E, N);
  double c = 2.0*PI*z;
  double c2 = 1.0/sq(lambda);
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      double n_ = n;
      double m_ = m;
      if (n > N/2)
        n_ = n - N;
      if (m > N/2)
        m_ = m - N;
      double theta = c*Math.sqrt(c2 - sq(n_/w) - sq(m_/w));
      //theta = theta - 2.0*PI*floor(theta/(2.0*PI));
      data[n][m] = data[n][m].mul(new complex(theta));
    }
  }
  data = IFFT2D(data, N);
  return data;
}

complex[][] sphereReflect(int N, float w, float lambda, float a, float r) {
  complex out[][] = new complex[N][N];
  double delta = Math.sqrt(sq((double)r) - sq((double)a/2.0));
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      double x = (((double)n/N) - 0.5)*w;
      double y = (((double)m/N) - 0.5)*w;
      if (sq(x)+sq(y) < sq(a/2)) {
        double theta = ((double)2.0*PI/((double)lambda))*(Math.sqrt(sq((double)r) - sq(x) - sq(y)) - delta);
        out[n][m] = new complex(2.0*theta);
      } else {
        out[n][m] = new complex();
      }
    }
  }
  return out;
}

complex[][] pointSource(int N, float w, float lambda, float z, float M) {
  complex out[][] = new complex[N][N];
  double c = ((double)(M*z))/((double)lambda);
  double k = ((double)(2.0*PI))/((double)lambda);
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      double x = (((double)n/N) - 0.5)*(double)w;
      double y = (((double)m/N) - 0.5)*(double)w;
      double r = Math.sqrt(sq(x)+sq(y)+sq(z));
      out[n][m] = (new complex(k*r)).mul((float)(c/sq(r)));
    }
  }
  return out;
}

void knifeEdgeX(complex data[][]) {
  for (int n = 0; n < N/2; n++) {
    for (int m = 0; m < N; m++) {
      data[n][m] = new complex();
    }
  }
}

void knifeEdgeY(complex data[][]) {
  for (int n = 0; n < N/2; n++) {
    for (int m = 0; m < N; m++) {
      data[n][m] = new complex();
    }
  }
}


PImage complexImageIntensity(complex data[][], int N) {
  PImage out = createImage(N, N, HSB);
  colorMode(HSB);
  float maxI = 0;
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      if (data[n][m].mag2() > maxI)
        maxI = data[n][m].mag2();
    }
  }
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      //out.set(n, m, color(128 + (128.0*data[n][m].arg()/PI), 192, 128.0*data[n][m].mag()));
      //out.set(n, m, color(170 - 128.0*data[n][m].mag2(), 255, 255));
      out.set(n, m, color(0, 0, 512.0*data[n][m].mag2()/maxI));
    }
  }
  colorMode(RGB);
  return out;
}

PImage complexImage(complex data[][], int N) {
  PImage out = createImage(N, N, HSB);
  colorMode(HSB);
  for (int n = 0; n < N; n++) {
    for (int m = 0; m < N; m++) {
      out.set(n, m, color(128 + (128.0*data[n][m].arg()/PI), 192, 128.0*data[n][m].mag()));
      //out.set(n, m, color(170 - 128.0*data[n][m].mag2(), 255, 255));
      //out.set(n, m, color(0,0,128.0*data[n][m].mag2()));
    }
  }
  colorMode(RGB);
  return out;
}

