import processing.core.*;
import static javax.swing.JOptionPane.*;

public class MazeBuilder extends PApplet {

  private JSONObject maze;
  private int w, h, gs, dim;
  private JSONArray grid;
  private String name;
  private boolean clickAction = true; // add/remove
  private int clickType = 0; // type of block

  public MazeBuilder() {
    // empty due to not being
    // able to load files so i
    // moved init to settings()
  }

  public void settings() {
    String[] init = new String[] { "Create New Maze", "Edit Maze" };
    int ic = showOptionDialog(null,
      "Choose an option", "Prompt",
      YES_NO_OPTION, INFORMATION_MESSAGE,
      null, init, init[0]);

    if (ic == 0) { // new maze
      String[] opts = new String[]{ "17x17", "21x21", "35x35" };
      int[] sOpts = new int[]{ 800, 800, 805 };
      int sc = showOptionDialog(null,
        "Choose the size of your maze", "Prompt",
        YES_NO_OPTION, INFORMATION_MESSAGE,
        null, opts, opts[1]);

      // setting width/height
      this.w = sOpts[sc];
      this.h = sOpts[sc];

      // split str to get dim
      String[] vals = opts[sc].split("x");
      this.dim = int(vals[0]);

      // setting more vals for json
      this.gs = this.w / this.dim;
      this.grid = new JSONArray();

      // setting up json for maze
      this.maze = new JSONObject();
      this.maze.setInt("width", this.w);
      this.maze.setInt("height", this.h);
      this.maze.setInt("grid-size", this.gs);

      // generate border of maze
      int it = 0;
      for (int i = 0; i < this.dim; i++) {
        for (int j = 0; j < this.dim; j++) {
          if (j == 0 || j == this.dim - 1 ||
            i == 0 || i == this.dim - 1) {
            JSONObject mc = new JSONObject();
            mc.setInt("x", j);
            mc.setInt("y", i);
            mc.setInt("type", 0);

            this.grid.setJSONObject(it, mc);
            it++;
          }
        }
      }
      this.maze.setJSONArray("grid", this.grid);

      // naming maze
      this.name = showInputDialog(null, "What would you like the name of your file to be?\n(Do not include .json)");
      export(this.name);
      
      showMessageDialog(null, "Controls for the MazeBuilder:\n- By default, the wall tile is selected, but you can press 1 on the number bar to select.\n- To add and remove tiles, use the spacebar to toggle actions.\n- To add a start and  an end, press 2 (start) and 3 (end) on the number row.\n- To quick save, press 'e' on your keyboard\n- To save and check the maze, press 'f' on your keyboard.\n\n* Ensure that you create no cyclical paths (Only one way in and out everywhere)\n* If you do create cyclical paths, the solvers will not run properly.");
    } else { // edit maze
      // load based on name
      this.name = showInputDialog(null, "What is the name of your file?\n[PUT FILE IN ./custom] (Do not include .json)");
      this.maze = load(this.name);

      // assign values from json
      this.w = this.maze.getInt("width");
      this.h = this.maze.getInt("height");
      this.gs = this.maze.getInt("grid-size");
      this.grid = this.maze.getJSONArray("grid");
    }

    size(this.w, this.h);
  }

  public void setup() {
    // empty
  }

  public void draw() {
    background(0);
    if (this.clickType == 0) {
      if (this.clickAction) {
        cursor(cursors.get(0));
      } else {
        cursor(cursors.get(1));
      }
    } else if (this.clickType == 1) {
      cursor(cursors.get(2));
    } else {
      cursor(cursors.get(3));
    }

    this.loadGrid();
  }

  // managing actions for the mb
  public void keyPressed() {
    // for simple saving
    if (key == 'e') {
      export(this.name);
      showMessageDialog(null, "Saved "+this.name+".json to the ./custom folder!");
    }
    
    // for final maze
    if (key == 'f') {
      int count = 0;
      for (int i = 0; i < this.grid.size(); i++) {
        JSONObject pc = this.grid.getJSONObject(i);
        if (pc.getInt("type") != 0) count++;
      }
      
      if (count == 2) {
        export(this.name);
        showMessageDialog(null, "Restart the program and enter the maze in the 'Use Custom Maze' prompt.");
        exit();
      } else {
        showMessageDialog(null, "Need to add a start/end to the maze before validating!");
      }
    }

    if (key == ' ') {
      this.clickAction = !this.clickAction;
    }
    
    //if (keyCode >= 49 || keyCode <= 51) {
    //  this.clickType = keyCode - 49; 
    //}
    
    // this is the less efficient 
    // alternative to above because 
    // for some reason the code is funky
    if (keyCode == 49) {
      this.clickType = 0; 
    } else if (keyCode == 50) {
      this.clickType = 1; 
    } else if (keyCode == 51) {
      this.clickType = 2; 
    }
  }

  // manages the adding/removing
  // with the option of dragging
  public void mouseClicked() {
    this.manageBlocks();
  }
  public void mouseDragged() {
    this.manageBlocks();
  }

  public void loadGrid() {
    for (int i = 0; i < this.grid.size(); i++) {
      JSONObject cc = this.grid.getJSONObject(i);

      if (cc.getInt("type") == 0) {
        fill(255);
      } else if (cc.getInt("type") == 1) {
        fill(0, 255, 0); 
      } else if (cc.getInt("type") == 2) {
        fill(255, 0, 0); 
      }
      rect(cc.getInt("x") * this.gs, cc.getInt("y") * this.gs, this.gs, this.gs);
    }
  }

  public void manageBlocks() {
    int gridX = floor(mouseX / this.gs);
    int gridY = floor(mouseY / this.gs) - (mouseY < 0 ? 1 : 0);

    if (this.clickAction) {
      for (int i = 0; i < this.grid.size(); i++) {
        JSONObject c = this.grid.getJSONObject(i);

        if (c.getInt("x") != gridX && c.getInt("y") != gridY) {
          JSONObject nc = new JSONObject();
          nc.setInt("x", gridX);
          nc.setInt("y", gridY);
          nc.setInt("type", this.clickType);
          
          if (this.clickType != 0) {
            for (int j = 0; j < this.grid.size(); j++) {
              JSONObject pc = this.grid.getJSONObject(j);
              
              if (pc.getInt("type") == this.clickType) {
                this.grid.remove(j); 
              }
            }
          }

          this.grid.setJSONObject(this.grid.size(), nc);
          break;
        }
      }
    } else {
      for (int i = 0; i < this.grid.size(); i++ ) {
        JSONObject c = this.grid.getJSONObject(i);
        if (c.getInt("x") == gridX && c.getInt("y") == gridY) {
          if (gridX == 0 || gridX == this.dim - 1 ||
              gridY == 0 || gridY == this.dim - 1) {
            // nothing
          } else {
            this.grid.remove(i);
          }
        }
      }
    }
  }

  public JSONObject getMaze() {
    return this.maze;
  }
}
