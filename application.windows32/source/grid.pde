import java.util.List; //<>// //<>// //<>//
import java.util.Arrays;


//Specify number of cells in grid
int gridW = 256;
int gridH = 160;
int numberOfCells = gridW*gridH;

//Declaring the grid
Grid grid;

//Determine size of each cell from size of grid and size of window
int cellW=1024/gridW;
int cellH=640/gridH;

int gridLength = cellW*gridW;
int gridHeight = cellH*gridH;

ArrayList<Integer> colours; //array to hold colours each frame

//colour limits
int lowLimR = 0;
int uppLimR = 255;
int lowLimG = 0;
int uppLimG = 255;
int lowLimB = 0;
int uppLimB = 255;
//paint gun
int gunR = 50;
int gunG = 100;
int gunB = 220;
int pelletSize = 1;
int pelletX, pelletY;

//Grid parameters
float sepCo = 1.0; //separation coeff
float cohCo = 1.0; //alignement coeff
float aliCo = 1.0; //alignement coeff
float rr = -1.0; //Reverse rate
float rein = 0.1; //a variable used to moderate the velocity

//misc
PImage snap, filGrid, gi; //PImages to hold: exported image/filtered image/grid itself
PGraphics sym; //graphic in which 2 gi are drawn to create symmetry
int snaps = 0; //counter for screenshots

int time = millis(); //start of the timer
int wait = 2000; 
int alpha = 55;

//GUI
import controlP5.*;
ControlP5 cp5;
//Declaring buttons
Accordion acco1, acco2, acco3, acco4;
Bang pause, restart, export, fullscreenB, exit, resetN, reset, verticalMode, horizontalMode, embed, startStripes, solidBack, addLayer, removeLayer, pastel;
CheckBox filt, neighbox;
Group resolutionGr, limitsGr, paintgunGr, filtersGr, filterSettingsGr, gridGr, neighboursGr;
Group presetsGr, flockingGr, symGr, patternGr, positionGr, stripeColourGr, backgroundGr, warpGr, layerGr, pastelGr;
Knob posterKnob, blurKnob, threshKnob;
RadioButton res, presets, syms, stripeOrientation, layerNumber;
Range limitsR, limitsG, limitsB, stripeOS;
Slider gunRS, gunGS, gunBS, pelletSizeS, reinS, rrS, sepCoS, cohCoS, aliCoS;
Slider stripeWS, stripeSS, stripeRS, stripeGS, stripeBS, backRS, backGS, backBS, warpS;
Tab basic, effects, advanced, stripes;
Textarea info, wrapLabel;
Toggle wrap;
//Setting filters to off
int f1, f2, f3, f4;
//Filter parameters default values
int paramP = 5; 
int paramB = 1; 
float paramT = 0.5;
//Declaring neighbour variables
float n1, n2, n3, n4, n6, n7, n8, n9;
//Setting tabs
int bas = 1;
int eff = 0;
int adv = 0;
int sti = 0;
//Setting measurements for relative positioning
int guiX, guiY;
int hpc, wpc;
//Empty object to call bangs on
Object obj;


//switches
boolean wrapping = false;
int symmetry = 0;
int flick = 0;
int fs = 1;
int pastelMode = 0;


//stripes variables
int layerCount = 1;
int activeLayer = 1;
int previousLayer = 1;
PImage stripeBuffer = createImage(gridW, gridH, ARGB);
PImage layer1 = createImage(gridW, gridH, ARGB);
PImage layer2 = createImage(gridW, gridH, ARGB);
PImage layer3 = createImage(gridW, gridH, ARGB);
PImage layer4 = createImage(gridW, gridH, ARGB);
int useStripes = 0;
int stripeWidth = 10;
int stripeGap = 10;
int stripeOffset = 0;
int sOff2;
int stripeR = 240;
int stripeG = 240;
int stripeB = 0;
int stripeEmbed = 0;
int background;
int backR = 200;
int backG = 200;
int backB = 200;
int hor = 0;
int ver = 1; 
int warp;

int[] widths = new int[4];
int[] offsets = new int[4];
int[] gaps = new int[4];
int[] offsets2 = new int[4];
int[] stripeReds = new int[4];
int[] stripeGreens = new int[4];
int[] stripeBlues = new int[4];
int[] backReds = new int[4];
int[] backGreens = new int[4];
int[] backBlues = new int[4];
int[] warps = new int[4];


//Setup the sketch
void setup() {
  
  //Processing 3
  fullScreen(P2D);

  //initialise grid and place cells
  grid = new Grid();
  grid.addCells();
  grid.findNeighbours();
  gi = createImage(gridW, gridH, RGB);
  gui();
}



void draw() {
  background(255);

  //Draw grid outline
  rectMode(CORNER);
  stroke(200);
  noFill();
  rect(grid.gridX-1, grid.gridY-1, gridW*cellW+1, gridH*cellH+1);
  

  grid.refresh();


  image(gi, grid.gridX, grid.gridY, 1024, 640);


  if (symmetry > 0) {
    switch(symmetry) {
      case(1):
      symmetry(1);
      break;
      case(2):
      symmetry(2);
      break;
    }
    image(sym, grid.gridX, grid.gridY, 1024, 640);
  }


  applyFilters();

  //draw controls
  cp5.draw();
  stroke(0);
  line(grid.gridX+gridLength-2*wpc, grid.gridY-4*hpc, grid.gridX+gridLength-1, grid.gridY-hpc-1);
  line(grid.gridX+gridLength-2*wpc, grid.gridY-hpc-1, grid.gridX+gridLength-1, grid.gridY-4*hpc);
  stripeColourGr.setBackgroundColor(color(stripeR, stripeG, stripeB, 40));

  
  //draw pellet if paint gun menu is open
  if (paintgunGr.isOpen() && bas==1 ) {
    paintgunGr.setBackgroundColor(color(gunR, gunG, gunB, 40));
    fill(gunR, gunG, gunB);
    noStroke();
    ellipse(paintgunGr.getPosition()[0]+12*wpc, paintgunGr.getPosition()[1]+29*hpc, pelletSize*0.0125*height, pelletSize*0.0125*height);
  }
  
  if (sti==1) {
   reset.hide();
  } else {reset.show();}

  //draw full screen if option enabled
  if (fs%2 == 0) {
    gridFullScreen();
  }


  if (cp5.isMouseOver()) {
    displayInfo();
  }
}

void mouseMoved() {
  cursor();
}

