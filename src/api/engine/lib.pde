class DisplayObject 
{
	Container parent;
	float x;
	float y;
	float w;
	float h;
	float rotation;
	float scaleX;
	float scaleY;
	boolean visible;
	boolean paused;
	
	protected Matrix stageMatrix;

	DisplayObject() {
		this.parent = null;
		this.x = 0;
		this.y = 0;
		this.w = 0;
		this.h = 0;
		this.rotation = 0;
		this.scaleX = 1;
		this.scaleY = 1;
		this.visible = true;
		this.paused = false;
		
		this.stageMatrix = new Matrix(1, 0, 0, 1, 0, 0);
	}
	
	void draw() {
		
	}
	
	void drawAll() {
		if (!this.visible) return;
		
		pushMatrix();
		pushStyle();
		
		this.transform();
		this.draw();
		
		popStyle();
		popMatrix();
	}
	
	void updateStageMatrix() {
		this.stageMatrix.createBox(this.scaleX, this.scaleY, this.rotation, this.x, this.y);
		if (this.parent != null) {
			this.stageMatrix.concat(this.parent.stageMatrix);
		}
	}
	
	protected float getLocalX(float stageX, float stageY) {
		return this.stageMatrix.transformInverseX(stageX, stageY);
	}
	
	protected float getLocalY(float stageX, float stageY) {
		return this.stageMatrix.transformInverseY(stageX, stageY);
	}
	
	protected float getLocalMouseX() {
		return this.getLocalX(mouseX, mouseY);
	}
	
	protected float getLocalMouseY() {
		return this.getLocalY(mouseX, mouseY);
	}
	
	void update() {
		
	}
	
	void updatePhysics() {
		
	}
	
	void updateAll() {
		if (this.paused) return;
		
		this.updateStageMatrix();
		this.updatePhysics();
		this.update();
	}
	
	void addToStage(Container parent) {
		parent.addChild(this);
	}
	
	void transform() {
		translate(this.x, this.y);
		rotate(this.rotation);
		scale(scaleX, scaleY);
	}
	
	void updateMatrix() {
		
	}
	
	void removeFromStage() {
		if (this.parent != null) this.parent.removeChild(this);
	}
}

class Container extends DisplayObject
{
	ArrayList<DisplayObject> children;

	Container() {
		super();
		
		this.children = new ArrayList<DisplayObject>();
	}
	
	void drawAll() {
		if (!this.visible) return;
		
		pushMatrix();
		pushStyle();
		
		this.transform();
		this.draw();
		
		for (int i = 0; i < this.children.size(); ++i) {
			DisplayObject child = this.children.get(i);
			
			child.drawAll();
		}
		
		popStyle();
		popMatrix();
	}
	
	void updateAll() {
		if (this.paused) return;

		this.updateStageMatrix();
		this.updatePhysics();
		this.update();
		
		for (int i = 0; i < this.children.size(); ++i) {
			DisplayObject child = this.children.get(i);
			
			child.updateAll();
		}
	}
	
	void addChild(DisplayObject child) {
		if (child.parent != null) child.parent.removeChild(child);
		this.children.add(child);
		child.parent = this;
	}
	
	void removeChild(DisplayObject child) {
		this.children.remove(child);
		child.parent = null;
	}
}

class MovableContainer extends Container
{
	float speedX;
	float speedY;
	float speedReduction;
	float angularSpeed;
	float angularSpeedReduction;
	
	MovableContainer() {
		this.speedX = 0;
		this.speedY = 0;
		this.speedReduction = 0.1;
		this.angularSpeed = 0;
		this.angularSpeedReduction = 0.1;
	}
	
	void updatePhysics() {
		this.x += this.speedX;
		this.y += this.speedY;
		
		this.rotation += this.angularSpeed;
		
		this.speedX *= (1.0 - this.speedReduction);
		this.speedY *= (1.0 - this.speedReduction);
		
		this.angularSpeed *= (1.0 - this.angularSpeedReduction);
	}
	
