Container mainContainer;
Image backgroundImage;

TitleScreen titleScreen;
GameScreen gameScreen;
EndScreen endScreen;


float pipeOpening = 80;
float pipeSpawnPeriod = 80;

int highscore = 0;
int score = 0;


class Flappy extends Container
{
	float speedY;
	float gravity;
	
	Image image;
	
	Flappy() {
		super();
		
		this.speedY = 0;
		this.gravity = 0.7f;
		
		this.image = new Image(loadImage("flappy.png"), 50, 50);
		this.image.addToStage(this);
		this.image.x = -25;
		this.image.y = -25;
	}
	
	void update() {
		this.speedY += this.gravity;
		this.y += this.speedY;
		
		if (this.y > 600) {
			gameScreen.gameOver();
		}
		else if (this.y < 0) {
			this.y = 0;
			this.speedY = 0;
		}
		
		if (Input.isAnyKeyPressedOnce() || Input.isAnyMousePressedOnce()) {
			this.flap();
		}
	}
	
	void flap() {
		this.speedY = -12.0f;
	}

}

class Pipe extends Rectangle
{
	
	float speedX;
	boolean addedToScore;
	
	Pipe(float x, float y, float width, float height) {
		super(width, height);
		this.x = x;
		this.y = y;
		
		this.rectColor = color(100, 225, 100);
		this.borderColor = color(100, 100, 100);
		this.borderWeight = 5;
		
		this.speedX = -4.0f;
		this.addedToScore = false;
	}
	
	void update() {
		this.x += this.speedX;
		
		if (this.x < -this.width) {
			this.removeFromStage();
		}
		
		if (Util.pointInRectangle(this.getLocalX(gameScreen.flappy.x, gameScreen.flappy.y), this.getLocalY(gameScreen.x, gameScreen.flappy.y), 0, 0, this.width, this.height)) {
			gameScreen.gameOver();
		}
		
		if (this.x + this.width < gameScreen.flappy.x && !this.addedToScore && this.y == 0) {
			++score;
			this.addedToScore = true;
		}
		
	}

}

class TitleScreen extends Container
{
	
	Text title;
	Text highscoreTxt;
	RectangleButton startBtn;
	
	TitleScreen() {
		title = new Text("Flappy Hacks");
		title.addToStage(this);
		title.size = 32;
		title.x = 400;
		title.y = 200;

		highscoreTxt = new Text("Highscore: " + highscore);
		highscoreTxt.addToStage(this);
		highscoreTxt.size = 20;
		highscoreTxt.x = 400;
		highscoreTxt.y = 280;

		startBtn = new RectangleButton(90, 30, "Start");
		startBtn.x = 400;
		startBtn.y = 400;
		startBtn.addToStage(this);
	}
	
	void update() {
		if (startBtn.releasedOnce) {
			this.removeFromStage();
			
			gameScreen = new GameScreen();
			gameScreen.addToStage(mainContainer);
		}
	}

}

class GameScreen extends Container
{
	
	Flappy flappy;
	Repeater repeater;
	
	Text scoreTxt;
	Container pipeContainer;
	
	GameScreen() {
	
		this.pipeContainer = new Container();
		this.pipeContainer.addToStage(this);
		
		this.flappy = new Flappy();
		this.flappy.addToStage(this);
		this.flappy.y = 50;
		this.flappy.x = 120;
		
		this.scoreTxt = new Text("");
		this.scoreTxt.addToStage(this);
		this.scoreTxt.size = 20;
		this.scoreTxt.x = 10;
		this.scoreTxt.y = 10;
		this.scoreTxt.textAlignX = LEFT;
		this.scoreTxt.textAlignY = TOP;

		this.repeater = new Repeater(pipeSpawnPeriod);
		
		score = 0;
	}
	
	void makePipes() {
		float r = random(100, 500);
		float rTop = r - pipeOpening;
		float rBottom = r + pipeOpening;
		Pipe pipe1 = new Pipe(800, 0, 100, rTop);
		pipe1.addToStage(this.pipeContainer);
		Pipe pipe2 = new Pipe(800, rBottom, 100, 600 - rBottom);
		pipe2.addToStage(this.pipeContainer);
	}

	void update() {
		scoreTxt.content = "Score: " + score;

		repeater.update();
		
		if (repeater.triggered) {
			makePipes();
		}
	}
	
	void gameOver() {
		if (score > highscore) highscore = score;

		this.removeFromStage();
		
		endScreen = new EndScreen();
		endScreen.addToStage(mainContainer);
	}

}

class EndScreen extends Container
{
	
	Text highscoreTxt;
	Text title;
	RectangleButton okBtn;
	
	EndScreen() {
		title = new Text("YOU DIED");
		title.addToStage(this);
		title.size = 24;
		title.x = 400;
		title.y = 200;

		highscoreTxt = new Text("Score: " + score + "\nHighscore: " + highscore);
		highscoreTxt.addToStage(this);
		highscoreTxt.size = 20;
		highscoreTxt.x = 400;
		highscoreTxt.y = 280;

		okBtn = new RectangleButton(90, 30, "OK");
		okBtn.x = 400;
		okBtn.y = 400;
		okBtn.addToStage(this);
	}
	
	void update() {
		if (okBtn.releasedOnce) {
			this.removeFromStage();
			
			titleScreen = new TitleScreen();
			titleScreen.addToStage(mainContainer);
		}
	}

}

void setup ()
{
	size(800, 600);
	mainContainer = new Container();
	
	backgroundImage = new Image(loadImage("background.png"), 800, 600);
	backgroundImage.addToStage(mainContainer);
	
	titleScreen = new TitleScreen();
	titleScreen.addToStage(mainContainer);
}

void draw ()
{
	background(0);

	Input.update();

	mainContainer.updateAll();
	mainContainer.drawAll();
}

void mousePressed() {
	Input.mousePressed(mouseButton);
}

void mouseReleased() {
	Input.mouseReleased(mouseButton);
}

void keyPressed() {
	Input.keyPressed(key, keyCode);
}

void keyReleased() {
	Input.keyReleased(key, keyCode);
}