void gui() {
  /*Set controls*/
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  //define percentage and set coordinates
  wpc = Math.round(0.01*width);
  hpc = Math.round(0.01*height);
  guiX=Math.round(3*wpc);
  guiY=grid.gridY;

  //font
  PFont pfont = createFont("Courier", 14, false); // use true/false for smooth/no-smooth
  ControlFont font = new ControlFont(pfont, hpc+2);
  cp5.setFont(font);


  //create colours
  CColor black = new CColor(color(100), color(80), color(150), color(0), color(255)); //(foreground,background,active,caption,value)
  CColor grey = new CColor(color(190), color(150), color(210), color(0), color(50));
  CColor red = new CColor(color(200, 10, 10), color(100, 10, 10), color(230, 10, 10), color(0), color(255));
  CColor green = new CColor(color(10, 200, 10), color(10, 100, 10), color(10, 230, 10), color(0), color(255));
  CColor blue = new CColor(color(10, 10, 200), color(10, 10, 100), color(10, 10, 230), color(0), color(255));

  //main buttons, all moved to global (not included in tab system)
  int buttonX = grid.gridX;
  int buttonY = Math.round(grid.gridY+gridH*cellH+hpc);
  int buttonW = Math.round(gridW*cellW/3);
  int buttonH = Math.round(grid.gridY/2);
  pause = cp5.addBang(obj, "0", "Pause (SPACE)", buttonX, buttonY, buttonW-1, buttonH).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo("global");
  restart = cp5.addBang(obj, "1", "Restart (BACKSPACE)", buttonX+buttonW, buttonY, buttonW, buttonH).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo("global");
  export = cp5.addBang(obj, "2", "Export (ENTER)", buttonX+2*buttonW+1, buttonY, buttonW-1, buttonH).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo("global");
  fullscreenB = cp5.addBang(obj, "3", "Full Screen", buttonX, grid.gridY-4*hpc, 2*wpc, 3*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo("global");
  fullscreenB.getCaptionLabel().getStyle().marginTop = -3*hpc;
  fullscreenB.getCaptionLabel().getStyle().marginLeft = 3*wpc;
  reset = cp5.addBang(obj, "4", "Restore to default", guiX, 92*hpc, 18*wpc, 3*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo("global");

  exit = cp5.addBang(obj, "2", "", buttonX+gridLength-2*wpc, grid.gridY-4*hpc, 2*wpc, 3*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo("global");


  //FIRST TAB: BASIC CONTROLS
  basic = cp5.getTab("default").activateEvent(true).setLabel("Basic controls").setId(1).setColorBackground(color(150)).setColorActive(color(210)).setColorForeground(color(180)).setColorLabel(color(255));

  //Radio button for resolution
  resolutionGr = cp5.addGroup("Resolution").setBackgroundHeight(10*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  resolutionGr.getCaptionLabel().getStyle().marginTop = hpc/4;
  res = cp5.addRadioButton("pickResolution", wpc, hpc).addItem("256 x 160", 0).addItem("512 x 320", 1);
  res.setItemHeight(2*hpc).setColor(grey).moveTo(resolutionGr);

  //colour limits
  limitsGr = cp5.addGroup("Colour Limits").setBackgroundHeight(25*hpc).setBackgroundColor(color(240)).setBarHeight(2*hpc);
  limitsGr.getCaptionLabel().getStyle().marginTop = hpc/4;
  //int limitsY = guiY + res.getBackgroundHeight() + 6*hpc;


  //using ranges
  limitsR = cp5.addRange("  Red\n  Range", 0, 255, 0, 255, wpc, 2*hpc, 16*wpc, 5*hpc).setDecimalPrecision(0).setHandleSize(wpc).moveTo(limitsGr);
  limitsG = cp5.addRange("  Green\n  Range", 0, 255, 0, 255, wpc, 10*hpc, 16*wpc, 5*hpc).setDecimalPrecision(0).setHandleSize(wpc).moveTo(limitsGr);
  limitsB = cp5.addRange("  Blue\n  Range", 0, 255, 0, 255, wpc, 18*hpc, 16*wpc, 5*hpc).setDecimalPrecision(0).setHandleSize(wpc).moveTo(limitsGr);
  limitsR.setHighValue(255).getCaptionLabel().getStyle().marginTop = -1*hpc;
  limitsG.setHighValue(255).getCaptionLabel().getStyle().marginTop = -1*hpc;
  limitsB.setHighValue(255).getCaptionLabel().getStyle().marginTop = -1*hpc;//get rid of decimals after high value


  //paint gun
  paintgunGr = cp5.addGroup("Paint Gun").setBackgroundHeight(30*hpc).setBarHeight(2*hpc);
  paintgunGr.getCaptionLabel().getStyle().marginTop = hpc/4;
  int gunY = 2*hpc;
  gunRS = cp5.addSlider("gunR", 0, 255, gunR, wpc, gunY, 4*wpc, 14*hpc).setCaptionLabel(" Gun R").setColor(red).moveTo(paintgunGr);
  gunGS = cp5.addSlider("gunG", 0, 255, gunG, 7*wpc, gunY, 4*wpc, 14*hpc).setCaptionLabel(" Gun G").setColor(green).moveTo(paintgunGr);
  gunBS = cp5.addSlider("gunB", 0, 255, gunB, 13*wpc, gunY, 4*wpc, 14*hpc).setCaptionLabel(" Gun B").setColor(blue).moveTo(paintgunGr);
  pelletSizeS = cp5.addSlider("pelletSize", 0, 5, 3, wpc, gunY+24*hpc, 16*wpc, 2*hpc).setCaptionLabel("   Size");
  pelletSizeS.showTickMarks(false).setColor(grey).setNumberOfTickMarks(6).moveTo(paintgunGr);
  pelletX = guiX + 15*hpc;
  pelletY = Math.round(gunY-1.52*2*hpc);

  //define accordion
  acco1 = cp5.addAccordion("acc", guiX, guiY, 18*wpc);
  acco1.addItem(resolutionGr).addItem(limitsGr).addItem(paintgunGr).setColorForeground(color(220)).setColorBackground(color(80));
  acco1.setCollapseMode(Accordion.MULTI).open(0, 1, 2);

  //set colours for sliders
  limitsR.setColor(red);
  limitsG.setColor(green);
  limitsB.setColor(blue);
  gunBS.setColor(blue).setColorValue(color(0));
  gunGS.setColor(green).setColorValue(color(0));
  gunRS.setColor(red).setColorValue(color(0));
  pelletSizeS.setColor(grey);

  //SECOND TAB: EFFECTS
  effects = cp5.addTab("Effects").setId(2).setColorBackground(color(150)).setColorActive(color(210));
  effects.setColorForeground(color(180)).setColorLabel(color(255)).activateEvent(true);

  //Checkbox for filters
  filtersGr = cp5.addGroup("Filters").setBackgroundHeight(8*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  filtersGr.getCaptionLabel().getStyle().marginTop = hpc/4;
  filt = cp5.addCheckBox("pickFilter", wpc, hpc).addItem("Black & White", 1).addItem("Posterise", 2).addItem("Blur", 3).addItem("Treshold", 4);
  filt.setItemHeight(2*hpc).setColor(grey).moveTo(filtersGr);
  //filter settings
  filterSettingsGr = cp5.addGroup("Filter Settings").setBackgroundHeight(7*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  filterSettingsGr.getCaptionLabel().getStyle().marginTop = hpc/4;
  posterKnob = cp5.addKnob("paramP", 2, 100, paramP, wpc, hpc, 3*wpc).setDragDirection(Knob.VERTICAL).setColor(grey).moveTo(filterSettingsGr);
  int blurX = Math.round(7.5*wpc);
  blurKnob = cp5.addKnob("paramB", 0, 10, paramB, blurX, hpc, 3*wpc).setDragDirection(Knob.VERTICAL).setColor(grey).moveTo(filterSettingsGr);
  threshKnob = cp5.addKnob("paramT", 0, 1, paramT, 28/2*wpc, hpc, 3*wpc).setDragDirection(Knob.VERTICAL).setColor(grey).moveTo(filterSettingsGr);
  posterKnob.setLabel("Posterise").setColorValue(color(255));
  blurKnob.setLabel("Blur").setColorValue(color(255));
  threshKnob.setLabel("Threshold").setDecimalPrecision(1).setColorValue(color(255));

  //Radio button for presets
  presetsGr = cp5.addGroup("Presets").setBackgroundHeight(13*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  presetsGr.getCaptionLabel().getStyle().marginTop = hpc/4;
  presets = cp5.addRadioButton("pickPresets", wpc, hpc).addItem("Default", 1).addItem("Fire", 2).addItem("Evening Sky", 3).addItem("Aurora Borealis", 4).addItem("Rorschach", 5);
  presets.setItemHeight(2*hpc).setColor(grey).moveTo(presetsGr).setNoneSelectedAllowed(false);

  //Radio button for symmetry
  symGr = cp5.addGroup("Symmetry").setBackgroundHeight(10*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  symGr.getCaptionLabel().getStyle().marginTop = hpc/4;
  syms = cp5.addRadioButton("setSymmetry", wpc, hpc).addItem("Off", 1).addItem("Vertical", 2).addItem("Horizontal", 3).setNoneSelectedAllowed(false);
  syms.setItemHeight(2*hpc).setColor(grey).moveTo(symGr);

  //Pattern Mode
  patternGr = cp5.addGroup("Pattern Mode").setBackgroundHeight(8*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  verticalMode = cp5.addBang(obj, "2", "Vertical Stripes", wpc, hpc, 5*wpc, 2*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo(patternGr);
  horizontalMode = cp5.addBang(obj, "2", "Horizontal Stripes", wpc, 6*hpc, 5*wpc, 2*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo(patternGr);
  
  //Pastel Mode
  pastelGr = cp5.addGroup("Pastel Mode").setBackgroundHeight(5*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  pastel = cp5.addBang(obj, "2", "Enable Pastel Colours", wpc, hpc, 5*wpc, 2*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo(pastelGr);
  
  //define accordion
  acco2 = cp5.addAccordion("acc2", guiX, guiY, 18*wpc);
  acco2.addItem(filtersGr).addItem(filterSettingsGr).addItem(presetsGr).addItem(symGr).addItem(patternGr).addItem(pastelGr).setColorForeground(color(220)).setColorBackground(color(80));
  acco2.setCollapseMode(Accordion.MULTI).open(0, 2, 3, 4, 5).moveTo(effects);

  //THIRD TAB: ADVANCED CONTROLS
  advanced = cp5.addTab("Advanced Controls").setId(3).setColorBackground(color(150)).setColorActive(color(210));
  advanced.setColorForeground(color(180)).setColorLabel(color(255)).activateEvent(true);

  //grid options
  gridGr = cp5.addGroup("Grid Options").setBackgroundHeight(6*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  rrS = cp5.addSlider("rr", -2, 1, -1, wpc, 5*hpc, 16*wpc, 2*hpc).setCaptionLabel(" Reverse\n rate").setColor(grey).moveTo(gridGr); //reverserate slider
  reinS = cp5.addSlider("rein", 0, 1, 0.1, wpc, hpc, 16*wpc, 2*hpc).setCaptionLabel(" Speed").setColor(grey).moveTo(gridGr); //speed slider

  //neighbour options
  neighboursGr = cp5.addGroup("Pick Neighbours").setBackgroundHeight(13*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  neighbox = cp5.addCheckBox("neighbox", wpc, hpc).setItemsPerRow(3).setSpacingColumn(1).setSpacingRow(1).setItemWidth(2*wpc).setItemHeight(2*wpc);
  neighbox.addItem("n1", 1).addItem("n2", 2).addItem("n3", 3).addItem("n4", 4).addItem("n5", 5).addItem("n6", 6)
    .addItem("n7", 7).addItem("n8", 8).addItem("n9", 9).setColor(black).setColorLabel(245).activateAll().moveTo(neighboursGr);
  wrap = cp5.addToggle("wrapping").setValue(false).setPosition(10*wpc, hpc).setSize(5*wpc, 2*hpc).setMode(ControlP5.SWITCH).setColor(grey).moveTo(neighboursGr);
  resetN = cp5.addBang(obj, "2", "Restart Grid", 10*wpc, 7*hpc, 5*wpc, 2*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo(neighboursGr);

  //flocking options
  flockingGr = cp5.addGroup("Flocking Options").setBackgroundHeight(13*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  flockingGr.getCaptionLabel().getStyle().marginTop = hpc/4;
  cohCoS = cp5.addSlider("cohCo", 0.5, 1.5, 1, wpc, hpc, 16*wpc, 2*hpc).setCaptionLabel(" Cohesion").moveTo(flockingGr);
  aliCoS = cp5.addSlider("aliCo", 0.5, 1.5, 1, wpc, 4*hpc, 16*wpc, 2*hpc).setCaptionLabel(" Alignment").moveTo(flockingGr);
  sepCoS = cp5.addSlider("sepCo", 0.5, 1.5, 1, wpc, 7*hpc, 16*wpc, 2*hpc).setCaptionLabel(" Separation").moveTo(flockingGr);

  //define accordion
  acco3 = cp5.addAccordion("acc3", guiX, guiY, 18*wpc);
  acco3.addItem(gridGr).addItem(neighboursGr).addItem(flockingGr).setColorForeground(color(220)).setColorBackground(color(80));
  acco3.setCollapseMode(Accordion.MULTI).open(0, 1, 2, 3).moveTo(advanced);
  //wrapLabel.setColorBackground(color(245));
  sepCoS.setColor(grey);
  cohCoS.setColor(grey);
  aliCoS.setColor(grey);
  reinS.setColor(grey);
  rrS.setColor(grey);


  //FOURTH TAB: STRIPES
  stripes = cp5.addTab("STRIPES").setId(4).setColorBackground(color(150)).setColorActive(color(210));
  stripes.setColorForeground(color(180)).setColorLabel(color(255)).activateEvent(true);

  positionGr = cp5.addGroup("Position").setBackgroundHeight(26*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  positionGr.getCaptionLabel().getStyle().marginTop = hpc/4;

  startStripes = cp5.addBang(obj, "2", "Enable Stripes", wpc, hpc, 3*wpc, 2*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo(positionGr);
  startStripes.getCaptionLabel().getStyle().marginTop = -2*hpc;
  startStripes.getCaptionLabel().getStyle().marginLeft = 5*wpc;
  stripeWS = cp5.addSlider("stripeWidth", 0, 256, 10, wpc, 5*hpc, 16*wpc, 2*hpc).setCaptionLabel("  Width").setColor(grey).setNumberOfTickMarks(129).showTickMarks(false).moveTo(positionGr);
  stripeSS = cp5.addSlider("stripeGap", 0, 256, 10, wpc, 9*hpc, 16*wpc, 2*hpc).setCaptionLabel("  Spacing").setColor(grey).setNumberOfTickMarks(129).showTickMarks(false).moveTo(positionGr);
  stripeOS = cp5.addRange("stripeOffset", 0, 256, 0, 256, wpc, 13*hpc, 16*wpc, 2*hpc).setCaptionLabel("  Offset").setColor(grey).moveTo(positionGr);
  stripeOS.setHighValue(256);

  stripeOrientation = cp5.addRadioButton("chooseOrientation", wpc, 18*hpc).addItem("Vertical ", 1).addItem("Horizontal ", 2).addItem("Checked ", 3);
  stripeOrientation.setItemHeight(2*hpc).setColor(grey).moveTo(positionGr);

  stripeColourGr = cp5.addGroup("Stripe Colour").setBackgroundHeight(13*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  stripeColourGr.getCaptionLabel().getStyle().marginTop = hpc/4;

  stripeRS = cp5.addSlider("stripeR", 0, 255, stripeR, wpc, hpc, 16*wpc, 3*hpc).setColor(red).moveTo(stripeColourGr).setCaptionLabel("");
  stripeGS = cp5.addSlider("stripeG", 0, 255, stripeG, wpc, 5*hpc, 16*wpc, 3*hpc).setColor(green).moveTo(stripeColourGr).setCaptionLabel("");
  stripeBS = cp5.addSlider("stripeB", 0, 255, stripeB, wpc, 9*hpc, 16*wpc, 3*hpc).setColor(blue).moveTo(stripeColourGr).setCaptionLabel("");

  backgroundGr = cp5.addGroup("Background").setBackgroundHeight(19*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  backgroundGr.getCaptionLabel().getStyle().marginTop = hpc/4;

  backRS = cp5.addSlider("backR", 0, 255, backR, wpc, 4*hpc, 16*wpc, 3*hpc).moveTo(backgroundGr).setCaptionLabel("");
  backGS = cp5.addSlider("backG", 0, 255, backG, wpc, 8*hpc, 16*wpc, 3*hpc).moveTo(backgroundGr).setCaptionLabel("");
  backBS = cp5.addSlider("backB", 0, 255, backB, wpc, 12*hpc, 16*wpc, 3*hpc).moveTo(backgroundGr).setCaptionLabel("");

  solidBack = cp5.addBang(obj, "2", "Solid Background", wpc, hpc, 3*wpc, 2*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo(backgroundGr);
  solidBack.getCaptionLabel().getStyle().marginTop = -2*hpc;
  solidBack.getCaptionLabel().getStyle().marginLeft = 4*wpc;
  embed = cp5.addBang(obj, "2", "Embed Stripes", wpc, 16*hpc, 3*wpc, 2*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo(backgroundGr);
  embed.getCaptionLabel().getStyle().marginTop = -2*hpc;
  embed.getCaptionLabel().getStyle().marginLeft = 4*wpc;

  layerGr = cp5.addGroup("Layers").setBackgroundHeight(15*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  layerGr.getCaptionLabel().getStyle().marginTop = hpc/4;

  addLayer = cp5.addBang(obj, "2", " Add Layer", wpc, hpc, 3*wpc, 2*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo(layerGr);
  addLayer.getCaptionLabel().getStyle().marginTop = -2*hpc;
  addLayer.getCaptionLabel().getStyle().marginLeft = 3*wpc;
  removeLayer = cp5.addBang(obj, "2", " Remove Layer", wpc, 5*hpc, 3*wpc, 2*hpc).setTriggerEvent(Bang.RELEASE).setColor(grey).moveTo(layerGr);
  removeLayer.getCaptionLabel().getStyle().marginTop = -2*hpc;
  removeLayer.getCaptionLabel().getStyle().marginLeft = 3*wpc;
  layerNumber = cp5.addRadioButton("chooseLayer", 2*wpc, 10*hpc).addItem("1", 1).addItem("2", 2).addItem("3", 3).addItem("4", 4).setNoneSelectedAllowed(false).setCaptionLabel("Choose active layer").showLabels();
  layerNumber.setItemHeight(2*hpc).setColor(grey).setItemsPerRow(4).setSpacingColumn(2*wpc).moveTo(layerGr);

  warpGr = cp5.addGroup("Warp").setBackgroundHeight(5*hpc).setBackgroundColor(color(245)).setBarHeight(2*hpc);
  warpGr.getCaptionLabel().getStyle().marginTop = hpc/4;
  warpS = cp5.addSlider("warp", 0, gridW/4, 0, wpc, hpc, 16*wpc, 2*hpc).setCaptionLabel("  Warp").setColor(grey).moveTo(warpGr);


  acco4 = cp5.addAccordion("acc4", guiX, guiY, 18*wpc);
  acco4.addItem(positionGr).addItem(stripeColourGr).addItem(backgroundGr).addItem(layerGr).addItem(warpGr).setColorForeground(color(220)).setColorBackground(color(80));
  acco4.setCollapseMode(Accordion.MULTI).open(0, 1, 3).moveTo(stripes);

  stripeRS.setColor(red);
  backRS.setColor(red);
  stripeGS.setColor(green);
  backGS.setColor(green);
  stripeBS.setColor(blue);
  backBS.setColor(blue);



  font = new ControlFont(pfont, hpc+5);
  cp5.setFont(font);
  info = cp5.addTextarea("info", "", grid.gridX, buttonY+buttonH*3, gridLength, 10*hpc).setColorValue(color(0)).moveTo("global");
}


//handle events for resolution and main buttons
void controlEvent(ControlEvent theEvent) {
  //restart grid with appropriate resolution when new one selected
  if (theEvent.isGroup()) {
    if (theEvent.isFrom(res)) {
      float choice = theEvent.getGroup().getValue();
      if (choice == 0.0) {
        gridW=256;
        gridH=160;
        cellW=1024/gridW;
        cellH=640/gridH;
        reinS.setValue(0.1);
        gi = createImage(gridW, gridH, RGB);
        grid.restart(1);
        stripeBuffer = createImage(gridW, gridH, ARGB);
        layer1 = createImage(gridW, gridH, ARGB);
        layer2 = createImage(gridW, gridH, ARGB);
        layer3 = createImage(gridW, gridH, ARGB);
        layer4 = createImage(gridW, gridH, ARGB);
      } else {
        gridW=512;
        gridH=320;
        cellW=1024/gridW;
        cellH=640/gridH;
        reinS.setValue(0.2);
        gi = createImage(gridW, gridH, RGB);
        grid.restart(1);
        stripeBuffer = createImage(gridW, gridH, ARGB);
        layer1 = createImage(gridW, gridH, ARGB);
        layer2 = createImage(gridW, gridH, ARGB);
        layer3 = createImage(gridW, gridH, ARGB);
        layer4 = createImage(gridW, gridH, ARGB);
      }
    }

    //add/remove filters
    else if (theEvent.isFrom(filt)) {
      float[] checks = theEvent.getGroup().getArrayValue();

      f1 = Math.round(checks[0]);
      f2 = Math.round(checks[1]);
      f3 = Math.round(checks[2]);
      f4 = Math.round(checks[3]);
    }
    //edit neighbours
    else if (theEvent.isFrom(neighbox)) {
      float[] checks = theEvent.getGroup().getArrayValue();

      n1 = Math.round(checks[0]);
      n2 = Math.round(checks[1]);
      n3 = Math.round(checks[2]);
      n4 = Math.round(checks[3]);
      n6 = Math.round(checks[5]);
      n7 = Math.round(checks[6]);
      n8 = Math.round(checks[7]);
      n9 = Math.round(checks[8]);
    }
    //launch presets
    else if (theEvent.isFrom(presets)) {
      float choice = theEvent.getGroup().getValue();
      if (choice == 1.0) {
        resetGUI();
      } else if (choice == 2.0) {
        fire();
      } else if (choice == 3.0) {
        eveningSky();
      } else if (choice == 4.0) {
        aurora();
      } else if (choice == 5.0) {
        rorschach();
      }
    } else if (theEvent.isFrom(syms)) {
      float choice = theEvent.getGroup().getValue();
      if (choice == 1.0) {
        symmetry=0;
      } else if (choice == 2.0) {
        symmetry=1;
      } else if (choice == 3.0) {
        symmetry=2;
      }
    } else if (theEvent.isFrom(stripeOrientation)) {
      float choice = theEvent.getGroup().getValue();
      if (choice == 1.0) {
        ver=1;
        hor=0;
      } else if (choice == 2.0) {
        ver=0;
        hor=1;
      } else if (choice == 3.0) {
        ver=1;
        hor=1;
      }
    } else if (theEvent.isFrom(layerNumber)) {
      float choice = theEvent.getGroup().getValue();
      
      if (previousLayer==1) {
        layer1 = stripeBuffer.copy();
      } else if (previousLayer==2) {
        layer2 = stripeBuffer.copy();
      } else if (previousLayer == 3){
        layer3 = stripeBuffer.copy();
      } else if (previousLayer == 4){
        layer4 = stripeBuffer.copy();
      }
      
      activeLayer = int(choice);
      
      if (activeLayer==1) {
        stripeBuffer = layer1.copy();
      } else if (activeLayer==2) {
        stripeBuffer = layer2.copy();
      } else if (activeLayer==3) {
        stripeBuffer = layer3.copy();
      } else if (activeLayer==4) {
        stripeBuffer = layer4.copy();
      }
      int index=previousLayer-1;
      int index2=activeLayer-1;
      
      
      
      widths[index]=stripeWidth;
      gaps[index]=stripeGap;
      offsets[index]=stripeOffset;
      offsets2[index]=sOff2;
      stripeReds[index]=stripeR;
      stripeGreens[index]=stripeG;
      stripeBlues[index]=stripeB;
      
      stripeWS.setValue(widths[index2]);
      stripeGS.setValue(gaps[index2]);
      stripeOS.setLowValue(offsets[index2]).setHighValue(offsets2[index2]);
      stripeRS.setValue(stripeReds[index2]);
      stripeGS.setValue(stripeGreens[index2]);
      stripeBS.setValue(stripeBlues[index2]);
      warpS.setValue(warps[index2]);
      
      previousLayer=activeLayer;
    }
  } else if (theEvent.isController()) {
    //pause/start
    if (theEvent.isFrom(pause)) {
      startPause();
    }
    //restart
    else if (theEvent.isFrom(restart)) {
      grid.restart(2);
    }
    //save grid as PImage and export
    else if (theEvent.isFrom(export)) {
      export();
    }
    //full screen mode
    else if (theEvent.isFrom(fullscreenB)) {
      fs++;
      alpha=55;
      time=millis();
    }
    //quit the program
    else if (theEvent.isFrom(exit)) {
      exit();
    }
    //set new R limits
    else if (theEvent.isFrom(limitsR)) {
      lowLimR = int(theEvent.getController().getArrayValue(0));
      uppLimR = int(theEvent.getController().getArrayValue(1));
    }
    //set new G limits
    else if (theEvent.isFrom(limitsG)) {
      lowLimG = int(theEvent.getController().getArrayValue(0));
      uppLimG = int(theEvent.getController().getArrayValue(1));
    }
    //set new B limits
    else if (theEvent.isFrom(limitsB)) {
      lowLimB = int(theEvent.getController().getArrayValue(0));
      uppLimB = int(theEvent.getController().getArrayValue(1));
    } else if (theEvent.isFrom(stripeOS)) {
      stripeOffset = int(theEvent.getController().getArrayValue(0));
      sOff2 = int(theEvent.getController().getArrayValue(1));
    }



    //restart with new neighbours
    else if (theEvent.isFrom(resetN)) {
      grid.restart(1);
    }

    //reset GUI
    else if (theEvent.isFrom(reset)) {
      resetGUI();
    }
    //Pattern modes
    else if (theEvent.isFrom(horizontalMode)) {
      n1=n2=n3=n6=n7=n8=n9=0.0;
      n4=1.0;
      wrapping=true;
      reinS.setValue(1);
      rrS.setValue(1);
      grid.restart(1);
    } else if (theEvent.isFrom(verticalMode)) {
      n1=n3=n4=n6=n7=n8=n9=0.0;
      n2=1.0;
      wrapping=true;
      reinS.setValue(1);
      rrS.setValue(1);
      grid.restart(1);
    }
    else if (theEvent.isFrom(pastel)) {
      if (pastelMode==0) {
        pastelMode=1;
        pastel.setCaptionLabel("Disable Pastel Colours");
      } else {
        pastelMode=0;
        pastel.setCaptionLabel("Enable Pastel Colours");
      }
    }

    //STRIPES
    else if (theEvent.isFrom(startStripes)) {
      if (useStripes==0) {
        useStripes=1;
        startStripes.setCaptionLabel("Disable Stripes");
      } else {
        useStripes=0;
        startStripes.setCaptionLabel("Enable Stripes");
      }
    } else if (theEvent.isFrom(addLayer)) {
      if (layerCount<4) {
        print(layerCount);
        int index = layerCount-1;
        widths[index]=stripeWidth;
        gaps[index]=stripeGap;
        offsets[index]=stripeOffset;
        offsets2[index]=sOff2;
        stripeReds[index]=stripeR;
        stripeGreens[index]=stripeG;
        stripeBlues[index]=stripeB;
        if (layerCount==1) {
          layer1 = stripeBuffer.copy();
        } else if (layerCount==2) {
         layer2 = stripeBuffer.copy();
        } else if (layerCount==3) {
         layer3 = stripeBuffer.copy();
        } else if (layerCount==4) {
         layer4 = stripeBuffer.copy();
        }
        stripeRS.setValue(random(256));
        stripeGS.setValue(random(256));
        stripeBS.setValue(random(256));
        stripeWS.setValue(random(20));
        layerCount+=1;
        activeLayer=layerCount;
        previousLayer=activeLayer;
      }
    } else if (theEvent.isFrom(removeLayer)) {
      int index;
      if (activeLayer==1) {
        index=activeLayer;
      } else {index = activeLayer-2;}
      
      stripeWS.setValue(widths[index]);
      stripeGS.setValue(gaps[index]);
      stripeOS.setLowValue(offsets[index]).setHighValue(offsets2[index]);
      stripeRS.setValue(stripeReds[index]);
      stripeGS.setValue(stripeGreens[index]);
      stripeBS.setValue(stripeBlues[index]);
      warpS.setValue(warps[index]);
      
      if (activeLayer == 1) {
        layer1 = createImage(gridW,gridH, ARGB);
      } else if (activeLayer==2) {
        layer2 = createImage(gridW,gridH, ARGB);
      } else if (activeLayer==3) {
        layer3 = createImage(gridW,gridH, ARGB);
      } else if (activeLayer == 4) {
        layer4 = createImage(gridW,gridH, ARGB);
      }
      
      if (layerCount!=1) {
        layerCount-=1;
        
      }
      activeLayer=index+1;
    } else if (theEvent.isFrom(solidBack)) {
      if (background==0) {
        background=1;
        solidBack.setCaptionLabel("Grid Background");
      } else {
        background=0;
        solidBack.setCaptionLabel("Solid Background");
      }
    } else if (theEvent.isFrom(embed)) {
      if (stripeEmbed==0) {
        stripeEmbed=1;
        embed.setCaptionLabel("Remove Embedding");
      } else {
        stripeEmbed=0;
        embed.setCaptionLabel("Embed Stripes");
      }
    }
  }
  //change tab
  else if (theEvent.isTab()) {
    switch(theEvent.getTab().getId()) {
      case(1):
      bas=1;
      eff=0;
      adv=0;
      sti=0;
      break;
      case(2):
      bas=0;
      eff=1;
      adv=0;
      sti=0;
      break;
      case(3):
      bas=0;
      eff=0;
      adv=1;
      sti=0;
      break;
      case(4):
      bas=0;
      eff=0;
      adv=0;
      sti=1;
      break;
    }
  }
}


void keyPressed() {
  switch(key) {
    case(' '):
    startPause();
    break;
    case(BACKSPACE):
    grid.restart(1);
    restart.setCaptionLabel("Restart");
    break;
    case(ENTER):
    export();
    export.setCaptionLabel("Export");
    break;
    case(RETURN):
    export();
    export.setCaptionLabel("Export");
    break;
    case('f'):
    fs++;
    alpha=55;
    time=millis();
    break;
    case(ESC):
    if (fs%2==0) {
      fs++;
      key=0;
    } else {key=0;
    };
    break;
    case(TAB):
    switch(bas) {
      case(1):
      effects.bringToFront();
      bas=0;
      eff=1;
      adv=0;
      sti=0;
      break;
      case(0):
      if (eff==1) {
        advanced.bringToFront();
        bas=0;
        eff=0;
        adv=1;
        sti=0;
      } else {
        if (adv==1) {
          stripes.bringToFront();
          bas=0;
          eff=0;
          adv=0;
          sti=1;
        } else {
          basic.bringToFront();
          bas=1;
          eff=0;
          adv=0;
          sti=0;
        }
      };
      break;
    }
  }
}


void startPause() {
  if (flick==0) {
    flick=1;
    pause.setCaptionLabel("Start");
  } else if (flick==1) {
    flick=0;
    pause.setCaptionLabel("Pause");
  }
}

void export() {
  snaps++;
  snap = get(grid.gridX, grid.gridY, 1024, 640);
  if (fs%2==0) {
    save("Snap "+ snaps +".jpg");
  } else {
    snap.save("Snap "+ snaps +".jpg");
  }
}

void gridFullScreen() {
  snap = get(grid.gridX, grid.gridY, 1024, 640);
  image(snap, 0, 0, width, height);
  if (millis() - time >= wait) {
    noCursor();
    if (alpha>0) {
      alpha -= 10;
    }
  }
  //message that fades out after the wait
  String messageFS = "Press Esc or F to exit full screen mode";
  rectMode(CENTER);
  fill(0, 0, 0, alpha);
  noStroke();
  rect(width/2, height/2, 40*wpc, 8*hpc); 
  fill(255, 255, 255, 5*alpha);
  textSize(2*hpc);
  textAlign(CENTER);
  text(messageFS, width/2, height/2);
}

void applyFilters() {
  filGrid = get(grid.gridX, grid.gridY, gridW*cellW, gridH*cellH);
  if (f1 == 1) {
    filGrid.filter(GRAY);
  }
  if (f2 == 1) {
    filGrid.filter(POSTERIZE, paramP);
  }
  if (f3 == 1) {
    filGrid.filter(BLUR, paramB);
  }
  if (f4 == 1) {
    filGrid.filter(THRESHOLD, paramT);
  }
  if (f1 > 0 || f2 > 0 || f3 > 0 || f4 > 0) {
    image(filGrid, grid.gridX, grid.gridY, gridLength, gridHeight);
  }
}

void symmetry(int x) {
  if (x == 1) {
    sym.beginDraw();
    sym.image(gi, 0+1024/2, Y, 1024/2, 640);
    sym.pushMatrix();
    sym.scale(-1.0, 1.0);
    sym.image(gi, 0, 0, -1024/2, 640);
    sym.popMatrix();
    sym.endDraw();
  } else {
    sym.beginDraw();
    sym.image(gi, 0, 320, 1024, 640/2);
    sym.pushMatrix();
    sym.scale(1.0, -1.0);
    sym.image(gi, 0, 0, 1024, -640/2);
    sym.popMatrix();
    sym.endDraw();
  }
}

void displayInfo() {
  if (cp5.isMouseOver(pause)) {
    info.setText("Pause or resume the animation. (Shortcut: spacebar)");
  } else if (cp5.isMouseOver(restart)) {
    info.setText("Reinitialise the grid and restart the animation. (Shortcut: backspace)");
  } else if (cp5.isMouseOver(export)) {
    info.setText("Save the current frame as a JPG file in the folder from which the application is running. (Shortcut: enter)");
  } else if (cp5.isMouseOver(fullscreenB)) {
    info.setText("Switch to full screen mode. (Shortcut: F)");
  } else if (cp5.isMouseOver(exit)) {
    info.setText("Quit the application.");
  } else if (cp5.isMouseOver(resolutionGr)) {
    info.setText("Renitialise the grid with a new resolution. The default is set at 256*160. 512*320 will take some time to initialise but is not too heavy on CPU.");
  } else if (cp5.isMouseOver(reinS)) {
    info.setText("Adjust the speed with which the cells are able to change colour.");
  } else if (cp5.isMouseOver(limitsR)) {
    info.setText("Using the handles on each side of the slider, set the lower and upper limit of the red component of each cell. The range itself is also draggable.");
  } else if (cp5.isMouseOver(limitsG)) {
    info.setText("Using the handles on each side of the slider, set the lower and upper limit of the green component of each cell. The range itself is also draggable.");
  } else if (cp5.isMouseOver(limitsB)) {
    info.setText("Using the handles on each side of the slider, set the lower and upper limit of the blue component of each cell. The range itself is also draggable.");
  } else if (cp5.isMouseOver(paintgunGr)) {
    info.setText("Adjust the red, green and blue components of the paint gun, as well as the pellet size. The pellet size is based on the number of cells which get painted and does not scale with resolution.");
  } else if (cp5.isMouseOver(filtersGr)) {
    info.setText("Apply a filter to the image. See the filter settings for more information.");
  } else if (cp5.isMouseOver(posterKnob)) {
    info.setText("The posterise filter limits the number of colours available to the renderer. Use the knob to select the number of colours allowed by dragging vertically.");
  } else if (cp5.isMouseOver(blurKnob)) {
    info.setText("Select the radius of the Gaussian blur by dragging vertically. The higher the radius, the more CPU-heavy the filter. It is recommended to pause the animation before using the blur filter, and de-activating it before resuming.");
  } else if (cp5.isMouseOver(threshKnob)) {
    info.setText("The threshold filter turns every pixel whose colour is about the threshold to white, and all those under to black. Use the knob to select the threshold by dragging vertically.");
  } else if (cp5.isMouseOver(basic)) {
    info.setText("The tab containing the basic controls for the grid. Use the TAB key to cycle through the tabs.");
  } else if (cp5.isMouseOver(effects)) {
    info.setText("Apply effects to the grid from within this tab. Use the TAB key to cycle through the tabs.");
  } else if (cp5.isMouseOver(advanced)) {
    info.setText("More advanced controls for the grid. Use the TAB key to cycle through the tabs.");
  } else if (cp5.isMouseOver(wrap)) {
    info.setText("Enable this option to wrap the cells: anything that comes off the top of the screen will re-appear at the bottom and vice versa. The same rule applies for left and right. Click 'Restart Grid' to initalise.");
  } else if (cp5.isMouseOver(neighboursGr)) {
    info.setText("Click on the boxes to enable or disable a cell as a neighbour to the one in the middle. The middle cell is only influenced by the colour of it's neighbours, so disabling some can have interesting effects. Be sure to restart the grid once you have selected new neighbours.");
  } else if (cp5.isMouseOver(rrS)) {
    info.setText("To avoid one colour taking over the entire grid, once a cell reaches the maximum level of either red, green, or blue, the programme caps that colour and gradually reduces it. This variable controls the rate at which this reduction is made.");
  } else if (cp5.isMouseOver(reset)) {
    info.setText("Restore all of the settings to their default value.");
  } else if (cp5.isMouseOver(flockingGr)) {
    info.setText("The colours shifts of the grid are based on a flocking algorithm. The sliders below allow you to modify the parameters of this algorithm.");
  } else if (cp5.isMouseOver(cohCoS)) {
    info.setText("A high cohesion coefficient makes the cells more likely to shift toward the average colour of their neighbours.");
  } else if (cp5.isMouseOver(aliCoS)) {
    info.setText("Increasing the alignement coefficient will cause the cells to follow the colour shifts of their neighbours.");
  } else if (cp5.isMouseOver(sepCoS)) {
    info.setText("The separation coefficient (also known as short range repulsion) controls the tendency of cells to not exactly match the colour of their neighbours.");
  } else if (cp5.isMouseOver(symGr)) {
    info.setText("Set a horizontal or vertical axis of symmetry in the middle of the grid. The paint gun will be affected.");
  } else if (cp5.isMouseOver(stripes)) {
    info.setText("Include stripe-based patterns over the grid.");
  } else if (cp5.isMouseOver(patternGr)) {
    info.setText("Create random stripes over the grid. Head the to 'Stripes' tab to have more control over the stripes.");
  } else if (cp5.isMouseOver(stripeWS)) {
    info.setText("Set the width of the stripes.");
  } else if (cp5.isMouseOver(stripeSS)) {
    info.setText("Set the sapce between each of the stripes.");
  } else if (cp5.isMouseOver(stripeOS)) {
    info.setText("Change the position of the stripes. Use the left handle to affect the horizontal position and the right handle to affect the vertical position.");
  } else if (cp5.isMouseOver(solidBack)) {
    info.setText("Alternate between using the grid as background and using a fixed colour (use sliders to set colour).");
  } else if (cp5.isMouseOver(embed)) {
    info.setText("Include or exclude the stripes in the colour generating algorithm.");
  } else if (cp5.isMouseOver(warpS)) {
    info.setText("The warp slider allows you to modify the stripe creating algorithm. You can achieve interesting patterns by setting a warp setting and playing with width and spacing.");
  } else if (cp5.isMouseOver(layerGr)) {
    info.setText("Add or remove layers, and choose which one to edit.");
  } else if (cp5.isMouseOver(pastel)) {
    info.setText("Give a pastel tint to the grid for easier-on-the-eyes colours.");
  } else {
    info.setText("");
  }
}



class Grid {
  ArrayList<Cell> cells;
  int gridX = Math.round(width*0.26);
  int gridY = Math.round(height*0.07);


  Grid() {
    cells = new ArrayList<Cell>();
    colours = new ArrayList<Integer>();
    n2 = n4 = n6 = n8 = 1.0;
    n1 = n3 = n7 = n9 = 1.0;
    sym = createGraphics(1024, 640, P2D);
  }

  void addCells() {
    //Use loop to reach every cell emplacement and add a cell in it
    int i, j;
    for (i=0; i<gridH; i++) {
      for (j=0; j<gridW; j++) {
        int cellX = Math.round(j*cellW+gridX);
        int cellY = Math.round(i*cellH+gridY);
        cells.add(new Cell(cellX, cellY, cellW, cellH));
      }
    }
  }

  void findNeighbours() {
    //Loop to find neighbours, using logical statements for corners and edges
    for (Cell c : cells) {
      int index=cells.indexOf(c);
      if (index % gridW == 0) {
        if (index / gridW < 1) {
          if (n1==1.0 && wrapping) {
            c.neighbours.add(cells.get(cells.size()-1));
          };
          if (n2==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+((gridH-1)*gridW)));
          };
          if (n3==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+((gridH-1)*gridW)+1));
          };
          if (n4==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+gridW-1));
          };
          if (n6==1.0) {
            c.neighbours.add(cells.get(index+1));
          };
          if (n7==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+2*gridW-1));
          };
          if (n8==1.0) {
            c.neighbours.add(cells.get(index+gridW));
          };
          if (n9==1.0) {
            c.neighbours.add(cells.get(index+gridW+1));
          };
        } else if (index / gridW >= gridH-1) {
          if (n1==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-1));
          };
          if (n2==1.0) {
            c.neighbours.add(cells.get(index-gridW));
          };
          if (n3==1.0) {
            c.neighbours.add(cells.get(index-gridW+1));
          };
          if (n4==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+gridW-1));
          };
          if (n6==1.0) {
            c.neighbours.add(cells.get(index+1));
          };
          if (n7==1.0 && wrapping) {
            c.neighbours.add(cells.get(gridW-1));
          };
          if (n8==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-((gridH-1)*gridW)));
          };
          if (n9==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-((gridH-1)*gridW)+1));
          };
        } else {
          if (n1==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-1));
          };
          if (n2==1.0) {
            c.neighbours.add(cells.get(index-gridW));
          };
          if (n3==1.0) {
            c.neighbours.add(cells.get(index-gridW+1));
          };
          if (n4==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+gridW-1));
          };
          if (n6==1.0) {
            c.neighbours.add(cells.get(index+1));
          };
          if (n7==1.0 && wrapping) {
            c.neighbours.add(cells.get(gridW-1));
          };
          if (n8==1.0) {
            c.neighbours.add(cells.get(index+gridW));
          };
          if (n9==1.0) {
            c.neighbours.add(cells.get(index+gridW+1));
          };
        }
      } else if ((index+1) % gridW == 0) {
        if (index / gridW < 1) {
          if (n1==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+((gridH-1)*gridW)-1));
          };
          if (n2==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+((gridH-1)*gridW)));
          };
          if (n3==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-gridW+1));
          };
          if (n4==1.0) {
            c.neighbours.add(cells.get(index-1));
          };
          if (n6==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+1));
          };
          if (n7==1.0) {
            c.neighbours.add(cells.get(index+gridW-1));
          };
          if (n8==1.0) {
            c.neighbours.add(cells.get(index+gridW));
          };
          if (n9==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+gridW+1));
          };
        } else if (index / gridW >= gridH-1) {
          if (n1==1.0) {
            c.neighbours.add(cells.get(index-gridW-1));
          };
          if (n2==1.0) {
            c.neighbours.add(cells.get(index-gridW));
          };
          if (n3==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-gridW+1));
          };
          if (n4==1.0) {
            c.neighbours.add(cells.get(index-1));
          };
          if (n6==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-gridW+1));
          };
          if (n7==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-((gridH-1)*gridW)+1));
          };
          if (n8==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-((gridH-1)*gridW)));
          };
          if (n9==1.0 && wrapping) {
            c.neighbours.add(cells.get(0));
          };
        } else {
          if (n1==1.0) {
            c.neighbours.add(cells.get(index-gridW-1));
          };
          if (n2==1.0) {
            c.neighbours.add(cells.get(index-gridW));
          };
          if (n3==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-2*gridW+1));
          };
          if (n4==1.0) {
            c.neighbours.add(cells.get(index-1));
          };
          if (n6==1.0 && wrapping) {
            c.neighbours.add(cells.get(index-gridW+1));
          };
          if (n7==1.0) {
            c.neighbours.add(cells.get(index+gridW-1));
          };
          if (n8==1.0) {
            c.neighbours.add(cells.get(index+gridW));
          };
          if (n9==1.0 && wrapping) {
            c.neighbours.add(cells.get(index+1));
          };
        }
      } else if (index / gridW < 1) {
        if (n1==1.0 && wrapping) {
          c.neighbours.add(cells.get(index+((gridH-1)*gridW)-1));
        };
        if (n2==1.0 && wrapping) {
          c.neighbours.add(cells.get(index+((gridH-1)*gridW)));
        };
        if (n3==1.0 && wrapping) {
          c.neighbours.add(cells.get(index+((gridH-1)*gridW)+1));
        };
        if (n4==1.0) {
          c.neighbours.add(cells.get(index-1));
        };
        if (n6==1.0) {
          c.neighbours.add(cells.get(index+1));
        };
        if (n7==1.0) {
          c.neighbours.add(cells.get(index+gridW-1));
        };
        if (n8==1.0) {
          c.neighbours.add(cells.get(index+gridW));
        };
        if (n9==1.0) {
          c.neighbours.add(cells.get(index+gridW+1));
        };
      } else if (index / gridW >= gridH-1) {
        if (n1==1.0) {
          c.neighbours.add(cells.get(index-gridW-1));
        };
        if (n2==1.0) {
          c.neighbours.add(cells.get(index-gridW));
        };
        if (n3==1.0) {
          c.neighbours.add(cells.get(index-gridW+1));
        };
        if (n4==1.0) {
          c.neighbours.add(cells.get(index-1));
        };
        if (n6==1.0) {
          c.neighbours.add(cells.get(index+1));
        };
        if (n7==1.0 && wrapping) {
          c.neighbours.add(cells.get(index-((gridH-1)*gridW)+1));
        };
        if (n8==1.0 && wrapping) {
          c.neighbours.add(cells.get(index-((gridH-1)*gridW)));
        };
        if (n9==1.0 && wrapping) {
          c.neighbours.add(cells.get(index-((gridH-1)*gridW)-1));
        };
      } else {
        if (n1==1.0) {
          c.neighbours.add(cells.get(index-gridW-1));
        };
        if (n2==1.0) {
          c.neighbours.add(cells.get(index-gridW));
        };
        if (n3==1.0) {
          c.neighbours.add(cells.get(index-gridW+1));
        };
        if (n4==1.0) {
          c.neighbours.add(cells.get(index-1));
        };
        if (n6==1.0) {
          c.neighbours.add(cells.get(index+1));
        };
        if (n7==1.0) {
          c.neighbours.add(cells.get(index+gridW-1));
        };
        if (n8==1.0) {
          c.neighbours.add(cells.get(index+gridW));
        };
        if (n9==1.0) {
          c.neighbours.add(cells.get(index+gridW+1));
        };
      }
    }
  }

  void refresh() {
    if (flick==0) {
      colours.clear();
    };

    for (Cell c : cells) {
      if (flick==0) {
        c.update();  //updating each cell's colour
      
      c.render(); // looping through all the cells to render each one
      }
      if (mousePressed) {
        c.paint();
      }
    }
    gi.loadPixels();
    stripeBuffer.loadPixels();
    for (int i = 0; i < gridW*gridH; i++) {
      gi.pixels[i] = colours.get(i);
      if (useStripes==1) {
        stripes(i, stripeWidth, stripeGap, stripeOffset, sOff2);
      }
    }
    gi.updatePixels();
    stripeBuffer.updatePixels();
  }

  void restart(int type) {
    if (type==1) {
      cells.clear();
      addCells();
      findNeighbours();
    } else { //quicker restart (no recreating the grid) if resolution is not changed
      colours.clear();
      for (Cell c : cells) {
        c.cellR = random(lowLimR, uppLimR);
        c.cellG = random(lowLimG, uppLimG);
        c.cellB = random(lowLimB, uppLimB);
        c.tempR = c.cellR; 
        c.tempG = c.cellG;
        c.tempB = c.cellB;
        c.cellVR = c.cellVG = c.cellVB = c.tempVR = c.tempVG = c.tempVB = 0;
        colours.add(color(c.cellR, c.cellG, c.cellB));
      }
    }
  }
}

