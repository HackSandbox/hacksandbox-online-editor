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