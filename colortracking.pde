import processing.video.*;
import processing.sound.*;
/**
 * Color sticker hand tracking
 * by Doğa Yüksel
 */
Capture video;

class Sticker {
  float x;
  float y;
  color col;
  float blueValue;
  float middleValue;
  float littleValue;
  Sticker(float x, float y) {
    this.x = x;
    this.y = y;
    this.col = color(0, 0, 0);
    blueValue = 0;
    middleValue = littleValue = 1000;
  }
  Sticker(float x, float y, color c) {
    this.x = x;
    this.y = y;
    this.col = c;
    blueValue = 0;
    middleValue = littleValue = 1000;
  }
  
  float dist(float x, float y) {
    return sqrt((x - this.x) * (x - this.x) + (y - this.y) * (y - this.y));
  }
  float dist2(float x, float y) {
    return (x - this.x) * (x - this.x) + (y - this.y) * (y - this.y);
  }
}

class EnergyBall {
  float x, y;
  float speed;
  float direction;
  PImage sprite;
  EnergyBall(float x, float y, float direction) {
    this.x = x;
    this.y = y;
    this.direction = direction;
    this.speed = 10;
    this. sprite = loadImage("energyBall.png");
  }
  void update(){
    float hMove = cos(direction) * speed;
    float vMove = sin(direction) * speed;
    x += hMove;
    y += vMove;
  }
  void render(){
    image(sprite, x-16, y-16);
  }
}
EnergyBall[] bullets;
int screenBulletCount = 10;
int lastBullet = 0;

class BattleShip {
  float x, y;
  PImage sprite;
  int left, right, up, down;
  float speed = 6;
  float angle = 0;
  
  BattleShip(float x, float y, PImage sprite) {
    this.x = x;
    this.y = y;
    this.sprite = sprite;
  }
  
  void update() {
    float hMove = (right - left);
    float vMove = (down - up);
    float speedMult = 0;
    if (hMove != 0 || vMove != 0) 
      speedMult = speed / sqrt(hMove*hMove + vMove*vMove);
      
    hMove *= speedMult;
    vMove *= speedMult;
    
    float centerX = x + 48, centerY = y + 48;
    if (mouseX - centerX > 0)
      angle = atan((mouseY - centerY) / (mouseX - centerX));
    else if (mouseX - centerX < 0)
      angle = PI + atan((mouseY - centerY) / (mouseX - centerX));
    else {
      if (mouseY > centerY) angle = atan((mouseY - centerY) / (mouseX - centerX));
      else angle = PI + atan((mouseY - centerY) / (mouseX - centerX));
    }
    
    
    x += hMove;
    y += vMove;
  }
  
  void shoot() {
    float centerX = x + 48, centerY = y + 48;
    bullets[lastBullet] = new EnergyBall(centerX, centerY, angle);
    lastBullet = (lastBullet + 1) % screenBulletCount;
  }
  
  void moveTo(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void render() {
    pushMatrix();
    translate(x+48, y+48);
    rotate(angle);
    image(sprite, -48, -48);
    popMatrix();
  }
  
  void keyPressed() {
    if (key == 'w') up = 1;
    if (key == 's') down = 1;
    if (key == 'a') left = 1;
    if (key == 'd') right = 1;
  }
  void keyReleased() {
    if (key == 'w') up = 0;
    if (key == 's') down = 0;
    if (key == 'a') left = 0;
    if (key == 'd') right = 0;
  }
}

BattleShip player;

void setup() {
  size(1280, 480);
  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, 640, 480);
  video.start();  
  noStroke();
  smooth();
  
  // initialize
  bullets = new EnergyBall[screenBulletCount];
  // player
  PImage shipSprite = loadImage("battleship.png");
  shipSprite.resize(96, 96);
  player = new BattleShip(50, 180, shipSprite);
}

int frames = 0;