class Cell {

  int cellX, cellY, cellW, cellH;
  float cellR, cellG, cellB; //a cell's colours
  float tempR, tempG, tempB; //a temporary value for each colour to act as buffer during the update loop
  float cellVR, cellVG, cellVB; //velocity (rate at which it's evolving) for each colour
  float tempVR, tempVG, tempVB; //temporary velocity
  float cohR, cohG, cohB; //cohesion variable (average colour of neighbours)
  float aliR, aliG, aliB; //alignment variable (average velocity of neighbours)
  float sepR, sepG, sepB; //separation variable (to ensure cells don't all become the same colour)
  int sepNormMag = 4;
  ArrayList<Cell> neighbours; //to hold the neighbours


  //Initialising cells with an x,y, width, height, initial random colour and null velocity (+empty neighbours array)
  Cell(int x, int y, int w, int h) {
    cellX = x;
    cellY = y;
    cellW = w;
    cellH = h;
    cellR = random(lowLimR, uppLimR); 
    cellG = random(lowLimG, uppLimG);
    cellB = random(lowLimB, uppLimB);
    tempR = cellR; 
    tempG = cellG;
    tempB = cellB;
    cellVR = 0; 
    cellVG = 0;
    cellVB = 0;
    tempVR=0; 
    tempVG=0;
    tempVB=0;
    neighbours = new ArrayList<Cell>();
    colours.add(color(cellR, cellG, cellB));
  }

