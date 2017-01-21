class Wall{
  
  ArrayList<DisplayObject> _wall = new ArrayList<DisplayObject>();
  DisplayObject _actor;
  
  Wall(DisplayObject obj){
    _actor = obj;
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
    
    // System.out.println(_actor.getClass());
    if (_actor instanceof Circle && neighbour instanceof Circle){
      Circle a = (Circle) _actor;
      Circle b = (Circle) neighbour;
      return circle_circle(_actor.x, _actor.y, a.getwidth(), neighbour.x, neighbour.y, b.getwidth());
    }
    else if (_actor instanceof Image && neighbour instanceof Rectangle) {
      Image a = (Image) _actor;
      Rectangle b = (Rectangle) neighbour;
      return box_box(a.x, a.y, a.x + a._width, a.x + a._height, b.x, b.y, b.x + b.width, b.x + b.height);
    }
    else if (_actor instanceof Image && neighbour instanceof Image) {
      Image a = (Image) _actor;
      Image b = (Image) neighbour;
      return box_box(a.x, a.y, a.x + a._width, a.x + a._height, b.x, b.y, b.x + b._width, b.x + b._height);
    }
    else if (_actor instanceof Rectangle && neighbour instanceof Image) {
      Rectangle a = (Rectangle) _actor;
      Image b = (Image) neighbour;
      return box_box(a.x, a.y, a.x + a.width, a.x + a.height, b.x, b.y, b.x + b._width, b.x + b._height);
    }
    else {
      Rectangle a = (Rectangle) _actor;
      Rectangle b = (Rectangle) neighbour;
      return box_box(a.x, a.y, a.x + a.width, a.x + a.height, b.x, b.y, b.x + b.width, b.x + b.height);
    }
    
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