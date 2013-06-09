/*
BasicMata
 Date 20110521, Jochen Leinberger
 http://www.explorative-environments.net/
 
BasicMata?

BasicMata? is A very simple way to interface an arduino over serial protocol from any computer. 
It's based on the Idea of Firmata (http://firmata.org/wiki/Main_Page) but won't allow
you to change any setting. Therfore the Code is as simple as possible and should run 
on all Arduinos with similar pins (most important are the PWM outputs Pins see Pinouts)! 
It's thought for people who just want to get going as fast as possible,without 
the need and possibility to configure anything from outside the Arduino IDE.

Jochen Leinberger, http://www.explorative-environments.net/ .
 
 
 Copyright  2011 Jochen Leinberger
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */


//__________________//
// Values needed to receive serial Messages  
int inputByte = 0;	// one incoming Byte.
int receiveMessage[9]; // the message when received in void filltable()
int validNewMessage[9]; // message gets stored here if value is valid
int readState = 1; // kind of state automata needed to receive the messages.
int didReceive = 0; // indicates wether if a new message was received.

// Values needed to send serial Messages 
//String SensorValuesMessage = 'empty'; 
char SensorValuesMessage = 0;


// Values needed to write Outputs
int pwmOutPin[6] = {
  3,5,6,9,10,11};
int digitalOutPin[3] = {
  8,12,13};
boolean DigitalValue=LOW;


// Values needed to read Sensors
int analogInputPin[6] = {
  0,1,2,3,4,5};
int digitalInputPin[3] = {
  2,4,7};
int sensorValues[9] = {
  0};


// debug values


void setup() 
{ 
  // Setup serial Communication 
  Serial.begin(115200); 

  // Setup Pin modes

  // Set Outputs
  // Output Analog
  for (int i=0;i<6;i++) {
    pinMode(pwmOutPin[i], OUTPUT);
    digitalWrite(pwmOutPin[i], LOW);
  }

  // Output Digital
  for (int i=0;i<3;i++) {
    pinMode(digitalOutPin[i], OUTPUT);
    digitalWrite(digitalOutPin[i], LOW);
  }


  // Set Inputs
  // Input Analog. To use them as GPIO uncomment the area above.
  /*
  for (int i=0;i<6;i++) {
   pinMode(analogInputPin[i], OUTPUT);
   digitalWrite(analogInputPin[i], HIGH);
   }
   */

  // Input Digital, with internal Pullup enabled
  for (int i=0;i<3;i++) {
    pinMode(digitalInputPin[i], INPUT);
    digitalWrite(digitalInputPin[i], HIGH);       // turn on pullup resistors, uncomment to disable pullup
  }
} 


void loop() 
{ 
  //Receive Serial Values
  serialReceive();

  //Output received Values
  outputValues();

  //Read Sensors
  readSensors();

  //Send Sensors
  if (didReceive > 0)
    sendSensors();

} 



void serialReceive()
{

  if(Serial.available()>12) 
  {
    do
    { 
      if(Serial.available()>0)   
        inputByte = Serial.read();

      if (readState == 1 && inputByte == 13) // carriage Return
      {
        readState = 2;
      }

      else if (readState == 2 && inputByte == 10) // LineFeed
      {
        readState = 3;
      }

      else if (readState == 3 && inputByte == 64 && Serial.available()>9) // @ = 64 in ASCII + we have a full table to read now
      {
        for(int i=0; i<9; i++)
        {
          receiveMessage[i]=Serial.read();
        } 
        readState = 4;
      }

      else if (readState == 4 && inputByte == 36) // $ = 36 in ASCII
      { 
        for(int i=0; i<9; i++)
        {
          validNewMessage[i] = receiveMessage[i];
        }
        didReceive = 1;
        readState = 5;
      }

      else 
      {
        for(int i=0; i<Serial.available();)
        {
          inputByte=Serial.read();
          if(inputByte == 36)
            break;
        }
        readState=6;
      }
    }
    while(readState<5);
    readState = 1 ;
  }
}


void outputValues()
{
  for(int i = 0; i<6; i++)
    analogWrite(pwmOutPin[i], validNewMessage[i]);

  for(int i = 0; i<3; i++)
  {
    if (validNewMessage[i+6] < 120)
      digitalWrite(digitalOutPin[i], LOW);
    else
      digitalWrite(digitalOutPin[i], HIGH);
  }
}


void readSensors()
{
  for(int i = 0; i<6; i++)
    sensorValues[i] = analogRead(analogInputPin[i]);

  for(int i = 0; i<3; i++)
    sensorValues[i+6] = digitalRead(digitalInputPin[i]); 
}



void sendSensors()
{
  Serial.print('@');
  for (int i=0; i<9; i++)
  {
    SensorValuesMessage = sensorValues[i] % 255;  // the m(modulo) part
    Serial.print(SensorValuesMessage);
    SensorValuesMessage = (sensorValues[i]-(sensorValues[i] % 255)) / 255; // r(realmultiples) of 255
    Serial.print(SensorValuesMessage); 
  }
  Serial.println('$');
  //SensorValuesMessage = SensorValuesMessage + '$';
  //Serial.println(SensorValuesMessage);

  didReceive = 0; // change back did Receive
}