  //function to update colour
  void update() {
    cohR = cohG = cohB = 0;
    aliR = aliG = aliB = 0;
    sepR = sepG = sepB = 0;
    int num = 0;
    //looping through neighbours to compute coh, ali, and sep values
    for (Cell n : neighbours) {
      cohR += n.cellR;
      cohG += n.cellG;
      cohB += n.cellB;
      aliR += n.cellVR;
      aliG += n.cellVG;
      aliB += n.cellVB;
      float distR = (cellR - n.cellR);
      float distG = (cellG - n.cellG);
      float distB = (cellB - n.cellB);
      if (distR*distR + distG*distG + distB*distB < 10) {
        sepR += distR;
        sepG += distG;
        sepB += distB;
      }
      num++;
    }
    cohR = cohR/num;
    cohG = cohG/num;
    cohB = cohB/num;
    aliR = aliR/num;
    aliG = aliG/num;
    aliB = aliB/num;

    //normalising the separation
    if ((sepR != 0) || (sepG != 0) || (sepB != 0)) {
      double norm = sepNormMag/Math.sqrt(sepR*sepR + sepG*sepG + sepB*sepB);
      sepR *= norm;
      sepG *= norm;
      sepB *= norm;
    }

    //updating the temporary velocity using the computed flocking values - using the rein to limit velocity
    tempVR += rein*(sepCo*sepR + cohR + aliCo*aliR - cellR - tempVR);
    tempVG += rein*(sepCo*sepG + cohG + aliCo*aliG - cellG - tempVG);
    tempVB += rein*(sepCo*sepB + cohB + aliCo*aliB - cellB - tempVB);

    //updating temp colour with velocity
    tempR += tempVR;
    tempG += tempVG;
    tempB += tempVB;


    //when a colour reaches an extreme value (0 or 255), these statements
    //cap the velocity and multiply it by -1 to send the colour back the other way

    if (tempR < lowLimR) {
      tempR = lowLimR;
      tempVR *= rr;
    } else if (tempR > uppLimR) {
      tempR = uppLimR;
      tempVR *= rr;
    }
    if (tempG < lowLimG) {
      tempG = lowLimG;
      tempVG *= rr;
    } else if (tempG > uppLimG) {
      tempG = uppLimG;
      tempVG *= rr;
    }
    if (tempB < lowLimB) {
      tempB = lowLimB;
      tempVB *= rr;
    } else if (tempB > uppLimB) {
      tempB = uppLimB;
      tempVB *= rr;
    }
  }

