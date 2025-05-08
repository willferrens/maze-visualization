import processing.core.*;

public class BreadthMaze extends PApplet {

  private int w, h, px, py;
  private int dim;
  private int speed = 5;
  private boolean paused = false;

  private JSONArray grid;
  private int[][] convGrid;

  private ArrayList<JSONObject> pastCells;
  private ArrayList<JSONObject> actCells;

  public BreadthMaze (JSONArray g, int d, int w, int h, int px, int py) {
    this.dim = d;
    this.grid = g;

    int[] start = new int[2];
    for (int i = 0; i < this.grid.size(); i++) {
      JSONObject c = this.grid.getJSONObject(i);
      int type = c.getInt("type");

      if (type == 1) start = new int[]{ c.getInt("x"), c.getInt("y") };
    }

    this.pastCells = new ArrayList<JSONObject>();
    this.actCells = new ArrayList<JSONObject>();

    // creating 2d array from JSONArray for checking dirs
    this.convGrid = new int[d][d];
    Arrays.stream(this.convGrid).forEach(a -> Arrays.fill(a, 0));
    for (int i = 0; i < this.grid.size(); i++) {
      JSONObject c = this.grid.getJSONObject(i);
      if (c.getInt("type") == 0) this.convGrid[c.getInt("y")][c.getInt("x")] = 1;
    }
    
    for (int i = 0; i < this.convGrid.length; i++) {
      String s = "";
      for (int j = 0; j < this.convGrid[i].length; j++) {
        s += this.convGrid[i][j]+" ";
      }
      println(s);
    }

    // create first active cell
    JSONObject sc = new JSONObject();
    sc.setInt("x", start[0]);
    sc.setInt("y", start[1]);
    sc.setInt("init_dir", 0);
    this.actCells.add(sc);

    // window settings
    this.w = w;
    this.h = h;
    this.px = px;
    this.py = py;
  }

  public void settings() {
    size(this.w, this.h);
  }

  public void setup() {
    surface.setLocation(this.px, this.py);
  }

  public void draw() {
    background(0);
    // drawing maze
    for (int i = 0; i < this.grid.size(); i++) {
      JSONObject c = this.grid.getJSONObject(i);
      if (c.getInt("type") == 0) {
        fill(255);
        rect(c.getInt("x") * (this.w / this.dim), c.getInt("y") * (this.h / this.dim), this.w / this.dim, this.h / this.dim);
      }
    }

    // draw past cells
    for (JSONObject pc : this.pastCells) {
      fill(0, 255, 0);
      rect(pc.getInt("x") * (this.w / this.dim), pc.getInt("y") * (this.h / this.dim), this.w / this.dim, this.h / this.dim);
    }
    // draw active cells
    for (JSONObject ac : this.actCells) {
      fill(255, 0, 0);
      rect(ac.getInt("x") * (this.w / this.dim), ac.getInt("y") * (this.h / this.dim), this.w / this.dim, this.h / this.dim);
    }

    // solve the maze
    if (frameCount % this.speed == 0) this.solve();
  }

  public void keyPressed() {
    if (this.paused) {
      loop();
      this.paused = false;
    } else {
      noLoop();
      this.paused = true;
    }
  }

  private void solve() {
    ArrayList<Integer> dirs;
    int sd = 0;

    // if there are active cells
    if (this.actCells.size() > 0) {
      // get each cell
      for (int i = 0; i < this.actCells.size(); i++) {
        // get the cell and remove it
        // but still have access to it
        JSONObject ac = this.actCells.get(i);
        this.actCells.remove(i);
        dirs = checkDirs(ac.getInt("x"), ac.getInt("y"));

        // if there are dirs
        if (dirs.size() > 0) {
          // remove last dir
          // just traveled
          int lastDir = ac.getInt("init_dir");
          if (lastDir != 0) {
            for (int j = 0; j < dirs.size(); j++) {
              if (dirs.get(j) == oppDir(lastDir)) dirs.remove(j);
            }
          }

          // add curr cell
          this.pastCells.add(ac);

          // if dirs mean intersection
          if (dirs.size() > 1) {
            // add each dir as a
            // new active cell
            for (int j = 0; j < dirs.size(); j++) {
              sd = dirs.get(j);
              this.actCells.add(newCell(ac.getInt("x"), ac.getInt("y"), sd));
            }
            break;
            // if dirs mean one way
          } else if (dirs.size() > 0) {
            // add dir as a
            // new active cell
            sd = dirs.get(0);
            this.actCells.add(newCell(ac.getInt("x"), ac.getInt("y"), sd));
            break;
          } else if (dirs.size() < 1) {
            // none
          }
        }
      }
    } else {
      // done
    }
  }

  // checks all dirs on the converted grid
  // at a specified x and y coord and
  // returns an arraylist of dirs
  private ArrayList<Integer> checkDirs(int x, int y) {
    ArrayList<Integer> dirs = new ArrayList<Integer>();

    if (this.convGrid[y - 1][x] == 0) {
      dirs.add(1);
    }
    if (this.convGrid[y][x + 1] == 0) {
      dirs.add(2);
    }
    if (this.convGrid[y + 1][x] == 0) {
      dirs.add(3);
    }
    if (this.convGrid[y][x - 1] == 0) {
      dirs.add(4);
    }

    return dirs;
  }

  // returns the opposite dir
  // of the specified arg
  private int oppDir(int d) {
    if (d == 1) {
      return 3;
    } else if (d == 2) {
      return 4;
    } else if (d == 3) {
      return 1;
    } else if (d == 4) {
      return 2;
    } else {
      return 0;
    }
  }

  // creates a new cell for the ac array
  // by recording the x and y coord and
  // then altering it with a given dir
  // returns a jsonobject
  private JSONObject newCell(int x, int y, int sd) {
    JSONObject nc = new JSONObject();

    if (sd == 1) {
      y -= 1;
    } else if (sd == 2) {
      x += 1;
    } else if (sd == 3) {
      y += 1;
    } else if (sd == 4) {
      x -= 1;
    }

    nc.setInt("x", x);
    nc.setInt("y", y);
    nc.setInt("init_dir", sd);

    return nc;
  }
}
