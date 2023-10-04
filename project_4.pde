void setup() {
  size(1000, 800);
  PImage img = loadImage("numbers.jpg");
  PImage img2 = loadImage("one.jpg");
  img.loadPixels();
  img2.loadPixels();

  int n = 8;  // Number of chaincode directions
  int M = 2;  // Grid dimension
  int N = 2;
  int step_size_x = 10; // Step size in the x-axis
  int step_size_y = 10; // Step size in the y-axis
  
  image(img, 0, 0); // Display image1
  image(img2, img.width + 10, 0);
  objectDetection(img, img2, M, N, n, step_size_x, step_size_y);
}

PImage grayscale(PImage img) {
  PImage img_gray = createImage(img.width, img.height, RGB);
  img.loadPixels();
  img_gray.loadPixels();
  for (int row = 0; row < img.height; row++)
    for (int col = 0; col < img.width; col++) {
      int index = row * img.width + col;
      float r = red(img.pixels[index]);
      float g = green(img.pixels[index]);
      float b = blue(img.pixels[index]);
      img_gray.pixels[index] = color((0.6*r + 0.2*g + 0.2*b) / 3);
    }
  img_gray.updatePixels();
  return img_gray;
}

void objectDetection(PImage img_gray, PImage img2_gray, int M, int N, int n, int step_size_x, int step_size_y) {
  image(img_gray, 0, 0);
  img2_gray = grayscale(img2_gray);
  float[][] img_hog = hog1(img2_gray, n, M, N);  // Calculate HoG for img2
  float threshold = 0.99; // Set your desired threshold here
  
  for (int y = 0; y < img_gray.height; y += step_size_y) {
    for (int x = 0; x < img_gray.width; x += step_size_x) {
      PImage i = img_gray.get(x, y, img2_gray.width, img2_gray.height);
      PImage i_gray = grayscale(i);
      float[][] i_hog = hog1(i_gray, n, M, N);  // Calculate HoG for the current window
      float similarity = cosine_similarity(img_hog, i_hog);
      
      if (similarity > threshold) {
        println("Match found at (x=" + x + ", y=" + y + "), Similarity = " + similarity);
        
        noFill();
        stroke(255, 0, 0); // Red outline
        strokeWeight(2);
        rect(x, y, img2_gray.width, img2_gray.height);
      }
    }
  }
}


float[][] hog1(PImage img, int n, int M, int N) {
  float[][] histogram = new float[M * N][n];
  int block_width = img.width / N + 1;
  int block_height = img.height / M + 1;
  int c = 0;
  for (int y = 0; y < img.height; y += block_height) {
    for (int x = 0; x < img.width; x += block_width) {
      PImage i = img.get(x, y, block_width, block_height);
      i.loadPixels();
       float[][] filter1 = {
        {-1, 0, 1},
        {-2, 0, 2},
        {-1, 0, 1}
      };
      float[][] filter2 = {
        {-1, -2, -1},
        {0, 0, 0},
        {1, 2, 1}
      };
      for (int y1 = 1; y1 < i.height - 1; y1++)
        for (int x1 = 1; x1 < i.width - 1; x1++) {
          float f1 = 0, f2 = 0;     //accumulate gradient information in X and Y directions
          for (int ky = -1; ky <= 1; ky++)
            for (int kx = -1; kx <= 1; kx++) {
              int index = (y1 + ky) * i.width + (x1 + kx);
              float r = brightness(i.pixels[index]);
              f1 += filter1[ky + 1][kx + 1] * r;     //calculating gradient in x direction
              f2 += filter2[ky + 1][kx + 1] * r;    //calculating gradient in y direction
            }
          float magnitude = sqrt(f1 * f1 + f2 * f2);   
          float theta = atan2(f2, f1) + PI;
          if (theta == TWO_PI) theta = 0;
          float[] h_temp = new float[n]; // store the contributions to histogram bins
          h_temp[int(theta * n / TWO_PI)] = magnitude;
          for (int k = 0; k < n; k++)
            histogram[c][k] = histogram[c][k] + h_temp[k];
        }
      c++;
    }
  }
 float s = 0;
  for (int l = 0; l < M * N; l++) {
    for (int g = 0; g < n; g++)
      s += histogram[l][g] * histogram[l][g];
  }
  s = sqrt(s);
  if (s == 0) return histogram;

  for (int l = 0; l < M * N; l++) {
    for (int g = 0; g < n; g++)
      histogram[l][g] /= s;
  }
  return histogram;
}

float cosine_similarity(float[][] h1, float[][] h2) {
  float dotProduct = 0;
  float normh1 = 0;
  float normh2 = 0;

  for (int i = 0; i < h1.length; i++) {
    for (int j = 0; j < h2[i].length; j++) {
      dotProduct += h1[i][j] * h2[i][j];
      normh1 += h1[i][j] * h1[i][j];
      normh2 += h2[i][j] * h2[i][j];
    }
  }

  normh1 = sqrt(normh1);
  normh2 = sqrt(normh2);

  if (normh1 == 0 || normh2 == 0) {
    return 0;
  } else {
    return dotProduct / (normh1 * normh2);
  }
}
