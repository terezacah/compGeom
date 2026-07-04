class KdTree {
  KdNode root;
  ArrayList<Edge> lines;
  ArrayList<Integer> dir;
  
  KdTree(ArrayList<PVector> points) {
    this.lines = new ArrayList<Edge>();
    this.dir = new ArrayList<Integer>();
    this.root = buildTree(points, 0, new PVector(0, width), new PVector(0, height));
  }
  
  void update(ArrayList<PVector> points) {
    this.lines = new ArrayList<Edge>();
    this.dir = new ArrayList<Integer>();
    this.root = buildTree(points, 0, new PVector(0, width), new PVector(0, height));
  }
  
  KdNode buildTree(ArrayList<PVector> points, int depth, PVector xRange, PVector yRange) {
    if (points.isEmpty()) {
      return null;
    }
    
    if (points.size() == 1) {
      int medianIndex = points.size() / 2;
      PVector median = points.get(medianIndex);
      
      if (depth % 2 == 0) {
        PVector start = new PVector(median.x, yRange.x);
        PVector end = new PVector(median.x, yRange.y);
        this.dir.add(0);
        this.lines.add(new Edge(start, end));
      } else {
        PVector start = new PVector(xRange.x, median.y);
        PVector end = new PVector(xRange.y, median.y);
        this.dir.add(1);
        this.lines.add(new Edge(start, end));
      }
      return new KdNode(points.get(0), depth);
    }
    
    points.sort((p1, p2) -> {
      if (depth % 2 == 0) {
        return Float.compare(p1.x, p2.x);
      } else {
        return Float.compare(p1.y, p2.y);
      }
    });
  
    int medianIndex = points.size() / 2;
    PVector median = points.get(medianIndex);
    
    KdNode node = new KdNode(median, depth);
    if (depth % 2 == 0) {
      PVector start = new PVector(median.x, yRange.x);
      PVector end = new PVector(median.x, yRange.y);
      this.dir.add(0);
      this.lines.add(new Edge(start, end));
    } else {
      PVector start = new PVector(xRange.x, median.y);
      PVector end = new PVector(xRange.y, median.y);
      this.dir.add(1);
      this.lines.add(new Edge(start, end));
    }
    
    ArrayList<PVector> P1 = new ArrayList<>(points.subList(0, medianIndex));
    ArrayList<PVector> P2 = new ArrayList<>(points.subList(medianIndex, points.size()));
  
    PVector yRangeP1; 
    PVector xRangeP1; 
    PVector yRangeP2; 
    PVector xRangeP2;
    if (depth % 2 == 0) {
      xRangeP1 = new PVector(xRange.x, median.x);
      xRangeP2 = new PVector(median.x, xRange.y);
      yRangeP1 = yRange;
      yRangeP2 = yRange;
    }
    else {
      yRangeP1 = new PVector(yRange.x, median.y);
      yRangeP2 = new PVector(median.y, yRange.y);
      xRangeP1 = xRange;
      xRangeP2 = xRange;
    }
    
    node.lesser = buildTree(P1, depth + 1, xRangeP1, yRangeP1);
    
    if (node.lesser != null) {
        node.lesser.parent = node;
    }
    
    node.greater = buildTree(P2, depth + 1, xRangeP2, yRangeP2);
    
    if (node.greater != null) {
      node.greater.parent = node;
    }
    return node;
  }
}

class KdNode {
  int k = 2;
  int depth = 0;
  PVector point = null;
  PVector linePoint1 = null;
  PVector linePoint2 = null;
  KdNode parent = null;
  KdNode lesser = null;
  KdNode greater = null;
  
  KdNode(PVector point, int depth) {
    this.point = point;
    this.depth = depth;
  }
}
