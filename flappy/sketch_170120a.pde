Container mainContainer;
Flappy flappy;
Image background;
Repeater repeater;


float openingSize = 100;


class Flappy extends Container
{
	float speedY;
	float gravity;
	
	Image image;
	
	Flappy() {
		super();
		
		this.speedY = 0;
		this.gravity = 0.7f;
		
		this.image = new Image(loadImage("flappy.png"));
		this.image.pImage.resize(50, 50);
		this.image.addToStage(this);
	}
	
	void update() {
		this.speedY += this.gravity;
		this.y += this.speedY;
		
		if (this.y > 600) {
			this.removeFromStage();
		}
		else if (this.y < 0) {
			this.y = 0;
			this.speedY = 0;
		}
	}
	
	void flap() {
		this.speedY = -10.0f;
	}

}

class Pipe extends Rectangle
{
	
	float speedX = -2.0f;
	
	Pipe(float x, float y, float width, float height) {
		super(width, height);
		this.x = x;
		this.y = y;
	}
	
	void update() {
		this.x += this.speedX;
	}

}

void makePipes() {
	float r = random(100, 500);
	float rTop = r - openingSize;
	float rBottom = r + openingSize;
	Pipe pipe1 = new Pipe(800, 0, 75, rTop);
	pipe1.addToStage(mainContainer);
	Pipe pipe2 = new Pipe(800, rBottom, 75, 600 - rBottom);
	pipe2.addToStage(mainContainer);
}

void setup ()
{
	size(800, 600);
	mainContainer = new Container();
	
	background = new Image(loadImage("background.png"));
	background.addToStage(mainContainer);
	background.pImage.resize(800, 600);
	
	flappy = new Flappy();
	flappy.addToStage(mainContainer);
	flappy.y = 50;
	flappy.x = 50;
	
	repeater = new Repeater(150);
}

void draw ()
{
	background(0);

	repeater.update();
	
	if (repeater.triggered) {
		makePipes();
	}

	mainContainer.updateAll();
	mainContainer.drawAll();
}

void mousePressed() {
	
}

void keyPressed() {
	if (key == ' ') {
		flappy.flap();
	}
}
