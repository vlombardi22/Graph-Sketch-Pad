PShape ellipse;
int ind1; // first nod clicked
int ind2; // second node clicked 
boolean move; // move mode
boolean del; // delete mode 
boolean guard; // debouncer variable
boolean paint; // color mode
boolean directed; // is directed graph
int label; // label index
PFont f; // text font

ArrayList<verti> v_list = new ArrayList<verti>(); // vertex list
ArrayList<edge> e_list = new ArrayList<edge>(); // edge list

class edge {
  private verti v1; // start edge
  private verti v2; // end edge
  private int offset; // what parrallel line is this
  private boolean blocked; // temporarily "deletes" edge for bridge check
  private boolean bridge; // is this a bridge//

  /**
  a = v1
  b = v2
  offset = offset
  */
  edge(verti a, verti b, int offset) {
    v1 = a;
    v2 = b;
    v1.addEdge(this);
    v2.addEdge(this);
    this.offset = offset;
    v1.setDegree(1);
    v1.setOut(1);

    v2.setDegree(1);
    v2.setIn(1);
    blocked = false;
    bridge = false;
  }

  /**
  bridges setter
  */
  void setBridge(boolean b) {
    bridge = b;
  }

  /**
  blocked setter
  */
  void setBlocked(boolean b) {
    blocked = b;
  }

  /**
  Blockeds getter
  */
  boolean isBlocked() {
    return blocked;
  }


  /**
  deletes edge when connecting vertex is deleted and readjusts degrees
  */
  boolean safeDel(verti node) {
    if (node == v1 || node == v2) {
      if (node == v1) {
        v2.setDegree(-1);
        v2.setIn(-1);
      } else {
        v1.setDegree(-1); 
        v1.setOut(-1);
      }
      return true;
    } else {
      return false;
    }
  }
  
  /**
  checks if node is a loop
  */
  boolean isLoop() {
    if (v1 == v2) {
      return true;
    }
    return false;
  }
  
  /**
  method hteat checks if we are making a loop
  */
  boolean isLoop(verti a, verti b) {
    if (a == v1 && b == v2) {
      return true;
    } else if (a == v2 && b == v1) {
      return true;
    }
    return false;
  }

  /**
  shorthand method for decremending degrees upon deletion of and edge
  */
  void del() {
    v1.setDegree(-1);
    v1.setOut(-1);
    v2.setDegree(-1);
    v2.setIn(-1);
  }


  /**
  checks if given node is the sending node.
  */
  boolean isout(verti temp) {
    if (temp == v1) {
      return true;
    }
    return false;
  }

  /**
  returns the labels 
  */
  int[] coords() {
    int[] temp = {v1.getLabel(), v2.getLabel()}; 
    return temp;
  }

  /**
  gets slope of the line
  */
  float slope() {
    return ((float)v2.getY()-v1.getY())/((float) v2.getX()-v1.getX()); //float(v2.getY()-v1.getY())/float(v2.getX()-v1.getX());
  }

  /** 
  returns midpoint for bridges
  */
  float[] midpoint() {

    float m = slope();
    float x = v2.getX()-((v2.getX()-v1.getX())/2);
    float b = v1.getY()-m*(v1.getX());
    float y = m*x+b;
    float[] temp = {x, y}; 
    return temp;
  }



  //return True if matches
  boolean ismatch(verti v) {
    if (v1 == v2) {
      return false;
    } else if (v1 == v) {
      if (v2.getc() > 0) {
        return (v2.getc() == v.getc());
      }
    } else if (v2 == v) {
      if (v1.getc() > 0) {
        return (v1.getc() == v.getc());
      }
    }
    return false;
  }

