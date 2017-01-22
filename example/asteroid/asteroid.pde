Stage stage;

TitleScreen titleScreen;
GameScreen gameScreen;
EndScreen endScreen;

int numAsteroids = 8;
float breakThreshold = 15;
float breakRadiusMul = 0.6;

int highscore = 0;
int score = 0;

class TitleScreen extends Container
{
	
	Text title;
	Text highscoreTxt;
	RectangleButton startBtn;
	
	TitleScreen() {
		title = new Text("Asteroid");
		title.addToStage(this);
		title.x = stage.getCenterX();
		title.y = stage.getCenterY() - 100;
		title.fontSize = 36;
		title.textColor = color(0);

		highscoreTxt = new Text("Highscore: " + highscore + "\n\nPress W/S/A/D to move\nHold SPACE to shoot");
		highscoreTxt.addToStage(this);
		highscoreTxt.fontSize = 20;
		highscoreTxt.x = stage.getCenterX();
		highscoreTxt.y = stage.getCenterY();

		startBtn = new RectangleButton(100, 30, "Play");
		startBtn.addToStage(this);
		startBtn.x = stage.getCenterX();
		startBtn.y = stage.getCenterY() + 100;
	}
	
	void update() {
		if (startBtn.releasedOnce) {
			this.removeFromStage();

			gameScreen = new GameScreen();
			gameScreen.addToStage(stage);
		}
	}
	
}

class Bullet extends MovableContainer
{
	Circle circle;
	
	Bullet(float x, float y, float angle, float speed) {
		this.speedReduction = 0;
		this.angularSpeedReduction = 0;

		this.x = x;
		this.y = y;
		
		this.circle = new Circle(10, 10);
		this.circle.addToStage(this);
		this.circle.circleColor = color(0);
		this.circle.borderWeight = 0;
		
		this.applyForce(angle, speed);
	}
	
	void update() {
		if (!Util.pointInRectangle(this.x, this.y, 0, 0, stage.getScreenWidth(), stage.getScreenHeight())) {
			this.removeFromStage();
		}
		
		for (int i = 0; i < gameScreen.asteroids.size(); ++i) {
			Asteroid asteroid = gameScreen.asteroids.get(i);
			if (Util.pointInRange(this.x, this.y, asteroid.x, asteroid.y, asteroid.radius)) {
				asteroid.destroy();
				this.removeFromStage();
				break;
			}
		}
	}

}

class Ship extends MovableContainer
{
	
	float angularForce;
	float force;
	Repeater repeater;
	
	Ship() {
		this.speedReduction = 0.02;
		this.angularSpeedReduction = 0.1;
		
		this.angularForce = 0.01;
		this.force = 0.15;
		
		this.repeater = new Repeater(15);
	}
	
	void draw() {
		fill(165);
		stroke(0);
		strokeWeight(1);
		beginShape();
		vertex(0, 0);
		vertex(-5, -10);
		vertex(20, 0);
		vertex(-5, 10);
		endShape(CLOSE);
	}
	
	void update() {
		this.repeater.update();

		if (Input.isKeyHolding('w')) {
			this.applyForce(this.rotation, this.force);
		}
		if (Input.isKeyHolding('s')) {
			this.applyForce(this.rotation, -this.force);
		}
		if (Input.isKeyHolding('a')) {
			this.applyAngularForce(-this.angularForce);
		}
		if (Input.isKeyHolding('d')) {
			this.applyAngularForce(this.angularForce);
		}
		if (Input.isKeyHolding(' ') && this.repeater.triggered) {
			Bullet bullet = new Bullet(this.x, this.y, this.rotation, 15.0f);
			bullet.addToStage(gameScreen);
		}
	
		this.x = Util.wrap(this.x, stage.getScreenWidth(), 20);
		this.y = Util.wrap(this.y, stage.getScreenHeight(), 20);
	}

}

class Asteroid extends MovableContainer
{
	Circle circle;
	float radius;
	