  // the function which adds the calculated colours to the colours ArrayList
  void render() {
    
    if (pastelMode==1) {
      colours.add(color(((tempR+255)/2), ((tempG+255)/2), ((tempB+255)/2)));
    } else {
      colours.add(color(tempR, tempG, tempB));
    }
    cellR = tempR;
    cellG = tempG;
    cellB = tempB;
    cellVR = tempVR/2; //divided by two to give colours a chance
    cellVG = tempVG/2;
    cellVB = tempVB/2;
  }

  void paint() {
    //defining the paintgun tool
    float clickX = 0;
    float clickY = 0;
    if (fs%2==0) {
      float w = float(width);
      float h = float(height);
      clickX = (mouseX/w)*(gridLength)+grid.gridX;
      clickY = (mouseY/h)*gridHeight+grid.gridY;
    } else if (mouseX > grid.gridX && mouseX < grid.gridX + gridLength 
      && mouseY > grid.gridY && mouseY < grid.gridY + gridHeight) {
      clickX = mouseX;
      clickY = mouseY;
    }

    if (clickY < cellY+cellH+1 && cellY-1 < clickY && clickX < cellX+1 + cellW && cellX-1 < clickX) {

      int o = grid.cells.indexOf(this); //index of clicked cell


      int oy = grid.cells.get(o).cellY; //y of clicked cell for wrapping prevention
      int maxDist = 7*cellH;
      int g = gridW;

      //defining which cells we want painted for each pellet size
      List<Integer> zone = new ArrayList<Integer>();
      switch(pelletSize) {
        //size 1
        case(1):
        zone.addAll(Arrays.asList(o, o-1, o+1, o+g, o-g));
        break;
        //size 2
        case(2):
        zone.addAll(Arrays.asList(o, o-1, o+1, o+g, o-g, o+g-1, o+2*g, o+2*g+1, o+g+1, o+g+2, o+2, o-g+1));
        break;
        //size 3
        case(3):
        zone.addAll(Arrays.asList(o, o-1, o+1, o+g, o-g, o+g-1, o+2*g, o+2*g+1, o+g+1, o+g+2, o+2, o-g+1, o-2*g-1, o-2*g, o-2*g+1, o-2*g+2, o+2*g+2, o-2*g-1+1, 
          o-g-1, o-g+1, o-g-2, o-2, o+g-2, o+2*g-2, o-g-1, o-g+1, o-g+3, o+3, o+g+3, o+2*g+3, o+3*g-1, o+3*g, o+3*g+1, o+3*g+2, o+2*g-1, o-g+2));
        break;
        //size 4
        case(4):
        zone.addAll(Arrays.asList(o, o-1, o+1, o+g, o-g, o+g-1, o+2*g, o+2*g+1, o+g+1, o+g+2, o+2, o-g+1, o-2*g-1, o-2*g, o-2*g+1, o-2*g+2, o+2*g+2, o-2*g-1+1, 
          o-g-1, o-g+1, o-g-2, o-2, o+g-2, o+2*g-2, o-g-1, o-g+1, o-g+3, o+3, o+g+3, o+2*g+3, o+3*g-1, o+3*g, o+3*g+1, o+3*g+2, o+2*g-1, o-g+2, o-3*g-1, o-3*g, o-3*g+1, o-3*g+2, 
          o+4*g-1, o+4*g, o+4*g+1, o+4*g+2, o-g-3, o-3, o+g-3, o+2*g-3, o-g+4, o+4, o+g+4, o+2*g+4, o-2*g-2, o+3*g-2, o-2*g+3, o+3*g+3, 
          o-4*g-1, o-4*g, o-4*g+1, o-4*g+2, o+5*g-1, o+5*g, o+5*g+1, o+5*g+2, o-g-4, o-4, o+g-4, o+2*g-4, o-g+5, o+5, o+g+5, o+2*g+5, o-3*g-2, o-3*g-3, o-2*g-3, o+3*g-3, o+4*g-3, 
          o+4*g-2, o+4*g+3, o+4*g+4, o+3*g+4, o-2*g+4, o-3*g+3, o-3*g+4));
        break;
        //size 5
        case(5):
        zone.addAll(Arrays.asList(o, o-1, o+1, o+g, o-g, o+g-1, o+2*g, o+2*g+1, o+g+1, o+g+2, o+2, o-g+1, o-2*g-1, o-2*g, o-2*g+1, o-2*g+2, o+2*g+2, o-2*g-1+1, 
          o-g-1, o-g+1, o-g-2, o-2, o+g-2, o+2*g-2, o-g-1, o-g+1, o-g+3, o+3, o+g+3, o+2*g+3, o+3*g-1, o+3*g, o+3*g+1, o+3*g+2, o+2*g-1, o-g+2, o-3*g-1, o-3*g, o-3*g+1, o-3*g+2, 
          o+4*g-1, o+4*g, o+4*g+1, o+4*g+2, o-g-3, o-3, o+g-3, o+2*g-3, o-g+4, o+4, o+g+4, o+2*g+4, o-2*g-2, o+3*g-2, o-2*g+3, o+3*g+3, 
          o-4*g-1, o-4*g, o-4*g+1, o-4*g+2, o+5*g-1, o+5*g, o+5*g+1, o+5*g+2, o-g-4, o-4, o+g-4, o+2*g-4, o-g+5, o+5, o+g+5, o+2*g+5, o-3*g-2, o-3*g-3, o-2*g-3, o+3*g-3, o+4*g-3, 
          o+4*g-2, o+4*g+3, o+4*g+4, o+3*g+4, o-2*g+4, o-3*g+3, o-3*g+4, o-3*g-5, o-3*g+6, o-2*g-5, o-2*g+6, o-1*g-5, o-1*g+6, o+0*g-5, o+0*g+6, o+1*g-5, o+1*g+6, 
          o+2*g-5, o+2*g+6, o+3*g-5, o+3*g+6, o+4*g-5, o+4*g+6, o-4*g-4, o+5*g-4, o-4*g-3, o+5*g-3, o-4*g-2, o+5*g-2, o-4*g+3, o+5*g+3, o-4*g+4, o+5*g+4, 
          o-4*g+5, o+5*g+5, o-5*g-3, o+6*g-3, o-5*g-2, o+6*g-2, o-5*g-1, o+6*g-1, o-5*g+0, o+6*g+0, o-5*g+1, o+6*g+1, o-5*g+2, o+6*g+2, o-5*g+3, o+6*g+3, 
          o-5*g+4, o+6*g+4, o-2*g-6, o-2*g+7, o-1*g-6, o-1*g+7, o+0*g-6, o+0*g+7, o+1*g-6, o+1*g+7, o+2*g-6, o+2*g+7, o+3*g-6, o+3*g+7, o-3*g-4, o-3*g+5, 
          o-2*g-4, o-2*g+5, o+3*g-4, o+3*g+5, o+4*g-4, o+4*g+5, o-6*g-2, o+7*g-2, o-6*g-1, o+7*g-1, o-6*g+0, o+7*g+0, o-6*g+1, o+7*g+1, o-6*g+2, o+7*g+2, o-6*g+3, o+7*g+3));
        break;
      }


      for (int z=0; z<zone.size(); z++) {
        try {
          Cell c = grid.cells.get(zone.get(z));
          if (abs(c.cellY-oy) > maxDist && !wrapping) {
            //avoids wrapping for the paintgun
          } else {
            c.cellR = c.tempR = gunR;
            c.cellG = c.tempG = gunG;
            c.cellB = c.tempB = gunB;
            c.tempVR = c.cellVR = 0;
            c.tempVG = c.cellVG = 0;
            c.tempVB = c.cellVB = 0;
            if (flick==1) {
              colours.set(zone.get(z), color(gunR, gunG, gunB));
            } //paint when paused
          }
        } 
        catch ( IndexOutOfBoundsException e ) {
        }
      }
    }
  }
}