  /**
  method helps determine if a user is hovering the mouse over and edge
  */
  boolean isClose(int x, int y) {
    if (v1 != v2) {
      float m = slope();

      float b = (v1.getY()+(offset*5))-m*(v1.getX()+(offset*10));
      float y2 = m*x+b;
      if (y2 >= (y-10) && y2 <= (y+10)) {
        return true;
      }
    } else {
      int x2 = v1.getX()+40;
      int y2 = v1.getY()+40;
      int z = 40 + (offset*20);
      int zz = z - 20;
      if (x2 < x+z && x2 > x-z && y2 < y+z && y2 > y-z) {
        if (!(x2 < x+zz && x2 > x-zz && y2 < y+zz && y2 > y-zz)) {

          return true;
        }
      }
    }

    return false;
  }
  /**
    gets the opposite vertex to temp.
  */
  verti getOp(verti temp) {
    if (v1==temp) {
      return v2;
    } else {
      return v1;
    }
  }
  
  /**
  draws edges. Hollow ellipses are used for loops. Also draws arrows and midpoints.
  */
  void draw() {

    if (v1 != null && v2 != null) {

      if (isClose(mouseX, mouseY)) {
        stroke(204, 102, 0);
      } else {
        stroke(0);
      }
      if (v1 != v2) {
        beginShape();
        vertex(v1.getX()+(offset*10), v1.getY()+(offset*5));
        vertex(v2.getX()+(offset*10), v2.getY()+(offset*5));

        endShape(CLOSE);
        if (directed) {
          fill(0);
          PVector mouse = new PVector(v2.getY(), v2.getX()); 
          PVector center = new PVector(v1.getY(), v1.getX());
          mouse.sub(center);
          pushMatrix();
          translate(v2.getX()+(offset*10), v2.getY()+(offset*5)); 
          stroke(10);
          float a = atan2(mouse.y, mouse.x);//v2.getY(),v2.getX());       
          rotate(-a); 

          line(-20, -24, 0, 0); 
          line(+20, -24, 0, 0);


          popMatrix();
        }  
        if (bridge) {
          float[] temp = midpoint();
          fill(255, 31, 31);

          shape(createShape(ELLIPSE, temp[0], temp[1], 20, 20));
        }
      } else {
        noFill();


        shape(createShape(ELLIPSE, v1.getX()+40, v1.getY()+40, 80+(offset*20), 80+(offset*20)));
      }
    }
  }
} 


class verti {
  private PShape v;
  private boolean start; 
  private int x; // x pos
  private int y; // y pos
  private int degree; // degree
  private boolean b; // has the edge been clicked on
  private int lab; // label
  private int c; // color
  private int in; // indegree
  private int out; //outdegree
  private boolean visited; 
  private ArrayList<edge> a_list; //list of connected edges


  verti (int x, int y) {
    v = createShape(ELLIPSE, x, y, 80, 80);
    start = true;
    this.x = x;
    this.y = y;
    b = false;
    degree = 0;
    lab = label;
    label++;
    c = 0;
    in = 0;
    visited = false;
    out = 0;
    a_list = new ArrayList<edge>();
  }



  /**
  lab getter
  */
  int getLabel() {
    return lab;
  }

  /**
  lab setter
  */
  void setLabel() {
    lab--;
  }


  /**
  adds and edge to the a_list
  */
  void addEdge(edge e) {
    if (!a_list.contains(e)) {
      a_list.add(e);
    }
  }

  /**
  removes edge from a_list
  */
  void removeEdge(edge e) {
    if (a_list.contains(e)) {
      a_list.remove(e);
    }
  }

  /**
  outs setter
  */
  void setOut(int i) {
    out = out+ i;
  }
  /**
  ins getter
  */
  void setIn(int i) {
    in = in + i;
  }

  /**
  degrees setter
  */
  void setDegree(int i) {
    degree = degree + i;
  }


  /**
  counts components
  */
  void components(ArrayList<verti> temp2) {
    if (!temp2.contains(this)) {
      ArrayList<verti> temp = new ArrayList<verti>();
      temp2.add(this);

      for (edge e : a_list) {
        if (!e.isBlocked()) {
          temp.add(e.getOp(this));
        }
      }
      for (verti t : temp) {
        t.components(temp2);
      }
    }
  }

