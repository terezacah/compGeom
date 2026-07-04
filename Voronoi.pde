class Voronoi {
  ArrayList<DEdge> edges;
  ArrayList<PVector> centers;

  Voronoi(ArrayList<Triangle> dt) {
    this.centers = new ArrayList<PVector>();
    this.edges = makeVoronoi(dt);
  }

  void update(ArrayList<Triangle> dt) {
    this.centers = new ArrayList<PVector>();
    this.edges = makeVoronoi(dt);
  }

  ArrayList<DEdge> makeVoronoi(ArrayList<Triangle> dt) {
    ArrayList<DEdge> result = new ArrayList<DEdge>();
    ArrayList<ArrayList<DEdge>> foo = new ArrayList<ArrayList<DEdge>>(dt.size());
    ArrayList<Boolean> inside = new ArrayList<Boolean>();

    for (Triangle t : dt) {
      PVector p = t.circumcenter();
      centers.add(p);
      inside.add(isPointInsideTriangle(p, t));
      ArrayList<DEdge> edges = new ArrayList<DEdge>();
      edges.add(new DEdge(t.a, t.b));
      edges.add(new DEdge(t.b, t.c));
      edges.add(new DEdge(t.c, t.a));
      foo.add(edges);
    }

    for (int i = 0; i < dt.size(); i++) {
      Triangle t1 = dt.get(i);
      
      for (int j = i + 1; j < dt.size(); j++) {
        Triangle t2 = dt.get(j);
        
        if (shareEdge(t1, t2)) {
          PVector center1 = centers.get(i);
          PVector center2 = centers.get(j);
          result.add(new DEdge(center1, center2));
          
          foo.get(i).removeIf(e -> edgeBelongsToTriangle(e, t2));
          foo.get(j).removeIf(e -> edgeBelongsToTriangle(e, t1));
        }
      }
    }

    for (int i = 0; i < foo.size(); i++) {
      PVector center = centers.get(i);
      for (DEdge edge : foo.get(i)) {
        PVector midpoint = new PVector((edge.start.x + edge.end.x) / 2, (edge.start.y + edge.end.y) / 2);
        PVector direction = PVector.sub(midpoint, center);
        float screenEdgeLength = max(width, height); 
        PVector extendedEndpoint;
        if (inside.get(i)) {
          extendedEndpoint = PVector.add(midpoint, PVector.mult(direction, screenEdgeLength));
          result.add(new DEdge(center, extendedEndpoint));
        }
        else {
          if (crossProduct(edge.start, edge.end, center) < 0) {
            extendedEndpoint = PVector.add(midpoint, PVector.mult(PVector.mult(direction, -1), screenEdgeLength));
            result.add(new DEdge(center, extendedEndpoint));
          }
          else {
            extendedEndpoint = PVector.add(midpoint, PVector.mult(direction, screenEdgeLength));
            result.add(new DEdge(center, extendedEndpoint));
          }
        }        
      }
    }
    return result;
  }

  boolean shareEdge(Triangle t1, Triangle t2) {
    PVector[] t1Vertices = {t1.a, t1.b, t1.c};
    PVector[] t2Vertices = {t2.a, t2.b, t2.c};
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        PVector p1 = t1Vertices[i];
        PVector p2 = t1Vertices[(i + 1) % 3];
        PVector p3 = t2Vertices[j];
        PVector p4 = t2Vertices[(j + 1) % 3];
        
        if ((p1.equals(p3) && p2.equals(p4)) || (p1.equals(p4) && p2.equals(p3))) {
          return true;
        }
      }
    }
    return false; 
  }
  
  boolean edgeBelongsToTriangle(DEdge edge, Triangle t) {
    return (edge.start.equals(t.a) && edge.end.equals(t.b)) ||
           (edge.start.equals(t.b) && edge.end.equals(t.c)) ||
           (edge.start.equals(t.c) && edge.end.equals(t.a)) ||
           (edge.start.equals(t.b) && edge.end.equals(t.a)) ||
           (edge.start.equals(t.c) && edge.end.equals(t.b)) ||
           (edge.start.equals(t.a) && edge.end.equals(t.c));
  }
  
  boolean isPointInsideTriangle(PVector p, Triangle t) {
    float cross1 = crossProduct(t.a, t.b, p);
    float cross2 = crossProduct(t.b, t.c, p);
    float cross3 = crossProduct(t.c, t.a, p);
  
    return (cross1 >= 0 && cross2 >= 0 && cross3 >= 0) || (cross1 <= 0 && cross2 <= 0 && cross3 <= 0);
  }
  
  float crossProduct(PVector p1, PVector p2, PVector p3) {
    float u1 = p2.x - p1.x;
    float v1 = p2.y - p1.y;
    float u2 = p3.x - p1.x;
    float v2 = p3.y - p1.y;
    return u1 * v2 - v1 * u2; // > 0 if p3 is to the left of edge p1->p2
  }
}
