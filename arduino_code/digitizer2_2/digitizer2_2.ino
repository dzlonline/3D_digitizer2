//*************************************************
//  Demo code for 3D digitizer
//  See description of project here:
//
//  (F)Dzl 2018  
//  
//*************************************************

#include "dzl_encoders.h"

IQencoder E0, E1, E2, E3;

//*************************************************
//  Mechanical set up:
//*************************************************
#define ARM1 176.38       // Arm E1-R2 length[mm.]
#define ARM2 176.38       // Arm E2-tip length[mm.]
//Offsets from mechanical set-up:
#define Z_OFFSET 80.782   // E1 axis height above table [mm.]
#define X_OFFSET -125.0   // Distance from E0 axis to preset position [mm.]
#define Y_OFFSET 125.0    // Distance from E0 axis to preset position [mm.]
//Angles from mechanical set-up:
#define E0_PRESET -45.0   
#define E1_PRESET 32.048
#define E2_PRESET -113.174
#define E3_PRESET 0.0

//*************************************************
//  Send coordinates to processing program
//*************************************************
void sendFloat(float f, unsigned t) {
  byte * b = (byte *) &f;
  Serial.write(t);
  Serial.write(b[0]);
  Serial.write(b[1]);
  Serial.write(b[2]);
  Serial.write(b[3]);
}

void setup()
{
  Serial.begin(19200);

  setEncoderRate(10000);
  
  //Attach encoders so anti-clockwise rotation is positive:
  E0.attach(9, 8);      //E0 (Q,I)  
  E1.attach(11, 10);    //E1 (I,Q)
  E2.attach(13, 12);    //E2 (I,Q)
  E3.attach(7, 6);      //tt (Q,I)

  delay(10);            //-Allow time to settle

  //Preset encoders:
  E0.setDegrees(E0_PRESET);     //Horizontal encoder (corner)
  E1.setDegrees(E1_PRESET);     //First vertical encoder
  E2.setDegrees(E2_PRESET);     //Second vertical encoder
  E3.setDegrees(E3_PRESET);     //Turntable
}

void loop()
{
  //Read encoders in radians
  double A = E1.getRadians();
  double B = E2.getRadians();
  double C = E0.getRadians();
  double D = E3.getRadians();

  //Calculate distance from E0 axis to tip 'r' and height above table 'z'
  double r = cos(A) * ARM1 + cos(A + B) * ARM2;
  double z = (sin(A) * ARM1) + (sin(A + B) * ARM2) + Z_OFFSET;

  //Calculate tip x,y
  double x = r * cos(C)+ X_OFFSET;
  double y = r * sin(C)+ Y_OFFSET;

/*
  //Print encoder angles:
  Serial.print(E0.getDegrees());
  Serial.print(",");
  Serial.print(E1.getDegrees());
  Serial.print(",");
  Serial.print(E2.getDegrees());
  Serial.print(",");
  Serial.println(E3.getDegrees());
*/

/*
  //Print coordinates:
  Serial.print(x);
  Serial.print(",");
  Serial.print(y);
  Serial.print(",");
  Serial.print(z);
  Serial.print(",");
  Serial.println(D);
*/

  //Send coordinates to Processing
  sendFloat(x, 'x');
  sendFloat(y, 'y');
  sendFloat(z, 'z');
  sendFloat(D, 'a');
  
  delay(100);

}