void resetGUI() {
  limitsR.setLowValue(0).setHighValue(255);
  limitsG.setLowValue(0).setHighValue(255);
  limitsB.setLowValue(0).setHighValue(255);
  pelletSizeS.setValue(3);
  gunRS.setValue(50);
  gunGS.setValue(100);
  gunBS.setValue(220);
  res.activate(2);
  n1 = n2 = n3 = n4 = n6 = n7 = n8 = n9 = 1.0;
  f1 = f2 = f3 = f4 = 0;
  symmetry = 0;
  neighbox.activateAll();
  rrS.setValue(-1);
  aliCoS.setValue(1);
  cohCoS.setValue(1);
  sepCoS.setValue(1);
  reinS.setValue(0.1);
  grid.restart(1);
}

void fire() {
  limitsR.setLowValue(196).setHighValue(255);
  limitsG.setLowValue(106).setHighValue(191);
  limitsB.setLowValue(0).setHighValue(0);
  reinS.setValue(0.05);
  pelletSizeS.setValue(3);
  gunRS.setValue(255);
  gunGS.setValue(105);
  gunBS.setValue(0);
  res.activate("256 x 160 (Default)");
  n1 = n2 = n3 = n4 = n6 = n7 = n8 = n9 = 1.0;
  neighbox.activateAll();
  f1 = f2 = f3 = f4 = 0;
  symmetry = 0;
  rrS.setValue(0);
  aliCoS.setValue(1);
  cohCoS.setValue(1);
  sepCoS.setValue(1);
  grid.restart(1);
}

