float DMDelay(float v1, float v2, float DM) {
  float KDM = 4148.808;
  return KDM*DM*((1.0/(v2*v2)) - (1.0/(v1*v1)));
}

Matrix slowDM(Matrix in, float DMLow, float DMHigh, int DMN, float FLow, float FHigh, float TLength) {
  Matrix out = new Matrix(in.N, DMN);
  float DMCoeff = (DMHigh - DMLow)/DMN;
  float FCoeff = (FHigh - FLow)/in.M;
  float TCoeff = TLength/in.N;
  for (int j = 0; j < DMN; j++) {
    println(j);
    float DM = DMLow + j*DMCoeff;
    for (int k = 0; k < in.M; k++) {
      float F = FLow + k*FCoeff;
      float delay = DMDelay(FLow, F, DM);
      int n = floor(delay/TCoeff);
      for (int i = 0; i < in.N; i++) {
        out.set(i, j, out.get(i, j) + in.getMod(i+n, k));
      }
    }
  }
  return out;
}