  /**
  visits setter
  */
  void setVisit() {
    visited = false;
  }
  
  /**
  traverses the graph to find out if the target is connected
  */
  boolean traverse(verti target) {
    ArrayList<verti> temp = new ArrayList<verti>();
    if (!visited) {
      visited = true;
    } else if (visited && this != target) {
      return false;
    } else {
      return true;
    }

    for (edge e : a_list) {
      if (e.isout(this)) {
        temp.add(e.getOp(this));
      }
    }

    for (verti t : temp) {
      if (t.thelper(target)) {

        return true;
      }
    }


    return false;
  }
  
  /**
  helps find strongly connected components
  */
  boolean traverse2(verti target) {
    ArrayList<verti> temp = new ArrayList<verti>();

    if (this == target) {
      visited = true;
      return true;
    } else if (visited) {
      return false;
    } else {
      visited = true;
    } 

    for (edge e : a_list) {
      if (e.isout(this)) {
        temp.add(e.getOp(this));
      }
    }

    for (verti t : temp) {
      if (t.traverse2(target)) {
        return true;
      }
    }


    return false;
  }

  /**
  traverses helper
  */
  boolean thelper(verti target) {
    ArrayList<verti> temp = new ArrayList<verti>();
    if (!visited && this != target) {
      visited = true;
    } else if (visited && this != target) {
      return false;
    } else {
      return true;
    }

    for (edge e : a_list) {
      if (e.isout(this)) {
        temp.add(e.getOp(this));
      }
    }

    for (verti t : temp) {
      if (t == this) {
        println("oh no");
      } 
      if (t.thelper(target)) {

        return true;
      }
    }


    return false;
  }




  /**
    moves throguh the graph and alternates which color it is using to see if it is connected
  */
  void searchGraph(int i) {
    ArrayList<verti> temp = new ArrayList<verti>();
    if (c==0) {

      c = i;
    } else {

      return;
    } 
    for (edge e : a_list) {
      temp.add(e.getOp(this));
    }
    int I = 1;
    if (i == 1) {
      I = 2;
    }

    for (verti t : temp) {
      t.searchGraph(I);
    }
  }

  /**
  colors the graph and finds the chromatic number
  */
  int paintGraph(int i) {

    ArrayList<verti> temp = new ArrayList<verti>();
    int c_count = i;


    if (c==0) {
      setc();
      while (c != 0) {
        boolean m = true;
        for (edge e : a_list) {
          if (e.ismatch(this)) {
            m = false;
          }
        }
        if (m) {
          break;
        } else {

          setc();
        }
      }

      if (c_count < c) {
        c_count = c;
      }
    } else {
      return c_count;
    } 

    for (edge e : a_list) {
      temp.add(e.getOp(this));
    }

    for (verti t : temp) {

      int t_count = t.paintGraph(c_count);
      if (c_count < t_count) {
        c_count = t_count;
      }
    }
    return c_count;
  }

  /**
  ins getter
  */
  int getIn() {
    return in;
  }

  /**
  outs getter
  */
  int getOut() {
    return out;
  }

  /**
  degrees getter
  */
  int getDegree() {
    return degree;
  }


  /**
  used to update vertex while moving it with a mouse
  */
  void update(int x, int y) {
    this.x = x;
    this.y = y;
    b = false;
  }
  
  /** 
  sets the color to specified
  */
  boolean setColor(int c) {
    if (this.c == c || this.c == 0) {
      this.c = c; 
      return true;
    }
    return false;
  }

  /**
  iterates through colors
  */
  void setc() {
    c += 1;

    if (c == 5) {
      c = 0;
    }
  }
  
  /**
  sets color to 0
  */
  void resetc() {
    c = 0;
  }

  /**
  colors getter
  */
  int getc() {
    return c;
  }
  
