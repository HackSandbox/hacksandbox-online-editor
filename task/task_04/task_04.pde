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