void draw() {
  if (video.available()) {
    background(128, 128, 128);
     
    fill(120, 64, 120);
    rect(0, 0, 640, 480);
    // Mirror the image
    //pushMatrix();
    //translate(video.width, 0);
    //scale(-1, 1);
    //image(video, 0, 0, width, height); // Draw the webcam video onto the screen
    //popMatrix();
    
    
    video.read();
    video.loadPixels();
    pushMatrix();
    translate(width, 0);
    scale(-1, 1);
    image(video, 0, 0);
    popMatrix();

    if (frames % 3 == 0) {
      
      Sticker blue  = new Sticker(0, 0);
      Sticker middle = new Sticker(0, 0);
      Sticker little = new Sticker(0, 0);
    
      int i = 0;
      for (int y = 0; y < video.height; y++) {
        for (int x = 0; x < video.width; x++) {
          // Get the color stored in the pixel
          color pixelValue = video.pixels[i];
          // Determine the brightness of the pixel
  
          float pixelBlueness = 2*blue(pixelValue) - red(pixelValue) - green(pixelValue);
          float pixelGreenness = abs(100 - red(pixelValue)) + abs(255 - green(pixelValue)) + abs(0 - blue(pixelValue));
          float pixelRedness = abs(255 - red(pixelValue)) + abs(150 - green(pixelValue)) + abs(50 - blue(pixelValue));
          // If that value is brighter than any previous, then store the
          // brightness of that pixel, as well as its (x,y) location
          if (pixelBlueness > blue.blueValue) {
            blue.blueValue = pixelBlueness;
            blue.x = x;
              blue.y = y;
              blue.col = pixelValue;
              //if (red(blue.col) != 0) 
              //  print("Blue R: " + red(blue.col) + "G:" + green(blue.col) + "B:" + blue(blue.col) + "\n");
            
          }
          if (pixelGreenness < middle.middleValue) {
            middle.middleValue = pixelGreenness;
            middle.x = x;
            middle.y = y;
            middle.col = pixelValue;
            //if (red(middle.col) != 0) 
            //  print("Middle R: " + red(middle.col) + "G:" + green(middle.col) + "B:" + blue(middle.col) + "\n");
          }
          if (pixelRedness < little.littleValue) {
            little.littleValue = pixelRedness;
            little.x = x;
            little.y = y;
            little.col = pixelValue;
            //if (red(little.col) != 0) 
            //  print("Little R: " + red(little.col) + "G:" + green(little.col) + "B:" + blue(little.col) + "\n");
          }
          i++;
        }
      }
      player.moveTo(width - (middle.x + little.x) / 2, (middle.y + little.y) / 2 );
      
      if (middle.x - little.x > 0)
        player.angle = PI/2.0 + atan((little.y - middle.y) / (middle.x - little.x));
      else if (middle.x - little.x < 0)
        player.angle = 3*PI/2.0 + atan((little.y - middle.y) / (middle.x - little.x));
      else {
        if (middle.y > little.y) player.angle = PI/2.0 + atan((little.y - middle.y) / (middle.x - little.x));
        else player.angle = 3*PI/2.0 + atan((little.y - middle.y) / (middle.x - little.x));
      }
      if (frames % 15 == 0) {
        if (blue.dist2(middle.x, middle.y) < 3600) player.shoot();
      }
    
      // Draw a large, yellow circle at the brightest pixel
    fill(0, 0, 255, 128);
    ellipse(width - blue.x, blue.y, 40, 40);
    fill(255, 212, 0, 128);
    ellipse(width - middle.x, middle.y, 40, 40);
    fill(255, 128, 0, 128);
    ellipse(width - little.x, little.y, 40, 40);
    }
    for(int j = 0; j < screenBulletCount; j++) {
      if (bullets[j] != null) {
        bullets[j].update();
      }
    }
    
    
    
    player.render();
    for(int j = 0; j < screenBulletCount; j++) {
      if (bullets[j] != null) {
        bullets[j].render();
      }
    }
  }
  frames++;
}

void mousePressed() {
  player.shoot();
}
