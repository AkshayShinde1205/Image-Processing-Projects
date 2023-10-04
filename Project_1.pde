size(720*2, 1280);
PImage Img = loadImage("Goku.png");   //store the input image
loadPixels(); 
Img.loadPixels();
PImage grayscaleImage = createImage(Img.width, Img.height, RGB);    //defining the  dimensions of grayscale image same as input image

int[] h = new int[256];   //store the histogram of input image
int[] heq = new int[256];   //stores the result of histogram equilization
for(int y = 0; y < Img.height; y++)   //Iterate over each pixel
  for (int x = 0; x < Img.width; x++) {
    int Index = x+y*Img.width;       //getting the Index of the pixels
    float r = red(Img.pixels[Index]);    //convert pixel color into floating value
    float g = green(Img.pixels[Index]);
    float b = blue(Img.pixels[Index]);
    grayscaleImage.pixels[Index] =  color(r + g + b);     //convert color image into greyscale
    //grayscaleImage.pixels[Index] =  color(0.3*r + 0.4*g + 0.3*b); 
    int w = int(brightness(Img.pixels[Index]));  //calculate the brightness of the pixels
    h[w]++;  //counts pixel with specific brightness
  }
  for(int i =0; i < 256; i++)
     println("h["+i+"] "+ h[i]);
     
     PImage equalizedImage = createImage(Img.width, Img.height, RGB);    //defining the  dimensions of equalized image same as input image
     
int temp = 0;
for(int i = 0; i < 256; i++){         //iterates between different intensity values
  temp += h[i];     //adds the count of pixels with that brightness level from the h histogram to the temp
  heq[i] = (int) 255 * temp / (Img.width * Img.height);  //calculates equilized value and stores in array
}

for (int y = 0; y < Img.height; y++)
  for (int x = 0; x < Img.width; x++) {
    int imgIndex = y * Img.width+ x;
    int w = int(brightness(Img.pixels[imgIndex]));
    equalizedImage.pixels[imgIndex] = color(heq[w]);
  }
 
equalizedImage.updatePixels();
grayscaleImage.updatePixels();

//displaying the processed images
image(grayscaleImage, 0, 0);
image(equalizedImage, grayscaleImage.width, 0);
