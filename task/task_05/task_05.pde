Container mainContainer;
Image backgroundImage;
Image actor;

void setup(){
  size(500, 500);
  mainContainer = new Container();
  
  backgroundImage = new Image(loadImage("background.png"), 500, 500);
  backgroundImage.addToStage(mainContainer);
  
  actor = new Image(loadImage("flappy.png"), 50, 50);
  actor.addToStage(mainContainer);
  actor.x = 200;
  actor.y = 200;
}

void draw(){
  // background(255, 0, 0);
  
  mainContainer.updateAll();
  mainContainer.drawAll();
}

void keyPressed(){
  if (key == 'w' || key == 'W' || keyCode == UP){
    actor.y --;
  }
  else if (key == 's' || key == 'S' || keyCode == DOWN){
    actor.y ++;
  }
  else if (key == 'a' || key == 'A' || keyCode == LEFT){
    actor.x --;
  }
  else if (key == 'd' || key == 'D' || keyCode == RIGHT){
    actor.x ++;
  }
}

void mousePressed(){
  if (mouseButton == LEFT){
    actor.x = actor.x - 10;
  }
  else if (mouseButton == RIGHT){
    actor.x = actor.x + 10;
  }
  else if (mouseButton == CENTER){
    actor.x = 200;
    actor.y = 200;
  }
}