void eveningSky() {
  limitsR.setLowValue(106).setHighValue(236);
  limitsG.setLowValue(96).setHighValue(121);
  limitsB.setLowValue(131).setHighValue(211);
  reinS.setValue(0.1);
  pelletSizeS.setValue(3);
  gunRS.setValue(135);
  gunGS.setValue(100);
  gunBS.setValue(210);
  res.activate("256 x 160 (Default)");
  n1 = n2 = n3 = n4 = n6 = n7 = n8 = n9 = 1.0;
  neighbox.activateAll();
  f1 = f2 = f3 = f4 = 0;
  symmetry = 0;
  rrS.setValue(0);
  aliCoS.setValue(1);
  cohCoS.setValue(1);
  sepCoS.setValue(0.95);
  grid.restart(1);
}

void aurora() {
  limitsR.setLowValue(0).setHighValue(51);
  limitsG.setLowValue(11).setHighValue(141);
  limitsB.setLowValue(61).setHighValue(81);
  reinS.setValue(0.1);
  pelletSizeS.setValue(3);
  gunRS.setValue(0);
  gunGS.setValue(0);
  gunBS.setValue(80);
  res.activate("256 x 160 (Default)");
  n1 = n2 = n3 = n7 = n8 = n9 = 1.0;
  n4 = n6 = 0.0;
  neighbox.deactivate("n4").deactivate("n6");
  f1 = f2 = f3 = f4 = 0;
  symmetry = 0;
  rrS.setValue(-0.12);
  aliCoS.setValue(1.3);
  cohCoS.setValue(1);
  sepCoS.setValue(1);
  grid.restart(1);
}