	void applyForce(float angle, float amount) {
		this.speedX += Util.angleToX(angle, amount);
		this.speedY += Util.angleToY(angle, amount);
	}
	
	void applyForceXY(float forceX, float forceY) {
		this.speedX += forceX;
		this.speedY += forceY;
	}
	
	void applyAngularForce(float amount) {
		this.angularSpeed += amount;
	}

}

class Stage extends Container
{
	
	Stage() {
		
	}
	
	void run() {
		this.updateAll();
		this.drawAll();
	}
	
	float getScreenWidth() {
		return width;
	}
	
	float getScreenHeight() {
		return height;
	}
	
	float getCenterX() {
		return width / 2.0f;
	}
	
	float getCenterY() {
		return height / 2.0f;
	}
	
}

class Rectangle extends DisplayObject
{
	float width;
	float height;
	int rectColor;
	int rectAlpha;
	float borderWeight;
	int borderColor;
	int borderAlpha;

	Rectangle(float width, float height) {
		super();
		
		this.width = width;
		this.height = height;

		this.w = width;
		this.h = height;
		
		this.rectColor = color(255);
		this.rectAlpha = 255;
		this.borderWeight = 1;
		this.borderColor = color(0);
		this.borderAlpha = 255;
	}
	
	void draw() {
		fill(this.rectColor, this.rectAlpha);
		strokeWeight(this.borderWeight);
		stroke(this.borderColor, this.borderAlpha);
		rect(0, 0, this.width, this.height);
	}
}

class Circle extends DisplayObject
{
	float width;
	float height;
	int circleColor;
	int circleAlpha;
	float borderWeight;
	int borderColor;
	int borderAlpha;
	
	Circle (float width, float height) {
		this.width = width;
		this.height = height;

		this.w = width;
		this.h = height;
		
		this.circleColor = color(255);
		this.circleAlpha = 255;
		this.borderWeight = 1;
		this.borderColor = color(0);
		this.borderAlpha = 255;
	}
	
	void draw() {
		fill(this.circleColor, this.circleAlpha);
		strokeWeight(this.borderWeight);
		stroke(this.borderColor, this.borderAlpha);
		ellipse(0, 0, this.width, this.height);
	}

}

class Image extends DisplayObject
{
	PImage pImage;
	int imageColor;
	int imageAlpha;
	private int _width;
	private int _height;
	
	Image (PImage pImage, int loadWidth, int loadHeight) {
		this.pImage = pImage;
		
		this.imageColor = color(255);
		this.imageAlpha = 255;
		
		this._width = loadWidth;
		this._height = loadHeight;

		this.w = loadWidth;
		this.h = loadHeight;
	}
	
	void draw() {
		if (pImage.width != this._width || pImage.height != this._height) {
			pImage.resize(this._width, this._height);
		}
		tint(this.imageColor, this.imageAlpha);
		image(this.pImage, 0, 0);
	}

}

class Text extends DisplayObject
{
	
	String content;
	float fontSize;
	int textColor;
	int textAlpha;
	int textAlignX;
	int textAlignY;
	
	Text(String content) {
		this.content = content;
		
		this.fontSize = 14;
		this.textColor = color(0);
		this.textAlpha = 255;
		this.textAlignX = CENTER;
		this.textAlignY = CENTER;
	}
	
	void draw() {
		textAlign(this.textAlignX, this.textAlignY);
		fill(this.textColor, this.textAlpha);
		textSize(this.fontSize);
		text(this.content, 0, 0);
	}

}

class RectangleButton extends Container
{
	
	int idleColor;
	int hoverColor;
	int pressedColor;
	Rectangle rectangle;
	Text textField;
	
	boolean pressedOnce;
	boolean releasedOnce;
	boolean holding;
	boolean hovering;
	
