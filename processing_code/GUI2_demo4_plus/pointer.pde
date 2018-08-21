import processing.serial.*;

Serial myPort;  // Create object from Serial class

float PX=0;
float PY=0;
float PZ=0;
float ROT=0;

float sx=0;
float sy=0;
float sz=0;
float sa=0;

char datatype;
byte [] inData = new byte[5];
int inptr=0;
int rstate=0;

float www=0;

void serialEvent(Serial myPort) 
{
  while (myPort.available ()>0)
  {
    switch(rstate)
    {
    case 0:
      datatype = myPort.readChar();
      if (datatype=='x'||datatype=='y'||datatype=='z'||datatype=='a')
      {
        rstate=1;
        inptr=0;
      }
      break;

    case 1:
      inData[inptr++]=(byte)myPort.readChar();
      if (inptr==4)
      {
        int intbit = 0;
        intbit = (inData[3] << 24) | ((inData[2] & 0xff) << 16) | ((inData[1] & 0xff) << 8) | (inData[0] & 0xff);
        float f = Float.intBitsToFloat(intbit);

        switch(datatype)
        {
        case 'x': 
          sx=f;
          break;
        case 'y': 
          sy=f;
          break;
        case 'z': 
          PX=sx;
          PY=sy;
          PZ=f;
          ROT=sa;
         
          break;
        case 'a':
          sa=f;
          break;
        }
        rstate=0;
      }        
      break;
    }
  }
}

class pointer
{
  PVector tip = new PVector(0, 0, 0);
  float rotation=0;
  boolean active=false;
  boolean demoMode=false;
  pointer(PApplet p,int index)
  {
    myPort =new Serial(p, Serial.list()[0], 19200);
    active=true;

  }

  void update()
  {
    if (demoMode)
    {
      tip.x=(mouseX-width/2)/4;
      tip.y=(mouseY-height/2)/4;
      tip.z=40+20*sin(www+=0.01);//random(20,50);//40.0;
    }
    else
    {
//      tip.set(PX,PY,PZ);
      tip.x=PX;
      tip.y=PY;
      tip.z=PZ;
      rotation=ROT;
    }
  }
};



