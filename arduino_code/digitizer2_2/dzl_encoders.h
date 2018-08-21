//*****************************************************
//  Quadrature encoder library V1.0
//  (F) Dzl 2018
//  Drives encoders on ATMEGA328 based and compatible
//*****************************************************

#ifndef __ENCODERS
#define __ENCODERS

//*****************************************************
//  Settings
//*****************************************************
#define MAX_ENCODERS 8             //Restrict number of encoders
#define STATES_PER_REV 2400        //Lines per rev * 2
#define DEFAULT_RATE 10000         //[Hz]

volatile unsigned int timerIncrement = (16000000L / DEFAULT_RATE);

//*****************************************************
//  Some macros
//*****************************************************
#define SET(x,y) (x |=(1<<y))          //-Bit set/clear macros
#define CLR(x,y) (x &= (~(1<<y)))      // |
#define CHK(x,y) (x & (1<<y))          // |
#define TOG(x,y) (x^=(1<<y))           //-+

//*****************************************************
// Encoder state machine:
// encoder offset = encref [old state][encoder input]
// 128 -> state machine error (impossible state change)
//*****************************************************
volatile int encref[4][4] =
{
  //  0  1  2  3
  {
    0, 1, -1, 128
  }
  ,//0
  {
    -1, 0, 128, 1
  }
  ,//1
  {
    1, 128, 0, -1
  }
  ,//2
  {
    128, -1, 1, 0
  }// 3
};

int setEncoderRate(unsigned int rate)
{
  if ((rate <= 20000) && (rate >= 250))
  {
    timerIncrement = 16000000L / rate;
    return rate;
  }
  return -1;
}



volatile unsigned char attachedEncoders = 0;
class IQencoder* encoders[MAX_ENCODERS];

class IQencoder
{
  public:
    volatile int encoderCounter;
    unsigned char I_pin;
    unsigned char Q_pin;
    unsigned char state;

    void attach(unsigned char I, unsigned char Q)
    {
      I_pin = I;
      Q_pin = Q;
      state = 0;
      pinMode(I_pin, INPUT_PULLUP);
      pinMode(Q_pin, INPUT_PULLUP);
      encoderCounter = 0;
      if (attachedEncoders < MAX_ENCODERS)
        encoders[attachedEncoders++] = this;  //-Add encoder to sampling system

      if (attachedEncoders == 1)              //-First encoder starts sampling system
      {
        TCCR1A = 0x00;                        //-Timer 1 inerrupt
        TCCR1B = 0x01;                        // |
        TCCR1C = 0x00;                        // |
        SET(TIMSK1, OCIE1A);                  // |
        sei();                                //-+
      }
    }

    void setDegrees(float deg)
    {
      encoderCounter = (deg / 360.0) * (float)STATES_PER_REV;
    }
    void setRadians(float rad)
    {
      encoderCounter = (rad / M_PI * 2) * (float)STATES_PER_REV;
    }

    float getRadians()
    {
      return (double)encoderCounter * M_PI * 2 / (double)STATES_PER_REV;
    }
    float getDegrees()
    {
      return (double)encoderCounter * 360.0 / (double)STATES_PER_REV;
    }
};

//*****************************************************
//  Global encoder sampler timer interrupt
//*****************************************************
SIGNAL(TIMER1_COMPA_vect)
{
  OCR1A += timerIncrement;
  volatile unsigned char input;
  for (unsigned char i = 0; i < attachedEncoders; i++)
  {
    input = 0;
    if (digitalRead(encoders[i]->I_pin) == HIGH)
      input |= 0x02;
    if (digitalRead(encoders[i]->Q_pin) == HIGH)
      input |= 0x01;
    encoders[i]->encoderCounter += encref[encoders[i]->state][input];
    encoders[i]->state = input;
  }
}

#endif