	RectangleButton(float width, float height, String content) {
		this.idleColor = color(200);
		this.hoverColor = color(240);
		this.pressedColor = color(160);
		
		this.rectangle = new Rectangle(width, height);
		this.rectangle.x = -width/2.0f;
		this.rectangle.y = -height/2.0f;
		this.rectangle.rectColor = this.idleColor;
		this.rectangle.addToStage(this);
		
		this.textField = new Text(content);
		this.textField.addToStage(this);
		
		this.pressedOnce = false;
		this.releasedOnce = false;
		this.holding = false;
		this.hovering = false;
	}
	
	void update() {
		float localMouseX = this.getLocalMouseX();
		float localMouseY = this.getLocalMouseY();
		
		this.pressedOnce = false;
		this.releasedOnce = false;
		this.holding = false;
		this.hovering = false;

		if (Util.pointInRectangle(localMouseX, localMouseY, this.rectangle.x, this.rectangle.y, this.rectangle.width, this.rectangle.height)) {
			if (Input.isMousePressedOnce(LEFT)) {
				this.pressedOnce = true;
				this.pressed();
			}
			if (Input.isMouseReleasedOnce(LEFT)) {
				this.releasedOnce = true;
				this.released();
			}
			if (Input.isMouseHolding(LEFT)) {
				this.holding = true;
				this.rectangle.rectColor = this.pressedColor;
			}
			else {
				this.hovering = true;
				this.rectangle.rectColor = this.hoverColor;
			}
		}
		else {
			this.rectangle.rectColor = this.idleColor;
		}
	}
	
	void pressed() {
		
	}

	void released() {
		
	}

}

class Repeater
{
	boolean triggered;
	float period;
	float count;
	
	Repeater(float period) {
		this.period = period;
		
		this.triggered = false;
	}
	
	void update() {
		++count;
		
		this.triggered = false;
		
		while (count > period) {
			this.triggered = true;
			count -= period;
		}
	}
}


static class Input
{
	
	static class InputHelper
	{
		
		HashMap<Integer, Boolean> pressedDetected;
		HashMap<Integer, Boolean> releasedDetected;
		HashMap<Integer, Boolean> pressedOnce;
		HashMap<Integer, Boolean> holding;
		HashMap<Integer, Boolean> releasedOnce;
		
		boolean anyPressedOnce;
		boolean anyReleasedOnce;
		boolean anyHolding;
		
		InputHelper() {
			this.pressedDetected = new HashMap<Integer, Boolean>();
			this.releasedDetected = new HashMap<Integer, Boolean>();
			this.pressedOnce = new HashMap<Integer, Boolean>();
			this.holding = new HashMap<Integer, Boolean>();
			this.releasedOnce = new HashMap<Integer, Boolean>();
			
			this.anyPressedOnce = false;
			this.anyReleasedOnce = false;
			this.anyHolding = false;
		}
		
		void pressed(Integer key) {
			this.pressedDetected.put(key, true);
		}
		
		void released(Integer key) {
			this.releasedDetected.put(key, true);
		}
		
		boolean isPressedOnce(Integer key) {
			Boolean value = this.pressedOnce.get(key);
			return value == null ? false : value;
		}
		
		boolean isReleasedOnce(Integer key) {
			Boolean value = this.releasedOnce.get(key);
			return value == null ? false : value;
		}
		
		boolean isHolding(Integer key) {
			Boolean value = this.holding.get(key);
			return value == null ? false : value;
		}
		
		boolean isAnyPressedOnce() {
			return this.anyPressedOnce;
		}
		
		boolean isAnyReleasedOnce() {
			return this.anyReleasedOnce;
		}
		
		boolean isAnyHolding() {
			return this.anyHolding;
		}
		
