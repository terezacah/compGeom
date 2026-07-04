import java.util.Stack;

class Triangulation {
    ArrayList<Edge> edges;
  
    Triangulation(ArrayList<PVector> points) {
        edges = triangulate(points);
    }
    
    void update(ArrayList<PVector> points) {
      edges = triangulate(points);
    }
    
    ArrayList<Edge> triangulate(ArrayList<PVector> points) {
      if (points.size() < 3) {
        return new ArrayList<Edge>();
      }
      ArrayList<PVector> sortedPoints = sortPoints(points);
      PVector minP = sortedPoints.get(0);
      PVector maxP = sortedPoints.get(sortedPoints.size() - 1);
      
      ArrayList<PVector> leftPath = new ArrayList<>();
      ArrayList<PVector> rightPath = new ArrayList<>();

      boolean addingToRightPath = true; 
      for (PVector point : points) {
        if (point.equals(maxP)) {
          addingToRightPath = false;
          leftPath.add(point);
          rightPath.add(point);
        } 
        else if (point.equals(minP)) {
          addingToRightPath = true;
          rightPath.add(point);
          leftPath.add(point);
        } 
        else {
          if (addingToRightPath) {
              rightPath.add(point);
          } else {
              leftPath.add(point);
          }
        }
      }
      
      edges = new ArrayList<Edge>();
  
      Stack<PVector> stack = new Stack<PVector>();
      stack.push(sortedPoints.get(0));
      stack.push(sortedPoints.get(1));
  
      for (int i = 2; i < sortedPoints.size(); i++) { 
        PVector vi = sortedPoints.get(i);   

        if (isOnSamePath(stack.peek(), vi, rightPath, leftPath)) {
          PVector vk = stack.peek();
          while (!stack.empty() && isOnSamePath(stack.peek(), vi, rightPath, leftPath)) {
            vk = stack.peek();
            edges.add(new Edge(vi, stack.pop()));
          }
          stack.push(vk);
          stack.push(vi);        
        } 
        else {
          PVector top = stack.peek();
          while (!stack.empty()) {
            edges.add(new Edge(vi, stack.pop()));
          }
          stack.push(top);
          stack.push(vi);
        }
      }

      
      return edges;
    }
  
    boolean isOnSamePath(PVector vj, PVector vi, ArrayList<PVector> rightPath, ArrayList<PVector> leftPath) {
      return (rightPath.contains(vj) && rightPath.contains(vi)) || (leftPath.contains(vj) && leftPath.contains(vi));
    }
    
    boolean isOnLeftPath(PVector v, PVector minP, PVector maxP) {
      return (v.x <= minP.x && v.x <= maxP.x);
    }
    
    boolean isOnRightPath(PVector v, PVector minP, PVector maxP) {
      return (v.x >= minP.x && v.x >= maxP.x);
    }
  
    ArrayList<PVector> sortPoints(ArrayList<PVector> points) {
        ArrayList<PVector> sortedPoints = new ArrayList<PVector>(points);
        sortedPoints.sort((a, b) -> {
            if (a.y != b.y) { 
              return Float.compare(b.y, a.y); 
            } 
            return Float.compare(a.x, b.x); 
        });
        return sortedPoints;
    }
}

class Edge {
    PVector start, end;
  
    Edge(PVector start, PVector end) {
        this.start = start;
        this.end = end;
    }
}