void rorschach() {
  limitsR.setLowValue(0).setHighValue(255);
  limitsG.setLowValue(0).setHighValue(255);
  limitsB.setLowValue(0).setHighValue(255);
  pelletSizeS.setValue(3);
  gunRS.setValue(50);
  gunGS.setValue(100);
  gunBS.setValue(220);
  res.activate(2);
  n1 = n2 = n3 = n4 = n6 = n7 = n8 = n9 = 1.0;
  f1 = f3 = 0;
  f2 = f4 = 1;
  symmetry = 1;
  threshKnob.setValue(0.6);
  neighbox.activateAll();
  rrS.setValue(-1);
  aliCoS.setValue(1);
  cohCoS.setValue(1);
  sepCoS.setValue(1);
  reinS.setValue(0.1);
  grid.restart(1);
}


void stripes(int i, int w, int gap, int off, int off2) {

  int g = gridW+warp;
  int g2 = gridH+warp;
  int spacing, spacing2, anchor, anchor2;

  spacing = gap+w;
  spacing2 = gap*gridW+w*gridW;
  if (spacing==0) {
    spacing=1;
  }
  if (spacing2==0) {
    spacing2=1;
  }

  anchor = (i%g+off)%spacing;
  anchor2 = (i%(g2*g)+off2*g)%spacing2;

  if (anchor<w && ver==1 || anchor2<=(w*g)-1 && hor==1) { 
    gi.pixels[i]=color(stripeR, stripeG, stripeB);
    stripeBuffer.pixels[i]=color(stripeR, stripeG, stripeB);
    if (stripeEmbed == 1) {
      Cell c = grid.cells.get(i);
      c.cellR = c.tempR = stripeR;
      c.cellG = c.tempG = stripeG;
      c.cellB = c.tempB = stripeB;
      c.tempVR = c.cellVR = 0;
      c.tempVG = c.cellVG = 0;
      c.tempVB = c.cellVB = 0;
    }
  } else {
    stripeBuffer.pixels[i]=color(0, 0, 0, 0);
    if (layer1.pixels[i]!=color(0, 0, 0, 0) && activeLayer!=1) {   //<>//
      gi.pixels[i]=layer1.pixels[i];
      if (stripeEmbed == 1) {
      Cell c = grid.cells.get(i);
      c.cellR = c.tempR = stripeReds[0];
      c.cellG = c.tempG = stripeGreens[0];
      c.cellB = c.tempB = stripeBlues[0];
      c.tempVR = c.cellVR = 0;
      c.tempVG = c.cellVG = 0;
      c.tempVB = c.cellVB = 0;
    }
    } else if (layer2.pixels[i]!=color(0, 0, 0, 0) && activeLayer!=2) {  
      gi.pixels[i]=layer2.pixels[i];
      if (stripeEmbed == 1) {
      Cell c = grid.cells.get(i);
      c.cellR = c.tempR = stripeReds[1];
      c.cellG = c.tempG = stripeGreens[1];
      c.cellB = c.tempB = stripeBlues[1];
      c.tempVR = c.cellVR = 0;
      c.tempVG = c.cellVG = 0;
      c.tempVB = c.cellVB = 0;
    }
    } else if (layer3.pixels[i]!=color(0, 0, 0, 0) && activeLayer!=3) {  
      gi.pixels[i]=layer3.pixels[i];
      if (stripeEmbed == 1) {
      Cell c = grid.cells.get(i);
      c.cellR = c.tempR = stripeReds[2];
      c.cellG = c.tempG = stripeGreens[2];
      c.cellB = c.tempB = stripeBlues[2];
      c.tempVR = c.cellVR = 0;
      c.tempVG = c.cellVG = 0;
      c.tempVB = c.cellVB = 0;
    }
    } else if (layer4.pixels[i]!=color(0, 0, 0, 0) && activeLayer!=4) {  
      gi.pixels[i]=layer4.pixels[i];
      if (stripeEmbed == 1) {
      Cell c = grid.cells.get(i);
      c.cellR = c.tempR = stripeReds[3];
      c.cellG = c.tempG = stripeGreens[3];
      c.cellB = c.tempB = stripeBlues[3];
      c.tempVR = c.cellVR = 0;
      c.tempVG = c.cellVG = 0;
      c.tempVB = c.cellVB = 0;
    }
    }
    if (background==1) {
      gi.pixels[i]=color(backR, backG, backB);
      stripeBuffer.pixels[i]=color(backR, backG, backB);
      if (layer1.pixels[i]!=color(0, 0, 0, 0) && activeLayer!=1) {  
      gi.pixels[i]=layer1.pixels[i];
    } else if (layer2.pixels[i]!=color(0, 0, 0, 0) && activeLayer!=2) {  
      gi.pixels[i]=layer2.pixels[i];
    } else if (layer3.pixels[i]!=color(0, 0, 0, 0) && activeLayer!=3) {  
      gi.pixels[i]=layer3.pixels[i];
    } else if (layer4.pixels[i]!=color(0, 0, 0, 0) && activeLayer!=4) {  
      gi.pixels[i]=layer4.pixels[i];
    }
    }
  }
  
}