		void update() {
			for (Integer key : this.pressedOnce.keySet()) {
				this.pressedOnce.put(key, false);
			}
			this.anyPressedOnce = false;
			
			for (Integer key : this.releasedOnce.keySet()) {
				this.releasedOnce.put(key, false);
			}
			this.anyReleasedOnce = false;
			
			for (Integer key : this.pressedDetected.keySet()) {
				if (this.pressedDetected.get(key) == true) {
					this.pressedOnce.put(key, true);
					this.anyPressedOnce = true;
					this.pressedDetected.put(key, false);
					this.holding.put(key, true);
				}
			}
			
			for (Integer key : this.releasedDetected.keySet()) {
				if (this.releasedDetected.get(key) == true){
					this.releasedOnce.put(key, true);
					this.anyReleasedOnce = true;
					this.releasedDetected.put(key, false);
					this.holding.put(key, false);
				}
			}
			
			this.anyHolding = false;
			for (Integer key : this.holding.keySet()) {
				if (this.holding.get(key) == true) {
					this.anyHolding = true;
				}
			}
		}

	}
	
	static InputHelper mouseHelper = new Input.InputHelper();
	static InputHelper keyHelper = new Input.InputHelper();
	static InputHelper codedKeyHelper = new Input.InputHelper();
	
	static void mousePressed(int mouse) {
		mouseHelper.pressed(mouse);
	}
	
	static void mouseReleased(int mouse) {
		mouseHelper.released(mouse);
	}
	
	static void keyPressed(char key, int keyCode) {
		if (key == CODED) {
			codedKeyHelper.pressed(keyCode);
		}
		else {
			keyHelper.pressed(int(key));
		}
	}
	
	static void keyReleased(char key, int keyCode) {
		if (key == CODED) {
			codedKeyHelper.released(keyCode);
		}
		else {
			keyHelper.released(int(key));
		}
	}
	
	static void update() {
		mouseHelper.update();
		keyHelper.update();
		codedKeyHelper.update();
	}
	
	static boolean isMousePressedOnce(int mouse) {
		return mouseHelper.isPressedOnce(mouse);
	}
	
	static boolean isMouseReleasedOnce(int mouse) {
		return mouseHelper.isReleasedOnce(mouse);
	}
	
	static boolean isMouseHolding(int mouse) {
		return mouseHelper.isHolding(mouse);
	}
	
	static boolean isKeyPressedOnce(char key) {
		return keyHelper.isPressedOnce(int(key));
	}
	
	static boolean isKeyReleasedOnce(char key) {
		return keyHelper.isReleasedOnce(int(key));
	}
	
	static boolean isKeyHolding(char key) {
		return keyHelper.isHolding(int(key));
	}
	
	static boolean isCodedKeyPressedOnce(int codedKey) {
		return codedKeyHelper.isPressedOnce(codedKey);
	}
	
	static boolean isCodedKeyReleasedOnce(int codedKey) {
		return codedKeyHelper.isReleasedOnce(codedKey);
	}
	
	static boolean isCodedKeyHolding(int codedKey) {
		return codedKeyHelper.isHolding(codedKey);
	}
	
	static boolean isAnyMousePressedOnce() {
		return mouseHelper.isAnyPressedOnce();
	}
	
	static boolean isAnyMouseReleasedOnce() {
		return mouseHelper.isAnyReleasedOnce();
	}
	
	static boolean isAnyMouseHolding() {
		return mouseHelper.isAnyHolding();
	}
	
	static boolean isAnyKeyPressedOnce() {
		return keyHelper.isAnyPressedOnce() || codedKeyHelper.isAnyPressedOnce();
	}
	
	static boolean isAnyKeyReleasedOnce() {
		return keyHelper.isAnyReleasedOnce() || codedKeyHelper.isAnyReleasedOnce();
	}
	
	static boolean isAnyKeyHolding() {
		return keyHelper.isAnyHolding() || codedKeyHelper.isAnyHolding();
	}
}

static class Util
{
	static boolean pointInRectangle(float centerX, float centerY, float rectX, float rectY, float rectWidth, float rectHeight) {
		return centerX > rectX && centerY > rectY && centerX < rectX + rectWidth && centerY < rectY + rectHeight;
	}
	
	static boolean pointInRange(float centerX, float centerY, float x, float y, float distance) {
		float dx = (x - centerX);
		float dy = (y - centerY);
		return sqrt(dx * dx + dy * dy) < distance;
	}
	
