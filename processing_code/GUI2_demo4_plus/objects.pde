//============================================================
//  Measuring objects for 3D digitizer
//  Objects implements function for 3D and 2D screen drawing and
//  2D export.
//  (F)DZL 2015   
//============================================================
//============================================================
// Base class for all objects
//============================================================
public abstract class object
{
  abstract void draw();  //-Draw to screen (3D)
  abstract void modify(PVector p); //-Modify object
  abstract void project(); //-Draw to 2D
  abstract void export(); //-Export (draw .PDF compatible)

};
//============================================================
// Single 3D point (1mmm box)
//============================================================
class gpoint extends object
{
  PVector pos;
  color lineColor=color(255);
  color projectColor=color(100);
  color exportColor=color(0);
  gpoint(PVector p)
  {
    pos.x=p.x;
    pos.y=p.y;
    pos.z=p.z;
  }
  gpoint(float x, float y, float z)
  {
    pos=new PVector(x, y, z);
  }
  void draw()
  {
    stroke(lineColor);
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    box(1);
    popMatrix();
  }

  void project()
  {
    stroke(projectColor);
    line(pos.x-5, pos.y, pos.x+5, pos.y);
    line(pos.x, pos.y-5, pos.x, pos.y+5);
  }

  void export()
  {
    stroke(exportColor);
    line(pos.x-5, pos.y, pos.x+5, pos.y);
    line(pos.x, pos.y-5, pos.x, pos.y+5);
  }

  void modify(PVector p)
  {
    pos.x=p.x;
    pos.y=p.y;
    pos.z=p.z;
  }
}

//============================================================
// Single 10mm circle 
//============================================================
class gcircle extends object
{
  PVector pos;
  color projectColor=color(100);
  color exportColor=color(0);
  color lineColor=color(255);
  boolean filled=true;
  gcircle(PVector p)
  {
    pos.x=p.x;
    pos.y=p.y;
    pos.z=p.z;
  }
  gcircle(float x, float y, float z)
  {
    pos=new PVector(x, y, z);
  }
  void draw()
  {
    stroke(lineColor);
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    ellipse(0, 0, 10, 10);
    popMatrix();
  }
  void project()
  {
    stroke(projectColor);
    ellipse(pos.x, pos.y, 10, 10);
  }

  void export()
  {
    if (filled)
    {
      noStroke();
      fill(exportColor);
    } else
    {
      noFill();
      stroke(exportColor);
    }
    ellipse(pos.x, pos.y, 10, 10);
  }

  void modify(PVector p)
  {
    pos.x=p.x;
    pos.y=p.y;
    pos.z=p.z;
  }
}

//============================================================
//  Open loop feature
//============================================================
class gfeature extends object
{
  boolean filled=true;
  PVector pos=new PVector(0, 0, 0);
  color projectColor=color(100);
  color exportColor=color(100, 100, 0);
  color lineColor=color(255, 255, 0);
  color anchorColor=color(0, 255, 0);
  ArrayList<PVector> figure = new ArrayList<PVector>();
  gfeature(PVector p)
  {
    pos.x=p.x;
    pos.y=p.y;
    pos.z=p.z;
    figure.add(new PVector(pos.x, pos.y, pos.z));
  }
  gfeature(float x, float y, float z)
  {
    pos=new PVector(x, y, z);
    figure.add(new PVector(pos.x, pos.y, pos.z));
  }

  void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    stroke(anchorColor);
    ellipse(0, 0, 5, 5);
    popMatrix();
    float x0=pos.x;
    float y0=pos.y;
    float z0=pos.z;

    stroke(lineColor);

    for (PVector p : figure)
    {
      line(x0, y0, z0, p.x, p.y, p.z);
      x0=p.x;
      y0=p.y;
      z0=p.z;
    }
    line(x0, y0, z0, pos.x, pos.y, pos.z);
  }

  void project()
  {
    stroke(projectColor);
    float x0=pos.x;
    float y0=pos.y;
    float z0=pos.z;
    for (PVector p : figure)
    {
      line(x0, y0, p.x, p.y);
      x0=p.x;
      y0=p.y;
      z0=p.z;
    }
    line(x0, y0, pos.x, pos.y);
  }

  void export()
  {
    if (filled)
    {
      noStroke();
      fill(exportColor);
    } else
    {
      noFill();
      stroke(exportColor);
    }

    PShape loop=createShape();
    loop.beginShape();

    for (PVector p : figure)
    {
      loop.vertex(p.x, p.y);
    }
    loop.vertex(pos.x, pos.y);
    loop.endShape();
    shape(loop);
  }

  void modify(PVector p)
  {
    figure.add(new PVector(p.x, p.y, p.z));
  }
}

