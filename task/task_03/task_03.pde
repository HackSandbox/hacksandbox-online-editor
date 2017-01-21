Container mainContainer;
Image backgroundImage;

void setup(){
  size(500, 500);
  mainContainer = new Container();
  
  backgroundImage = new Image(loadImage("background.png"), 500, 500);
  backgroundImage.addToStage(mainContainer);
}

void draw(){
  background(255, 0, 0);
  
  mainContainer.updateAll();
  mainContainer.drawAll();
}