	static float angleToX(float angle, float distance) {
		return cos(angle) * distance;
	}
	
	static float angleToY(float angle, float distance) {
		return sin(angle) * distance;
	}
	
	static float getAngle(float x, float y, float targetX, float targetY) {
		return atan2(targetY - y, targetX - x);
	}
	
	static float distance(float dx, float dy)
	{
		return sqrt(dx*dx + dy*dy);
	}
	
	static float wrap(float x, float divisor, float margin) {
		divisor += 2.0 * margin;
		return (((x + margin) % divisor + divisor) % divisor) - margin;
	}
	
	static float clamp(float val, float lower, float higher)
	{
		return val < lower ? lower : (val > higher ? higher : val);
	}
}

class Matrix {

	float a;
	float b;
	float c;
	float d;
	float tx;
	float ty;

	Matrix(float a, float b, float c, float d, float tx, float ty) {
		
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
		
	}


	Matrix clone () {
		
		return new Matrix (a, b, c, d, tx, ty);
		
	}


	void concatInverse (Matrix m) {
		
		float a1 = m.a * a + m.b * c;
		b = m.a * b + m.b * d;
		a = a1;
		
		float c1 = m.c * a + m.d * c;
		d = m.c * b + m.d * d;
		c = c1;
		
		float tx1 = m.tx * a + m.ty * c + tx;
		ty = m.tx * b + m.ty * d + ty;
		tx = tx1;
		
		//__cleanValues ();
		
	}
	
	void concat (Matrix m) {
		
		float a1 = a * m.a + b * m.c;
		b = a * m.b + b * m.d;
		a = a1;
		
		float c1 = c * m.a + d * m.c;
		d = c * m.b + d * m.d;
		c = c1;
		
		float tx1 = tx * m.a + ty * m.c + m.tx;
		ty = tx * m.b + ty * m.d + m.ty;
		tx = tx1;
		
		//__cleanValues ();
		
	}
	
	void createBox (float scaleX, float scaleY, float rotation, float tx, float ty) {
		
		//identity ();
		//rotate (rotation);
		//scale (scaleX, scaleY);
		//translate (tx, ty);
		
		if (rotation != 0) {
			
			float _cos = cos (rotation);
			float _sin = sin (rotation);
			
			a = _cos * scaleX;
			b = _sin * scaleY;
			c = -_sin * scaleX;
			d = _cos * scaleY;
			
		} else {
			
			a = scaleX;
			b = 0;
			c = 0;
			d = scaleY;
			
		}
		
		this.tx = tx;
		this.ty = ty;
		
	}


	boolean equals (Matrix matrix) {
		
		return (matrix != null && tx == matrix.tx && ty == matrix.ty && a == matrix.a && b == matrix.b && c == matrix.c && d == matrix.d);
		
	}


	void identity () {
		
		a = 1;
		b = 0;
		c = 0;
		d = 1;
		tx = 0;
		ty = 0;
		
	}


	void invert () {
		
		float norm = a * d - b * c;
		
		if (norm == 0) {
			
			a = b = c = d = 0;
			tx = -tx;
			ty = -ty;
			
		} else {
			
			norm = 1.0 / norm;
			float a1 = d * norm;
			d = a * norm;
			a = a1;
			b *= -norm;
			c *= -norm;
			
			float tx1 = - a * tx - c * ty;
			ty = - b * tx - d * ty;
			tx = tx1;
			
		}
		
		//__cleanValues ();
		
	}


	void rotate (float theta) {
		
		/*
		Rotate object "after" other transforms
			
		[  a  b   0 ][  ma mb  0 ]
		[  c  d   0 ][  mc md  0 ]
		[  tx ty  1 ][  mtx mty 1 ]
			
		ma = md = cos
		mb = sin
		mc = -sin
		mtx = my = 0
			
		*/
		
		float _cos = cos (theta);
		float _sin = sin (theta);
		
		float a1 = a * _cos - b * _sin;
		b = a * _sin + b * _cos;
		a = a1;
		
		float c1 = c * _cos - d * _sin;
		d = c * _sin + d * _cos;
		c = c1;
		
		float tx1 = tx * _cos - ty * _sin;
		ty = tx * _sin + ty * _cos;
		tx = tx1;
		
		//__cleanValues ();
		
	}