  /**
  resets b
  */
  void setb() {
    b = false;
  }
  /**
  x's getter
  */
  int getX() {
    return x;
  }
  /**
  Y's getter
  */
  int getY() { 
    return y;
  }

  /**
    checks if coordiantes are in shape and recolors if b when clicked
  */
  boolean check(int x2, int y2) {
    if (isClose(x2, y2)) {
      if (!paint) {
        b = !b;
      } 
      return true;
    } else {
      return false;
    }
  }

  /**
    checks if mouse is hovering over shape
  */
  boolean isClose(int x2, int y2) {

    if (x2 < x+45 && x2 > x-45 && y2 < y+45 && y2 > y-45) {

      return true;
    } else {

      return false;
    }
  }

  void draw() {
    if (start) {
      stroke(0);
      if (paint && c > 0) {
        if (c == 1) {
          fill(255, 31, 31);
        } else if (c==2) {
          fill(44, 131, 219);
        } else if (c == 3) {
          fill(44, 219, 91);
        } else if (c == 4) {
          fill(203, 21, 223);
        }
      } else if (b) {
        fill(26, 193, 219);
      } else if (isClose(mouseX, mouseY)) {
        fill(204, 102, 0);
      } else {
        fill(255);
      }

      v = createShape(ELLIPSE, x, y, 80, 80);
      shape(v);
    }
  }
}


void setup() {
  size(1500, 1500);
  refresh();
  move = false;
  label = 0;
  del = false;
  guard = false;
  directed = false;
  paint = false;
  f = createFont("Arial", 16, true);
  println("d delete, m move, p color, g reset mode, b bipartie/components, c clear,a adjacency matrix, w chromatic number ");
}

/**
resets pointers after edge creation
*/
void refresh() {
  ind1 = -1;
  ind2 = -1;

  for (verti v : v_list) {
    v.setb();
  }
}

/**
checks if colros are matching
*/
boolean checkMatch(verti v) {
  boolean match;

  do {
    match = false;
    for (edge e : e_list) {
      if (e.ismatch(v)) {
        match = true;
      }
    }

    if (match) {
      v.setc();
      if (v.getc() == 0) {
        return false;
      }
    }
  } while (match);
  return true;
}


void draw() {
  background(120);

  if (!mousePressed) {
    guard = false;
  } else {
    if (del) { // deletion

      if (!guard) {
        int I = -1;
        for (int i =0; i < v_list.size(); i++) {
          if (v_list.get(i).check(mouseX, mouseY)) {
            I = i;
            break;
          }
        }

        if (I > -1) {
          verti temp = v_list.get(I);

          v_list.remove(I);
          for (verti v : v_list) {
            if (v.getLabel() > temp.getLabel()) {
              v.setLabel();
            }
          }
          label--;

          for (int i = e_list.size()-1; i >= 0; i--) {
            if (e_list.get(i).safeDel(temp)) {
              for (verti v : v_list) {
                v.removeEdge(e_list.get(i));
              }
              e_list.remove(i);
            }
          }
        } else {

          for (int i = e_list.size()-1; i >= 0; i--) {
            if (e_list.get(i).isClose(mouseX, mouseY)) {
              for (verti v : v_list) {
                v.removeEdge(e_list.get(i));
              }
              e_list.get(i).del();
              e_list.remove(i);
            }
          }
        }
      }
      bridger(); // draw bridges
    } else if (move) { // movement

      for (int i =0; i < v_list.size(); i++) {
        if (v_list.get(i).check(mouseX, mouseY)) {

          v_list.get(i).update(mouseX, mouseY);
          break;
        }
      }
    } else if (paint) { // color graph
      if (!guard) {
        for (int i =0; i < v_list.size(); i++) {
          if (v_list.get(i).check(mouseX, mouseY)) {
            verti v = v_list.get(i);
            v.setc();
            checkMatch(v);


            break;
          }
        }
      }
    } else { // place edges
      if (!guard) {

        boolean test = false;
        for (int i =0; i < v_list.size(); i++) {
          if (v_list.get(i).check(mouseX, mouseY)) {
            test = true;
            if (ind1 == -1) {
              ind1 = i;
            } else if (ind2 == -1) {    
              ind2 = i;
            }

            break;
          }
        }
        if (!test) {
          v_list.add(new verti(mouseX, mouseY));
          refresh();
        } else if (ind1 != -1 && ind2 != -1) {
          int offset = 0;
          for (edge e : e_list) {
            if (e.isLoop(v_list.get(ind1), v_list.get(ind2))) {
              offset += 1;  
              if (offset > 2) {
                break;
              }
            }
          }
          e_list.add(new edge(v_list.get(ind1), v_list.get(ind2), offset));
          refresh();
          bridger();
        }
      }
    }
    guard = true;
  }



  for (int i =0; i < v_list.size(); i++) {
    v_list.get(i).draw(); // draw vertices
    textFont(f, 25);                  
    fill(255); 

    if (directed) { // draw edge info
      text(v_list.get(i).getOut() + "", v_list.get(i).getX()+50, v_list.get(i).getY()+50);
      text(v_list.get(i).getIn() + "", v_list.get(i).getX()-60, v_list.get(i).getY()+50);
    } else {
      text(v_list.get(i).getDegree() + "", v_list.get(i).getX()+50, v_list.get(i).getY()+50);
    }
    text(v_list.get(i).getLabel() + "", v_list.get(i).getX()+50, v_list.get(i).getY()-50);
  }

  for (int i =0; i < e_list.size(); i++) {
    e_list.get(i).draw(); // draw edges
  }
  textFont(f, 40);
  fill(255);
  text("n="+v_list.size(), 50, 100); // vertex count
  text("m="+e_list.size(), 1350, 100); // edge count
}