	Asteroid(float x, float y, float angle, float speed, float radius) {
		this.radius = radius;

		this.speedReduction = 0;
		this.angularSpeedReduction = 0;

		this.x = x;
		this.y = y;
		
		this.circle = new Circle(radius * 2, radius * 2);
		this.circle.addToStage(this);
		this.circle.circleColor = color(225);
		this.circle.borderWeight = 5;
		this.circle.borderColor = color(50);
		
		this.applyForce(angle, speed);
	}
	
	void destroy() {
		this.removeFromStage();
		gameScreen.asteroids.remove(this);
		if (this.radius > breakThreshold) {
			gameScreen.makeAsteroid(this.x, this.y, this.radius * breakRadiusMul);
			gameScreen.makeAsteroid(this.x, this.y, this.radius * breakRadiusMul);
		}
		else if (gameScreen.asteroids.size() < numAsteroids) gameScreen.makeAsteroidRandom();
		
		++score;
	}
	
	void update() {
		this.x = Util.wrap(this.x, stage.getScreenWidth(), this.radius);
		this.y = Util.wrap(this.y, stage.getScreenHeight(), this.radius);
		
		if (Util.pointInRange(this.x, this.y, gameScreen.ship.x, gameScreen.ship.y, this.radius)) {
			gameScreen.gameOver();
		}
	}
}

class GameScreen extends Container
{
	
	Ship ship;
	ArrayList<Asteroid> asteroids;
	Text scoreTxt;
	Container asteroidContainer;
	
	Asteroid makeAsteroidRandom() {
		float radius = random(8, 35);
		float distance = random(200, 400);
		float angle = random(0, 100);
		float moveAngle = random(0, 100);
		float moveSpeed = random(1, 6);
		Asteroid asteroid = new Asteroid(this.ship.x + Util.angleToX(angle, distance), this.ship.y + Util.angleToY(angle, distance), moveAngle, moveSpeed, radius);
		asteroid.addToStage(this.asteroidContainer);
		asteroids.add(asteroid);
		
		return asteroid;
	}
	
	Asteroid makeAsteroid(float x, float y, float radius) {
		float moveAngle = random(0, 100);
		float moveSpeed = random(1, 7);
		Asteroid asteroid = new Asteroid(x, y, moveAngle, moveSpeed, radius);
		asteroid.addToStage(this.asteroidContainer);
		asteroids.add(asteroid);
		
		return asteroid;
	}
	
	GameScreen() {
		this.asteroidContainer = new Container();
		this.asteroidContainer.addToStage(this);
		
		this.ship = new Ship();
		this.ship.addToStage(this);
		this.ship.x = stage.getCenterX();
		this.ship.y = stage.getCenterY();
		
		this.scoreTxt = new Text("");
		this.scoreTxt.addToStage(this);
		this.scoreTxt.fontSize = 20;
		this.scoreTxt.x = 10;
		this.scoreTxt.y = 10;
		this.scoreTxt.textAlignX = LEFT;
		this.scoreTxt.textAlignY = TOP;

		this.asteroids = new ArrayList<Asteroid>();
		for (int i = 0; i < numAsteroids; ++i) {
			this.makeAsteroidRandom();
		}
		
		score = 0;
	}
	
	void gameOver() {
		if (score > highscore) highscore = score;

		this.removeFromStage();
		
		endScreen = new EndScreen();
		endScreen.addToStage(stage);
	}
	
	void update() {
		this.scoreTxt.content = "Score: " + score;
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
		title.fontSize = 24;
		title.x = 400;
		title.y = 200;

		highscoreTxt = new Text("Score: " + score + "\nHighscore: " + highscore);
		highscoreTxt.addToStage(this);
		highscoreTxt.fontSize = 20;
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
			titleScreen.addToStage(stage);
		}
	}

}

void setup() {
	size(800, 600);
	
	stage = new Stage();
	
	titleScreen = new TitleScreen();
	titleScreen.addToStage(stage);
}

void draw() {
	background(255);
	
	Input.update();
	
	stage.run();
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