	void scale (float sx, float sy) {
		
		/*
			
		Scale object "after" other transforms
			
		[  a  b   0 ][  sx  0   0 ]
		[  c  d   0 ][  0   sy  0 ]
		[  tx ty  1 ][  0   0   1 ]
		*/
		
		a *= sx;
		b *= sy;
		c *= sx;
		d *= sy;
		tx *= sx;
		ty *= sy;
		
		//__cleanValues ();
		
	}


	void setRotation (float theta, float scale) {
		
		a = cos (theta) * scale;
		c = sin (theta) * scale;
		b = -c;
		d = a;
		
		//__cleanValues ();
		
	}


	void setTo (float a, float b, float c, float d, float tx, float ty) {
		
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
		
	}
	
	void translate (float dx, float dy) {
		
		tx += dx;
		ty += dy;
		
	}

	float transformInverseX (float px, float py) {
		
		float norm = a * d - b * c;
		
		if (norm == 0) {
			
			return -tx;
			
		} else {
			
			return (1.0 / norm) * (c * (ty - py) + d * (px - tx));
			
		}
		
	}

	float transformInverseY (float px, float py) {
		
		float norm = a * d - b * c;
		
		if (norm == 0) {
			
			return -ty;
			
		} else {
			
			return (1.0 / norm) * (a * (py - ty) + b * (tx - px));
			
		}
		
	}

	float transformX (float px, float py) {
		
		return px * a + py * c + tx;
		
	}


	float transformY (float px, float py) {
		
		return px * b + py * d + ty;
		
	}

}




// Wall
class Wall{
  
  ArrayList<DisplayObject> _wall = new ArrayList<DisplayObject>();
  DisplayObject obj;
  
  Wall(DisplayObject o){
    obj = o;
  }
  
  void addwall(DisplayObject wall){
    _wall.add(wall);
  }
  
  boolean circle_ornot(DisplayObject test){
    if (test instanceof Circle){
      return true;
    }
    else{
      return false;
    }
  }
  
  boolean circle_circle(float cx0, float cy0, float r0, float cx1, float cy1, float r1){
    float dxSQ = (cx1 - cx0)*(cx1 - cx0);
    float dySQ = (cy1 - cy0)*(cy1 - cy0);
    float rSQ = (r0 + r1)*(r0 + r1);
    float drSQ = (r0 - r1)*(r0 - r1);
    return (dxSQ + dySQ <= rSQ && dxSQ + dySQ >= drSQ);
  }
  
  boolean box_box(float ax0, float ay0, float ax1, float ay1, float bx0, float by0, float bx1, float by1){
  float topA = min(ay0, ay1);
  float botA = max(ay0, ay1);
  float leftA = min(ax0, ax1);
  float rightA = max(ax0, ax1);
  float topB = min(by0, by1);
  float botB = max(by0, by1);
  float leftB = min(bx0, bx1);
  float rightB = max(bx0, bx1);

  return !(botA <= topB  || botB <= topA || rightA <= leftB || rightB <= leftA);
}
  
  boolean overlap(DisplayObject neighbour){
        
      DisplayObject a = (DisplayObject) obj;
      DisplayObject b = (DisplayObject) neighbour;
      
      float ax1 = a.x + a.w;
      float ay1 = a.y + a.h;
      float bx1 = b.x + b.w;
      float by1 = b.y + b.h;
      return box_box(a.x, a.y, ax1, ay1, b.x, b.y, bx1, by1);
    
    
  }
  
  boolean overlaps(){
    
    for (int i = 0; i < _wall.size(); i++) {
     if(overlap(_wall.get(i))){
       return true;
     }
    }
    return false;
  }
  
  void draw(){
  }
}