/**
  checks if bipartite by seeing if the chromatic number is 2
*/
boolean isBipartite() {

  if (v_list.size()<=1) { // checks for more than 1 vertice
    return false;
  }
  for (edge e : e_list) { // checks for loops
    if (e.isLoop()) {
      return false;
    }
  }   
  int chromatic = 0;
  cleanCanvas(); // cleans colors
  for (verti v : v_list) {
    if (v.getc() == 0) {
      int temp = v.paintGraph(1);
      if (chromatic < temp) {
        chromatic = temp;
      }
    }
  }
  cleanCanvas(); // cleans colors
  if (chromatic == 2) {
    return true;
  }
  return false;
}

/**
creates adjacency matrix
*/
void adjmatrix() {
  int[][] adj = new int[v_list.size()][v_list.size()];
  for (int x = 0; x < adj.length; x++) {
    for (int y = 0; y < adj.length; y++) { //Initialize matrix
      adj[x][y] = 0;
    }
  }
  for (edge e : e_list) { // fill in matrix
    int[] temp = e.coords();
    adj[temp[0]][temp[1]] += 1;   
    if (!directed) {
      adj[temp[1]][temp[0]] += 1;
    }
  }

  for (int x = 0; x < adj.length; x++) { // print matrix
    for (int y = 0; y < adj.length; y++) {
      print("|"+adj[x][y]);
    }
    println("|");
  }
  println("");
}

/**
strongly connected components
*/
int scomp() {
  int count = 0;
  ArrayList<verti> traveled = new ArrayList<verti>();

  for (verti v : v_list) {
    if (!traveled.contains(v)) {
      traveled.add(v);
      count += 1;  

      for (verti w : v_list) {
        if (v != w) {
          if (v.traverse2(w)) {
            rset();
            if (w.traverse2(v)) {

              if (!traveled.contains(w)) {
                traveled.add(w);
              }
            }
          }
          rset();
        }
      }
    }
  }
  return count;
}

/**
components
*/
int countComp() {
  ArrayList<verti> traveled = new ArrayList<verti>();

  int count = 0;
  if (!directed) {

    for (verti v : v_list) {
      if (!traveled.contains(v)) {
        count += 1;
        v.components(traveled);
      }
    }
  } else {
    count = scomp();
  }

  return count;
}

