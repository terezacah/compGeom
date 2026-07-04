class Delaunay {
  ArrayList<DEdge> DT;
  ArrayList<Triangle> triangles;
  ArrayList<DEdge> AEL;
  
  Delaunay(ArrayList<PVector> points) {
    this.AEL = new ArrayList<DEdge>();
    this.triangles = new ArrayList<Triangle>();
    this.DT = triangulate(points);
  }
  
  void update(ArrayList<PVector> points) {
    this.AEL = new ArrayList<DEdge>();
    this.triangles = new ArrayList<Triangle>();
    this.DT = triangulate(points);
  }
  
  ArrayList<DEdge> triangulate(ArrayList<PVector> points) {  
    if (points.size() < 3) {
     return new ArrayList<DEdge>();  
    } 
    
    ArrayList<DEdge> resultDT = new ArrayList<DEdge>();
    this.AEL = new ArrayList<DEdge>();
    
    // p1 - random point from points
    PVector p1 = points.get(0);
    // p2 - the closest point to p1
    PVector p2 = closestPoint(p1, points);
    // create edge p1p2
    DEdge e = new DEdge(p1, p2);
    
    // find point p with smallest delaunay distance left from e
    PVector p = minDelDistLeft(e, points); 
    
    DEdge e2;
    DEdge e3;
    if (p == null) {
      e = new DEdge(p2, p1);
      p = minDelDistLeft(e, points);
      e2 = new DEdge(p1, p);
      e3 = new DEdge(p, p2);
    }
    else {
      e2 = new DEdge(p2, p);
      e3 = new DEdge(p, p1);
    }
    
    addTriangle(p2, p, p1);
    
    // add e, e2, e3 to AEL
    this.AEL.add(e);
    this.AEL.add(e2);
    this.AEL.add(e3);
     
    while (!this.AEL.isEmpty()) {
      // get the first edge from AEL
      e = this.AEL.get(0);
      // swap orientation of e
      DEdge twin = new DEdge(e.end, e.start);
      // find p with smallest DD left from e
      p = minDelDistLeft(twin, points);
      if (p != null) {

        e2 = new DEdge(twin.end, p);
        e3 = new DEdge(p, twin.start);
        
        // add to AEL if these or their flips are not in AEL or DT
        addToAEL(e2);
        addToAEL(e3);
        
        resultDT.add(e2);
        resultDT.add(e3);
        //println("Triangle formed: " + e2.start + ", " + e2.end + ", " + e3.end);
        addTriangle(e2.start, e2.end, e3.end);
      }
      resultDT.add(twin);
      this.AEL.remove(0);
    }
    return resultDT;
  } 
  
  void addToAEL(DEdge e) {
    for (int i = 0; i < this.AEL.size(); i++) {
      DEdge e2 = this.AEL.get(i);
      if (e2.start == e.start && e2.end == e.end) {
        // e already in AEL
        return;
      }
      if (e2.end == e.start && e2.start == e.end) {
        // twin in AEL
        this.AEL.remove(i);
        return;
      }
    }
    this.AEL.add(e);
  }
  
  PVector minDelDistLeft(DEdge e, ArrayList<PVector> points) {
    PVector result = null;
    float minDist = Float.MAX_VALUE;
    
    for (PVector p : points) {
      if (isOnLeft(e, p)) {
        Circle cC = circumCircle(e.start, e.end, p);
        float delDist;
        //if (cC != null) {
        if (isOnLeft(e, cC.c)) {
          // p, c - same halfplane
          delDist = cC.r;
        } else {
          // p, c - opposite halfplane
          delDist = - cC.r;
        }
        
        if (delDist < minDist) {
          minDist = delDist;
          result = p;
        }
      }
    }
    return result;
  }
  
  Circle circumCircle(PVector p1, PVector p2, PVector p3) {
    float cp = crossProduct(p1, p2, p3);
    if (cp != 0) {
      float p1Sq = sq(p1.x) + sq(p1.y);
      float p2Sq = sq(p2.x) + sq(p2.y);
      float p3Sq = sq(p3.x) + sq(p3.y);
      float num = p1Sq * (p2.y - p3.y) + p2Sq * (p3.y - p1.y) + p3Sq * (p1.y - p2.y);
      float cx = num / (2.0 * cp);
      num = p1Sq * (p3.x - p2.x) + p2Sq * (p1.x - p3.x) + p3Sq * (p2.x - p1.x);
      float cy = num / (2.0 * cp);
      PVector c = new PVector(cx, cy);
      float r = pointDistance(c, p1);
      return new Circle(c, r);
    }
    return null;
  }
  
  boolean isOnLeft(DEdge e, PVector p) {
    return crossProduct(e.start, e.end, p) > 0;
  }
  
  float crossProduct(PVector p1, PVector p2, PVector p3) {
    float u1 = p2.x - p1.x;
    float v1 = p2.y - p1.y;
    float u2 = p3.x - p1.x;
    float v2 = p3.y - p1.y;
    return u1 * v2 - v1 * u2; // > 0 if p3 is to the left of edge p1->p2
  }
  
  PVector closestPoint(PVector p, ArrayList<PVector> points) {
    PVector closest = null;
    float minDist = Float.MAX_VALUE;
    
    for (PVector p2 : points) {
      if (p2.x != p.x || p2.y != p.y) {
        float dist = pointDistance(p, p2);
        if (dist < minDist) {
          closest = p2;
          minDist = dist;
        }
      }
    }
    return closest;
  }
  
  float pointDistance(PVector p1, PVector p2) {
    return sqrt(sq(p1.x - p2.x) + sq(p1.y - p2.y));
  }
  
  void addTriangle(PVector a, PVector b, PVector c) {
    if (crossProduct(a, b, c) < 0) {
      PVector temp = b;
      b = c;
      c = temp;
    }
    this.triangles.add(new Triangle(a, b, c));
  }
  
}

class Triangle {
  PVector a, b, c;
  
  Triangle(PVector a, PVector b, PVector c) {
    this.a = a;
    this.b = b;
    this.c = c;
  }
  
  PVector circumcenter() {
    float D = 2 * (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y));
    float ux = ((sq(a.x) + sq(a.y)) * (b.y - c.y) + (sq(b.x) + sq(b.y)) * (c.y - a.y) + (sq(c.x) + sq(c.y)) * (a.y - b.y)) / D;
    float uy = ((sq(a.x) + sq(a.y)) * (c.x - b.x) + (sq(b.x) + sq(b.y)) * (a.x - c.x) + (sq(c.x) + sq(c.y)) * (b.x - a.x)) / D;
    
    return new PVector(ux, uy);
  }
}


class DEdge {
  PVector start;
  PVector end;
  
  DEdge(PVector start, PVector end) {
    this.start = start;
    this.end = end;
  }
}


class Circle {
  PVector c;
  float r;
  
  Circle(PVector c, float r) {
    this.c = c;
    this.r = r;
  }
}
