Container mainContainer;
Image backgroundImage;
Image actor;
Rectangle wall1;
Rectangle wall2;
Wall wall;

void setup(){
  size(500, 500);
  mainContainer = new Container();
  
  backgroundImage = new Image(loadImage("background.png"), 500, 500);
  backgroundImage.addToStage(mainContainer);
  
  actor = new Image(loadImage("flappy.png"), 50, 50);
  actor.addToStage(mainContainer);
  actor.x = 200;
  actor.y = 200;
  
  wall = new Wall(actor);
  
  wall1 = new Rectangle(20, 200);
  wall1.addToStage(mainContainer);
  wall1.x = 120;
  wall1.y = 120;
  
  wall.addwall(wall1);
  
  wall2 = new Rectangle(200, 20);
  wall2.addToStage(mainContainer);
  wall2.x = 140;
  wall2.y = 100;
  
  wall.addwall(wall2);
}

void draw(){
  // background(255, 0, 0);
  
  mainContainer.updateAll();
  mainContainer.drawAll();
}

void keyPressed(){
  if (key == 'w' || key == 'W' || keyCode == UP){
    actor.y --;
    if (wall.overlaps()){
      actor.y ++;
    }
  }
  else if (key == 's' || key == 'S' || keyCode == DOWN){
    actor.y ++;
    if (wall.overlaps()){
      actor.y --;
    }
  }
  else if (key == 'a' || key == 'A' || keyCode == LEFT){
    actor.x --;
    if (wall.overlaps()){
      actor.x ++;
    }
  }
  else if (key == 'd' || key == 'D' || keyCode == RIGHT){
    actor.x ++;
    if (wall.overlaps()){
      actor.x --;
    }
  }
}

void mousePressed(){
  if (mouseButton == LEFT){
    actor.x --;
    actor.y --;
    if (wall.overlaps()){
      actor.x ++;
      actor.y ++;
    }
  }
  else if (mouseButton == RIGHT){
    actor.x ++;
    actor.y ++;
    if (wall.overlaps()){
      actor.x --;
      actor.y --;
    }
  }
  else if (mouseButton == CENTER){
    actor.x = 200;
    actor.y = 200;
  }
}