class ConvexHull {
  ArrayList<PVector> hullGW;
  ArrayList<PVector> hullGS;
  
  ConvexHull(ArrayList<PVector> points) {
    this.hullGW = giftWrapping(points);
    this.hullGS = grahamScan(points);
  }
  
  void update(ArrayList<PVector> points) {
    this.hullGW = giftWrapping(points);
    this.hullGS = grahamScan(points);
  }
  
  ArrayList<PVector> grahamScan(ArrayList<PVector> points) {
    if (points.size() < 3) {
     return new ArrayList<PVector>();  
    } 
    
    ArrayList<PVector> hull = new ArrayList<PVector>();
    
    PVector pivot = findPivot(points);
    ArrayList<PVector> sortedPoints = new ArrayList<>(points);
    sortedPoints.remove(pivot);
    sortedPoints.sort((p1, p2) -> {
      float angle1 = PVector.sub(p1, pivot).heading();
      float angle2 = PVector.sub(p2, pivot).heading();
      if (angle1 != angle2) {
          return Float.compare(angle1, angle2);
      }
      return Float.compare(PVector.dist(pivot, p1), PVector.dist(pivot, p2));
    });
    
    hull.add(pivot);
    hull.add(sortedPoints.get(0));
    hull.add(sortedPoints.get(1));

    for (int i = 2; i < sortedPoints.size(); i++) {
      PVector current = sortedPoints.get(i);

      while (hull.size() > 1 && orientation(hull.get(hull.size() - 2), hull.get(hull.size() - 1), current) <= 0) {
        hull.remove(hull.size() - 1); // Remove the last point if it's not counter-clockwise
      }

      hull.add(current); 
    }
    return hull;
  }
  
  ArrayList<PVector> giftWrapping(ArrayList<PVector> points) {
    if (points.size() < 3) {
     return new ArrayList<PVector>();  
    } 
    
    ArrayList<PVector> hull = new ArrayList<PVector>();
    
    PVector rightmostPoint = findRightmostPoint(points);
    PVector currentPoint = rightmostPoint;
    PVector nextPoint = null;
    
    do {
      hull.add(currentPoint);  
      nextPoint = points.get(0); 
      
      for (PVector candidate : points) {
        if (nextPoint == currentPoint || orientation(currentPoint, nextPoint, candidate) > 0) {
          nextPoint = candidate;
        }
      }
  
      currentPoint = nextPoint; 
  
    } while (currentPoint != rightmostPoint); 
    
    return hull;
  }
  
  PVector findPivot(ArrayList<PVector> points) {
    PVector pivot = points.get(0);
    for (PVector p : points) {
      if (p.y < pivot.y || (p.y == pivot.y && p.x > pivot.x)) {
        pivot = p;
      }
    }
    return pivot;
  }
  
  PVector findRightmostPoint(ArrayList<PVector> points) {
    PVector rightmost = points.get(0);
    for (PVector p : points) {
      if (p.x > rightmost.x) {
        rightmost = p;
      }
    }
    return rightmost;
  }
  
  int orientation(PVector a, PVector b, PVector c) {
    float value = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
    if (value > 0) {
      return 1; // Counter-clockwise
    }
    if (value < 0) {
      return -1; // Clockwise
    } 
    return 0; // Collinear
  }
  
}
