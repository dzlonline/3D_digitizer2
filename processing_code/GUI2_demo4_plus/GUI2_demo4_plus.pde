//============================================================
//  3D Digitizer GUI V2 Prototype
//  Used with 3D digitizer:
//  http://fablab.ruc.dk/diy-digitizer/
//  (F)DZL 2015
//============================================================

import processing.serial.*;
import peasy.*;
import processing.pdf.*;

//============================================================
//-3D navigation
//============================================================
PeasyCam cam;

//============================================================
//-Digitizer
//============================================================
pointer digitizer = new pointer(this, 0);

//============================================================
//  GUI controls
//============================================================
ArrayList<control> controls = new ArrayList<control>();

control ctl_clear = new control(10, 10, 'q', "Clear", "Clear all");
control ctl_point = new control(10, 10+1*40, 'p', "Point", "Mark a point");
control ctl_circle = new control(10, 10+2*40, 'c', "Circle", "Mark a hole");
control ctl_feature = new control(10, 10+3*40, 'f', "Feature", "Start a feature. Use \"Modify\" to add points");
control ctl_modify = new control(10, 10+4*40, 'm', "Modify", "Modify last figure");
control ctl_pdf = new control(10, 10+5*40, 'z', ".pdf", "Export as flat PDF file");

//============================================================
//  Objects
//============================================================
ArrayList<object> objects = new ArrayList<object>();

//============================================================
//  Setup
//============================================================
void setup()
{
  size(1024, 768, P3D);

  //Set up visualizer
  cam = new PeasyCam(this, 250);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(1000);
  //Add GUI controls to display list
  controls.add(ctl_clear);
  controls.add(ctl_point); 
  ctl_point.typematic=true;
  controls.add(ctl_circle); 
  ctl_circle.typematic=true;
  controls.add(ctl_feature);
  controls.add(ctl_modify);
  ctl_modify.typematic=true;
  controls.add(ctl_pdf);

  background(0);
}

//============================================================
//  Handy globals
//============================================================
float penX=0;
float penY=0;
float penZ=0;
float penA=0;
//PVector pen;

object currentObject=null; //-Last created object

//============================================================
//  Draw
//======================================================proce======

void draw()
{
  //-Get coordinated from digitizer
  digitizer.update();    
  //-Update globals

  PVector pd=new PVector(digitizer.tip.x, digitizer.tip.y);
  penA=digitizer.rotation;

  pd.rotate(-penA);

  penX=pd.x;   
  penY=pd.y;
  penZ=digitizer.tip.z;
  //  pen=digitizer.tip;






  background(0);
  //-Draw pad
  stroke(255);
//  fill(10,10,10,128);
  noFill();
  rect(-125, -125, 125*2, 125*2);

  rotateZ(penA);

  //-Draw zero cross
  stroke(100, 100, 0);
  line(-20, 0, 20, 0);
  line(0, -20, 0, 20);
  //-Draw all objects flat projection
  for (object obj : objects)
  {
    obj.project();
  }
  //-Draw all objects
  for (object obj : objects)
  {
    obj.draw();
  }
  //-Draw cursor
  pushMatrix();
  rotateZ(-penA);
  translate(digitizer.tip.x, digitizer.tip.y, digitizer.tip.z);
  stroke(0, 255, 0);
  noFill();
  box(10);
  popMatrix();
  
  
  //-Draw Heads Up Display
  cam.beginHUD();  
  color faceColor=color(98, 206, 198);
  color textColor=color(75, 42, 0);
  stroke(50);
  fill(98, 206, 198);
  rect(width-115, 10, 105, 90);
  fill(75, 42, 0);
  textSize(15);
  //-Coordinates
  text("X: "+penX, width-110, 30);
  text("Y: "+penY, width-110, 50);
  text("Z: "+penZ, width-110, 70);
  text("R: "+penA, width-110, 90);
  pushStyle();
  //-Update GUI controls 
  if (ctl_clear.update())
  {
    objects.clear();
  }
  if (ctl_point.update())
  {
    currentObject=new gpoint(penX, penY, penZ);
    objects.add(currentObject);
  }
  if (ctl_circle.update())
  {
    currentObject=new gcircle(penX, penY, penZ);
    objects.add(currentObject);
  }
  if (ctl_feature.update())
  {
    currentObject=new gfeature(penX, penY, penZ);
    objects.add(currentObject);
  }
  if (ctl_modify.update())
  {
    if (currentObject!=null)
    {
      currentObject.modify(new PVector(penX, penY, penZ));
    }
  }
  if (ctl_pdf.update())
  {
    String s="3D_"+Integer.toString(year())+"_"+Integer.toString(day())+"_"+Integer.toString(hour())+"_"+Integer.toString(minute())+"_"+Integer.toString(second())+".pdf";
    beginRecord(PDF, s); 
    background(255);
    translate(width/2, height/2);
    scale(2.84832);
    for (object obj : objects)
    {
      obj.export();
    }
    endRecord();
  }
  //-Draw GUI controls
  for (control ctl : controls)
  {
    if (ctl.change)
      ctl.draw();
    if (ctl.mouseOver)
      ctl.drawHelp();
  }
  popStyle();
  cam.endHUD();
}

