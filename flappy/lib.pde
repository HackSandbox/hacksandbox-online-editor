class DisplayObject 
{
	Container parent;
	float x;
	float y;
	float rotation;
	float scaleX;
	float scaleY;
	boolean visible;
	boolean paused;

	DisplayObject() {
		this.parent = null;
		this.x = 0;
		this.y = 0;
		this.rotation = 0;
		this.scaleX = 1;
		this.scaleY = 1;
		this.visible = true;
		this.paused = false;
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
	
	void update() {
		
	}
	
	void updateAll() {
		if (this.paused) return;
		
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
	int _width;
	int _height;
	boolean _resized;
	
	Image (PImage pImage, int width, int height) {
		this.pImage = pImage;
		
		this.imageColor = color(255);
		this.imageAlpha = 255;
		
		this._width = width;
		this._height = height;
		
		this._resized = false;
	}
	
	void draw() {
		if (!this._resized) {
			pImage.resize(this._width, this._height);
			this._resized = true;
		}
		tint(this.imageColor, this.imageAlpha);
		image(this.pImage, 0, 0);
	}

}

static class Util
{
	static boolean isInsideRectangle(float centerX, float centerY, float rectX, float rectY, float rectWidth, float rectHeight) {
		return centerX > rectX && centerY > rectY && centerX < rectWidth && centerY < rectHeight;
	}
	
	static boolean pointInRange(float centerX, float centerY, float x, float y, float distance) {
		float dx = (x - centerX);
		float dy = (y - centerY);
		return sqrt(dx * dx + dy * dy) < distance;
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