/**
draws bridges
*/
void bridger() {

  int comp = countComp();

  for (edge e : e_list) {
    e.setBlocked(false);
  }

  for (edge e : e_list) {
    if (!e.isLoop()) {
      e.setBlocked(true);
      if (comp < countComp()) {
        e.setBridge(true);
      } else {
        e.setBridge(false);
      }
      e.setBlocked(false);
    }
  }
}

/**
checks if graph is connected
*/
boolean isConnected(int i, boolean direct) {
  if (v_list.size() <= 0) {
    return false;
  }

  v_list.get(i).searchGraph(1);
  for (verti v : v_list) {
    if (v.getc() == 0) {

      return false;
    }
  }
  for (verti v : v_list) {
    v.setColor(0);
  }

  return true;
}

/** 
resets visit
*/
void rset() {
  for (verti v : v_list) {
    v.setVisit();
  }
}

/**
cleans colors
*/
void cleanCanvas() {

  for (verti v : v_list) {
    v.setb(); 
    v.resetc();
  }
}

/**
user control function
*/
void keyPressed() {
  if (key == 'd') {
    del = !del;
    move = false;
    paint = false;
  } else if (key == 'm') {
    move = !move;
    del = false;
    //paint = false;
  } else if (key == 'p') {
    paint = !paint;

    if (!paint) {
      cleanCanvas();
    } else {
      for (verti v : v_list) {
        v.setb();
      }
    }

    ind1 = -1;
    ind2 = -1;
    move = false;
    del = false;
  } else if (key == 'c') {
    move = false;
    del = false;
    paint = false;
    label = 0;
    move = false;
    ind1 = -1;
    ind2 = -1;
    e_list.clear();
    v_list.clear();
  } else if (key == 'g') {
    move = false;
    del = false;
    paint = false;
    move = false;
    ind1 = -1;
    ind2 = -1;
    for (verti v : v_list) {
      v.setb();
    }
  } else if (key == 'b') {
    for (verti v : v_list) {
      v.setb(); 
      v.resetc();
    }
    ind1 = -1;
    ind2 = -1;
    boolean strong = false;

    boolean weak = false;
    //paint = true;

    if (isConnected(0, false)) {
      weak = true;
    }
    if (weak && directed) {
      strong = true;
      for (int x = 0; x < v_list.size(); x++) {

        for (int y = 0; y < v_list.size(); y++) {

          if (!v_list.get(x).traverse(v_list.get(y))) {

            strong = false;
            rset();
            break;
          }
          cleanCanvas();
          rset();
        }
        if (!strong) {
          break;
        }
      }
    }

    if (directed) {
      if (strong) {
        println("strongly connected");
      } else if (weak) {
        println("weakly connected");
      } else {
        println("not connected");
      }
    } else {
      if (weak) {
        println("connected");
      } else {
        println("not connected");
      }
    }

    paint = true;
    boolean d = false;
    if (directed) {
      d = true;
      directed = false;
    }
    directed = false;
    if (isBipartite()) {
      println("bipartite");
    } else {
      println("not bipartite");
    }
    if (d) {
      directed = true;
    }
    paint = false;
    cleanCanvas();  
    println("components:" + countComp());

    move = false;
    del = false;
  } else if (key == 'r') {
    directed = !directed; 
    bridger();
  } else if (key == 'a') {
    adjmatrix();
  } else if (key == 'w') {


    if (v_list.size() > 0) {
      paint = true;

      int chromatic = 0;

      for (verti v : v_list) {
        if (v.getc() == 0) {
          int temp = v.paintGraph(1);
          if (chromatic < temp) {
            chromatic = temp;
          }
        }
      }


      println("chromatic number=" + chromatic);//v_list.get(0).paintGraph(1));
      //cleanCanvas();
      //paint = false;
    } else {
      println("chromatic number=" + 0);
    }
  }
}
