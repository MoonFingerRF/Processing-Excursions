int mod(int a, int b) {
  int out = ((a%b) + b)%b;
  return out;
}

class Matrix {
  int N, M;
  float[][] a;
  float maxVal;
  Matrix(int N, int M) {
    this.N = N;
    this.M = M;
    a = new float[N][M];
    for (int n = 0; n < N; n++)
      for (int m = 0; m < M; m++)
        a[n][m] = 0;
    maxVal = 0;
  }
  Matrix(String file) {
    String[] lines = loadStrings(file);
    N = lines.length-1;
    String[] l1 = split(lines[0], ',');
    M = l1.length;
    a = new float[N][M];
    maxVal = 0;
    for (int n = 1; n < N+1; n++) {
      String[] line = split(lines[n], ',');
      for (int m = 0; m < M; m++) {
        a[n-1][m] = float(line[m]);
        if (a[n-1][m] > maxVal)
          maxVal = a[n-1][m];
      }
    }
  }
  float get(int n, int m) {
    if (n < 0 || m < 0 || n >= N || m >= M)
      return 0;
    return a[n][m];
  }
  float getClamp(int n, int m) {
    if (n < 0)
      n = 0;
    else if (n >= N)
      n = N-1;
    if (m < 0)
      m = 0;
    else if (m >= M)
      m = M-1;
    return a[n][m];
  }
  float getMod(int n, int m) {
    return a[mod(n, N)][mod(m, M)];
  }
  void set(int n, int m, float in) {
    a[n][m] = in;
  }
  float getMax() {
    maxVal = 0;
    for (int n = 0; n < N; n++)
      for (int m = 0; m < M; m++)
        if (a[n][m] > maxVal)
          maxVal = a[n][m];
    return maxVal;
  }
  Matrix transpose() {
    Matrix out = new Matrix(M, N);
    for (int n = 0; n < N; n++)
      for (int m = 0; m < M; m++)
        out.a[m][n] = a[n][m];
    return out;
  }
  PImage toImage() {
    PImage out = createImage(N, M, RGB);
    out.loadPixels();
    int i = 0;
    getMax();
    for (int m = 0; m < M; m++) {
      for (int n = 0; n < N; n++) {
        out.pixels[i] = color(255*a[n][m]/maxVal);
        i++;
      }
    }
    out.updatePixels();
    return out;
  }
  PImage toSTDImage() {
    PImage out = createImage(N, M, RGB);
    out.loadPixels();
    int i = 0;
    float mean = 0;
    float std = 0;
    for (int n = 0; n < N; n++)
      for (int m = 0; m < M; m++)
        mean += a[n][m];
    mean /= N*M;
    for (int n = 0; n < N; n++)
      for (int m = 0; m < M; m++)
        std += sq(a[n][m] - mean);
    std = sqrt(std/(N*M));
    for (int m = 0; m < M; m++) {
      for (int n = 0; n < N; n++) {
        out.pixels[i] = color(128*(((a[n][m]-mean)/std)*0.01 + 1.0));
        i++;
      }
    }
    out.updatePixels();
    return out;
  }
}

