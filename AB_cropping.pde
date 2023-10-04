size(720 * 2, 1280);
PImage Img = loadImage("plate2.png");   // Store the input image
loadPixels(); 
Img.loadPixels();
PImage grayscaleImage = createImage(Img.width, Img.height, RGB);    // Define the dimensions of the grayscale image same as the input image

int[] h = new int[256];   // Store the histogram of the input image
int[] heq = new int[256];   // Store the result of histogram equalization
for (int y = 0; y < Img.height; y++)   // Iterate over each pixel
  for (int x = 0; x < Img.width; x++) {
    int Index = x + y * Img.width;       // Get the Index of the pixels
    float r = red(Img.pixels[Index]);    // Convert pixel color into a floating value
    float g = green(Img.pixels[Index]);
    float b = blue(Img.pixels[Index]);
    grayscaleImage.pixels[Index] =  color(0.2*r + 0.6*g + 0.2*b);     // Convert the color image into grayscale
    int w = int(brightness(Img.pixels[Index]));  // Calculate the brightness of the pixels
    h[w]++;  // Count pixels with specific brightness
  }
  for (int i = 0; i < 256; i++)
     println("h[" + i + "] " + h[i]);
     
PImage equalizedImage = createImage(Img.width, Img.height, RGB);    // Define the dimensions of the equalized image same as the input image

int temp = 0;
for (int i = 0; i < 256; i++) {         // Iterate between different intensity values
  temp += h[i];     // Add the count of pixels with that brightness level from the h histogram to the temp
  heq[i] = (int) 255 * temp / (Img.width * Img.height);  // Calculate the equalized value and store it
}

for (int y = 0; y < Img.height; y++)
  for (int x = 0; x < Img.width; x++) {
    int imgIndex = y * Img.width + x;
    int w = int(brightness(Img.pixels[imgIndex]));
    equalizedImage.pixels[imgIndex] = color(heq[w]);
  }

equalizedImage.updatePixels();

// Apply adaptive binarization
PImage binaryImage = createImage(Img.width, Img.height, RGB);  // Create a binary image canvas
binaryImage.loadPixels();

int neighborhoodSize = 20;  // Size of the local neighborhood (adjust as needed)

for (int y = 0; y < Img.height; y++) {
  for (int x = 0; x < Img.width; x++) {
    int index = x + y * Img.width;
    float localSum = 0;
    int count = 0;

    // Calculate the local mean within the neighborhood
    for (int j = -neighborhoodSize / 2; j <= neighborhoodSize / 2; j++) {      //calculate mean by examining neighbouring pixels
      for (int i = -neighborhoodSize / 2; i <= neighborhoodSize / 2; i++) {
        int neighborX = constrain(x + i, 0, Img.width - 1);  //calculates the horizontal position of the neighboring pixel
        int neighborY = constrain(y + j, 0, Img.height - 1);  //calculates the vertical position of the neighboring pixel
        int neighborIndex = neighborX + neighborY * Img.width;  //computes the index of the neighboring pixel
        localSum += brightness(equalizedImage.pixels[neighborIndex]);  //adds the brightness value of the neighboring pixel to the localSum variable
        count++;
      }
    }

    float localMean = localSum / count;  //calculates the mean brightness within neighborhood
    float pixelValue = brightness(equalizedImage.pixels[index]);  //calculates brightness value of current pixel

    // Apply adaptive thresholding
    if (pixelValue > localMean) {
      binaryImage.pixels[index] = color(255);  // White (foreground)
    } else {
      binaryImage.pixels[index] = color(0);    // Black (background)
    }
  }
}

binaryImage.updatePixels();

// Apply cropping using Sobel filter to the binarized image
PImage edgeImage = createImage(Img.width, Img.height, RGB);
edgeImage.loadPixels();

float[][] sobelX = {    //detection of horizontal edgees
  {-1, 0, 1},
  {-2, 0, 2},
  {-1, 0, 1}
};

float[][] sobelY = {     // detection of vertical edges
  {-1, -2, -1},
  {0, 0, 0},
  {1, 2, 1}
};

for (int y = 1; y < Img.height - 1; y++) {
  for (int x = 1; x < Img.width - 1; x++) {
    float sumX = 0;
    float sumY = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int xi = x + i;
        int yj = y + j;
        int imgIndex = xi + yj * Img.width;
        float pixelValue = brightness(binaryImage.pixels[imgIndex]);
        sumX += sobelX[i + 1][j + 1] * pixelValue;
        sumY += sobelY[i + 1][j + 1] * pixelValue;
      }
    }
    float magnitude = sqrt(sumX * sumX + sumY * sumY);
    edgeImage.pixels[x + y * Img.width] = color(magnitude);
  }
}

edgeImage.updatePixels();

// Display the images vertically
image(grayscaleImage, 0, 0);
image(equalizedImage, 0, grayscaleImage.height); // Below the grayscale image
image(binaryImage, 0, grayscaleImage.height + equalizedImage.height); // Below the equalized image
image(edgeImage, 0, grayscaleImage.height + equalizedImage.height + binaryImage.height); // Below the binary image
