int pointSize = 10;
int batchSize = 5;

PVector selectedPoint = null;
boolean dragging = false;

ArrayList<PVector> points;

ConvexHull convexHull;
Triangulation triangulation;
Delaunay delaunay;
Voronoi voronoi;
KdTree tree;

boolean showGiftWrapping = false;
boolean showGrahamScan = false;
boolean showTriangulation = false;
boolean showDelaunay = false;
boolean showVoronoi = false;
boolean showKdTree = false;

void setup() {
  fullScreen();
  //size(1000, 800);
  background(250);
  stroke(0);
  strokeWeight(pointSize);
  
  points = new ArrayList<PVector>();
  
  for (int i = 0; i < batchSize; i++) {
    points.add(new PVector(random(width), random(height)));
  }
  
  convexHull = new ConvexHull(points);
  triangulation = new Triangulation(convexHull.hullGW);
  delaunay = new Delaunay(points);
  voronoi = new Voronoi(delaunay.triangles);
  tree = new KdTree(points);
}

void draw() {
  background(250);
  
  stroke(0);
  strokeWeight(pointSize);
  for (PVector vec : points) {
    point(vec.x, vec.y);
  }
  
  if (showGiftWrapping) {
    stroke(44, 62, 80);
    strokeWeight(2);
    noFill();
    
    beginShape();
    for (PVector v : convexHull.hullGW) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
  }
  
  if (showGrahamScan) {
    stroke(241, 196, 15);
    strokeWeight(2);
    noFill();
    
    beginShape();
    for (PVector v : convexHull.hullGS) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
  }
  
  if (showKdTree) {
    strokeWeight(2);
    noFill();
    
    for (int i = 0; i < tree.lines.size(); i++) {
      Edge e = tree.lines.get(i);
      if (tree.dir.get(i) == 0) {
        stroke(155, 89, 182);
      }
      else {
        stroke(189, 195, 199);
      }
      line(e.start.x, e.start.y, e.end.x, e.end.y);
    }
  }
  
  if (showTriangulation) {
    stroke(44, 62, 80);
    strokeWeight(2);
    noFill();
    
    for (Edge e : triangulation.edges) {
      line(e.start.x, e.start.y, e.end.x, e.end.y);
    }
  }
  
  if (showDelaunay) {
    stroke(52, 152, 219);
    strokeWeight(2);
    noFill();
    
    //for (DEdge e : delaunay.DT) {
    //  line(e.start.x, e.start.y, e.end.x, e.end.y);
    //}
    
    for (Triangle t : delaunay.triangles) {
      line(t.a.x, t.a.y, t.b.x, t.b.y);
      line(t.b.x, t.b.y, t.c.x, t.c.y);
      line(t.c.x, t.c.y, t.a.x, t.a.y);
    }
  }
  
  if (showVoronoi) {
    stroke(231, 76, 60);
    noFill();
    
    strokeWeight(8);
    for (PVector e : voronoi.centers) {
      point(e.x, e.y);
    }
    
    strokeWeight(2);
    for (DEdge e : voronoi.edges) {
      line(e.start.x, e.start.y, e.end.x, e.end.y);
    }
  }
  
  addLegend();
}

void addLegend() {
  fill(0);
  textSize(20);
  textAlign(LEFT);
  text("- left click to add points", 50, 100);
  text("- right click to delete points", 50, 120);
  text("- click and drag to move points", 50, 140);
  text("- c : clear scene", 50, 160);
  text("- r : generate 5 random points", 50, 180);
  text("- w : gift wrapping", 50, 200);
  text("- s : graham scan", 50, 220);
  text("- k : kd tree", 50, 240);
  text("- t : triangulation", 50, 260);
  text("- d : delaunay triangulation", 50, 280);
  text("- v : voronoi diagram", 50, 300);
  text("- u : update data structures after a change", 50, 320);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    selectedPoint = getPointUnderCursor();
    if (selectedPoint == null) {
      points.add(new PVector(mouseX, mouseY));
      updateAll();
    } else {
      dragging = true; 
    }
  } else if (mouseButton == RIGHT) {
    PVector toDelete = getPointUnderCursor();
    if (toDelete != null) {
      points.remove(toDelete);
      updateAll();
    }
  }
}

void mouseDragged() {
  if (dragging && selectedPoint != null) {
    selectedPoint.x = mouseX;
    selectedPoint.y = mouseY;
  }
}

void mouseReleased() {
  dragging = false;
  selectedPoint = null;
  updateAll();
}

PVector getPointUnderCursor() {
  for (PVector point : points) {
    float d = dist(mouseX, mouseY, point.x, point.y);
    if (d <= pointSize / 2) {
      return point;
    }
  }
  return null;
}

void keyPressed() {
  if (key == 'c') {  
    background(250);
    points.clear();
    updateAll();
  } 
  if (key == 'r') {  
    for (int i = 0; i < batchSize; i++) {
      points.add(new PVector(random(width), random(height)));
    }
  } 
  if (key == 'w') {
    showGiftWrapping = !showGiftWrapping;
  }
  if (key == 's') {
    showGrahamScan = !showGrahamScan;
  }
  if (key == 'k') {
    showKdTree = !showKdTree;
  }
  if (key == 't') {
    showTriangulation = !showTriangulation;
    showGiftWrapping = showTriangulation;
  }
  if (key == 'd') {
    showDelaunay = !showDelaunay;
  }
  if (key == 'v') {
    showVoronoi = !showVoronoi;
  }
  if (key == 'u') {
    updateAll();
  }
}

void updateAll() {
  convexHull.update(points);
  triangulation.update(convexHull.hullGW);
  delaunay.update(points);
  voronoi.update(delaunay.triangles);
  tree.update(points);
}
