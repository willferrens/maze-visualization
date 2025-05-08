import processing.core.*;

public class DepthMaze extends PApplet {

  private int w, h, px, py;
  private int dim;
  private int currX, currY, endX, endY;
  // can alter the display
  // speed of the auto solve
  private int speed = 5;
  private boolean paused = false;

  private JSONArray grid;
  private int[][] convGrid;

  private ArrayList<JSONObject> pastInts;
  private ArrayList<Integer> pastDirs;
  private ArrayList<JSONObject> pastCells;

  public DepthMaze (JSONArray g, int d, int w, int h, int px, int py) {
    this.dim = d;
    this.grid = g;
    
    // declare important cells
    for (int i = 0; i < this.grid.size(); i++) {
      JSONObject c = this.grid.getJSONObject(i); 
      int type = c.getInt("type");
      
      if (type == 1) {
        this.currX = c.getInt("x");
        this.currY = c.getInt("y");
      } else if (type == 2) {
        this.endX = c.getInt("x");
        this.endY = c.getInt("y");
      }
    }
    
    this.pastInts = new ArrayList<JSONObject>();
    this.pastDirs = new ArrayList<Integer>();
    this.pastCells = new ArrayList<JSONObject>();

    // creating 2d array from JSONArray for checking dirs
    this.convGrid = new int[d][d];
    Arrays.stream(this.convGrid).forEach(a -> Arrays.fill(a, 0));
    for (int i = 0; i < this.grid.size(); i++) {
      JSONObject c = this.grid.getJSONObject(i);
      if (c.getInt("type") == 0) this.convGrid[c.getInt("y")][c.getInt("x")] = 1;
    }

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
    // showing current pos
    fill(255, 0, 0);
    rect(this.currX * (this.w / this.dim), this.currY * (this.h / this.dim), this.w / this.dim, this.h / this.dim);

    // draw past cells
    for (int i = 0; i < this.pastCells.size(); i++) {
      JSONObject pc = this.pastCells.get(i);

      fill(255, 0, 255);
      rect(pc.getInt("x") * (this.w / this.dim), pc.getInt("y") * (this.h / this.dim), this.w / this.dim, this.h / this.dim);
    }

    // draw intersections
    for (int i = 0; i < this.pastInts.size(); i++) {
      JSONObject inter = this.pastInts.get(i);
      if (i == this.pastInts.size() - 1) {
        fill(0, 0, 255);
      } else {
        fill(0, 255, 0);
      }
      rect(inter.getInt("x") * (this.w / this.dim), inter.getInt("y") * (this.h / this.dim), this.w / this.dim, this.h / this.dim);
    }

    // drawing maze
    for (int i = 0; i < this.grid.size(); i++) {
      JSONObject c = this.grid.getJSONObject(i);
      if (c.getInt("type") == 0) {
        fill(255);
        rect(c.getInt("x") * (this.w / this.dim), c.getInt("y") * (this.h / this.dim), this.w / this.dim, this.h / this.dim);
      }
    }

    // solve the maze on pace with the speed and
    // if not already at the end of the maze
    if (frameCount % speed == 0 && !(this.currX == this.endX && this.currY == this.endY)) {
      this.solve();
    }
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
    dirs = this.checkDirs();
    int sd = 0;
    int lastDir = 0;
    boolean backtrack = false;

    // check if able to move
    if (dirs.size() > 0) {
      // remove last dir
      if (this.pastDirs.size() > 0) {
        lastDir = this.pastDirs.get(this.pastDirs.size() - 1);

        for (int i = 0; i < dirs.size(); i++) {
          if (dirs.get(i) == oppDir(lastDir)) dirs.remove(i);
        }
      }

      // check if intersection
      if (dirs.size() > 1) {
        // chooses a random dir
        int ind = int(random(dirs.size()));
        sd = dirs.get(ind);

        // create a new intersection
        JSONObject inse = new JSONObject();
        inse.setInt("x", this.currX);
        inse.setInt("y", this.currY);
        inse.setInt("init_dir", lastDir);
        inse.setInt("steps", this.pastCells.size());

        // supply dirs
        JSONArray ds = new JSONArray();
        for (int i = 0; i < dirs.size(); i++) {
          ds.setInt(i, dirs.get(i));
        }

        // remove dir taken and add inter
        ds.remove(ind);
        inse.setJSONArray("dirs", ds);
        this.pastInts.add(inse);
        // if no dirs from point
      } else if (dirs.size() < 1) {
        backtrack = true;
        // move to and then check
        // last intersection and
        // see for possible dirs
        // keep repeating until you find
        // one with an possible dir
        while (backtrack) {
          JSONObject lastInt = this.pastInts.get(this.pastInts.size() - 1);

          for (int i = this.pastCells.size() - 1; i > lastInt.getInt("steps") - 1; i--) {
            JSONObject pc = this.pastCells.get(i);
            this.currX = pc.getInt("x");
            this.currY = pc.getInt("y");

            this.pastCells.remove(i);
            this.pastDirs.remove(i);
          }

          JSONArray intDirs = lastInt.getJSONArray("dirs");
          if (intDirs.size() > 0) {
            int in = int(random(intDirs.size()));
            sd = intDirs.getInt(in);
            
            intDirs.remove(in);
            lastInt.setJSONArray("dirs", intDirs);
            backtrack = false;
          } else {
            this.pastInts.remove(this.pastInts.size() - 1);
            continue;
          }
        }
      } else {
        // move to only
        // possible dir
        sd = dirs.get(0);
      }

      if (!backtrack) {
        // adds cells as past cell
        JSONObject pc = new JSONObject();
        pc.setInt("x", this.currX);
        pc.setInt("y", this.currY);
        this.pastCells.add(pc);

        // record most recent dir
        // move the curr cell
        this.pastDirs.add(sd);
      }
      this.move(sd);
    } else {
      println("stuck");
    }
  }

  // checks all dirs on the converted grid
  // at a specified x and y coord and
  // returns an arraylist of dirs
  private ArrayList<Integer> checkDirs() {
    ArrayList<Integer> dirs = new ArrayList<Integer>();

    if (this.convGrid[this.currY - 1][this.currX] == 0) {
      dirs.add(1);
    }
    if (this.convGrid[this.currY][this.currX + 1] == 0) {
      dirs.add(2);
    }
    if (this.convGrid[this.currY + 1][this.currX] == 0) {
      dirs.add(3);
    }
    if (this.convGrid[this.currY][this.currX - 1] == 0) {
      dirs.add(4);
    }

    return dirs;
  }

  // moves the curr cell
  private void move(int sd) {
    if (sd == 1) {
      this.currY -= 1;
    } else if (sd == 2) {
      this.currX += 1;
    } else if (sd == 3) {
      this.currY += 1;
    } else if (sd == 4) {
      this.currX -= 1;
    }
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
}
