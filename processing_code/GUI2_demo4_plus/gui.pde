//============================================================
//  Simple GUI controls
//  Controls are activated by key and mouse click
//  Contextual hels is displayed on mouse over
//  (F)DZL 2015
//============================================================

class control
{
  //Position and size
  int x=0;
  int y=0;
  int w=60;
  int h=35;
  //-Colors
  color faceColor=color(98, 206, 198);
  color textColor=color(75, 42, 0);
  //-Key to activate control
  char hotkey;
  //-Discriptive caption
  String caption;
  //-Mouse-over help 
  String help;
  //-Mouse and key state
  boolean clickState=false;
  boolean keyState=false;
  boolean mouseOver=false;
  //-Updated for redraw
  boolean change=false;
  //-Typematic control
  int timer=0;
  boolean typematic=false;
  //-Constructor
  control(int px, int py, char k, String c,String h)
  {
    x=px;
    y=py;
    hotkey=k;
    caption=c;
    help=h;
  }
  //-Draw
  void draw()
  {
    if (clickState||keyState)
      stroke(255, 0, 0);
    else
      stroke(50);
    fill(faceColor);
    rect(x, y, w, h);
    fill(textColor);
    textSize(20);
    text("-"+hotkey+"-", x+5, y+17);
    textSize(14);
    text(caption, x+8, y+33);
  }
  //-Draw help
  void drawHelp()
  {
    textSize(20);
    fill(200);
    text(help,x+w+5,y+20);
  }
  //-Update. Handles keys and mouse
  boolean update()
  {
    boolean result=false;
    mouseOver=false;
    if ((mouseX>x)&&(mouseX<(x+w)) && (mouseY>y)&&(mouseY<(y+h)))
    {
      mouseOver=true;
      if (mousePressed==true)
      {
        if (!clickState)
        {
          clickState=true;
          change=true;
        }
      } else
      {
        if (clickState==true)
        {
          result=true;
          clickState=false;
          change=true;
        }
      }
    } else
      if (mousePressed==false)
    {      
      clickState=false;
      change=true;
    }     


    if (key==hotkey)
    {
      if (keyPressed==true)
      {
              mouseOver=true;

        if (!keyState)
        {
          keyState=true;
          change=true;
          timer=millis()+500;
          result=true;
        } else
        {
          if (typematic)
          {
            if (millis()>timer)
            {
              timer+=10;
              result=true;
            }
          }
        }
      } else
      {
        if (keyState==true)
        {
          keyState=false;
          change=true;
        }
      }
    } else
      if (keyPressed==false)
    {
      keyState=false;
      change=true;
    }
    return result;
  }
};

