import java.util.*;
import static javax.swing.JOptionPane.*;

// vars for windows
MazeBuilder mb;
DepthMaze dm;
BreadthMaze bm;
// basic grid values
JSONObject json;
int w, h;
ArrayList<PImage> cursors;

void setup() {
  // cursors
  String[] types = new String[]{ "add", "remove", "start", "end" };
  cursors = new ArrayList<PImage>();
  for (int i = 0; i < types.length; i++) {
    PImage img = loadImage("./cursors/"+types[i]+".png");
    cursors.add(img);
  }
  
  // prompt use to create maze
  // or to select a preset
  String[] mo = { "Maze Builder", "Choose Preset", "Use Custom Maze" };
  int mc = showOptionDialog(null,
    "Choose an option!", "Prompt",
    YES_NO_OPTION, INFORMATION_MESSAGE,
  null, mo, mo[1]);
  
  // logic for maze option dialog
  if (mc == 0) {
    mb = new MazeBuilder();
    runSketch(new String[]{ "MazeBuilder" }, mb);
  } else if (mc == 1) {
    // preset option dialog
    String[] po = { "Preset 1 (17x17)", "Preset 2 (21x21)", "Preset 3 (35x35)" };
    int pc = showOptionDialog(null,
      "Choose a preset", "Prompt",
      YES_NO_OPTION, INFORMATION_MESSAGE,
    null, po, po[0]);
    // preset files
    String[] files = { "maze1.json", "maze2.json", "maze3.json" };

    // loading json and basic vars from
    // the json that is chosen
    json = loadJSONObject("./presets/"+files[pc]);
    w = json.getInt("width");
    h = json.getInt("height");
  } else if (mc == 2) {
    // custom maze
    String file = showInputDialog(null, "What would you like the name of your file to be?\n(Do not include .json)");
    
    json = loadJSONObject("./custom/"+file+".json");
    w = json.getInt("width");
    h = json.getInt("height");
  }
  
  // create tab for depth maze example
  if (mc != 0) {
    dm = new DepthMaze(
      json.getJSONArray("grid"), int(floor(w / json.getInt("grid-size"))),
      w, h, displayWidth / 12, displayHeight / 12
    );
    // create tab for breadth maze example
    bm = new BreadthMaze(
      json.getJSONArray("grid"), int(floor(w / json.getInt("grid-size"))),
      w, h, displayWidth / 12 + w, displayHeight / 12
    );
    
    // display option dialog
    String[] dio = { "Depth-First", "Breadth-First", "Both" };
    int dc = showOptionDialog(null,
      "Choose a display option (Windows run side by side)\n\n* Only do so if you are sure the maze has no cyclical paths", "Prompt",
      YES_NO_OPTION, INFORMATION_MESSAGE,
    null, dio, dio[2]);
    
    // both sketches will run and display side by side
    // you can choose with the dialog above if you
    // want one or the other or both display methods
    if (dc == 0 || dc == 2) runSketch(new String[]{ "DepthMaze" }, dm);
    if (dc == 1 || dc == 2)  runSketch(new String[]{ "BreadthMaze" }, bm);
  }
}

void draw() {
  background(0);

  // nothing
  noLoop();
}

// something about PApplet 
// messes up the import/export
// within the MazeBuilder tab
JSONObject load(String n) {
   return loadJSONObject("./custom/"+n+".json");
}
void export(String n) {
  saveJSONObject(mb.getMaze(), "./custom/"+n+".json");
}
