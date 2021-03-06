basicmata
=========

= Introduction =

BasicMata

BasicMata is A very simple way to interface an arduino over serial protocol from any computer. It's based on the Idea of Firmata (http://firmata.org/wiki/Main_Page) but won't allow you to change any setting. Therfore the Code is as simple as possible and should run on all Arduinos with similar pins (most important are the PWM outputs Pins see Pinouts)! It's thought for people who just want to get going as fast as possible,without the need and possibility to configure anything from outside the Arduino IDE.

Jochen Leinberger, http://www.explorative-environments.net/ 

== Concept ==

The BasicMata Communication protocol is based on the concep of Ping Pong. Which means whenever the comuter send a new valid set with data to the Arduino, the arduino replies with a record of all actual read values.
This allows to controll the polling rate from the media software and prevent it from getting blocked by to much data packes sent from the Aruino.

== Protocoll - Its as simple as PING and PONG ! ==

Serial speed is set to 115200baud
{{{
Serial.begin(115200);
}}}

Do forever:

*1. PING: Send Outputs to Arduino:*

{{{
@ 0xpwm00 0xpwm01 0xpwm02 0xpwm03 0xpwm04 0xpwm05 0xdo0 0xdo1 0xdo2 $ 0x13 0x10 
}}}

  * All Values ascii coded.
  * No seperation strings.
  * pwm: 0-255
  * do: LOW=0, HIGH=255

*2. PONG Reveice the latest Readings from the Arduino:*

All values are split in modulo 255 and hole multiples of 255 with these lines of code:
{{{
   SensorValuesMessage = sensorValues[i] % 255;  // the m(modulo) part
   Serial.print(SensorValuesMessage);
   SensorValuesMessage = (sensorValues[i]-(sensorValues[i] % 255)) / 255; // r(realmultiples) of 255
   Serial.print(SensorValuesMessage); 
}}}

{{{
@ 0xa01m 0xa01r 0xa02m 0xa02r 0xa03m 0xa03r 0xa04m 0xa04r 0xa05m 0xa05r 0xa06m 0xa06r 
0xd01m 0xd01r 0xd01m 0xd01r 0xd02m 0xd02r 0xd03m 0xd03r $ 0x13 0x10 
}}}

 * All Values as Bytes.
 * No seperation string. 
 * Fixed length: 23 Bytes
 * an: 0-1024
 * di: LOW=0, HIGH=1


![imagename](https://github.com/JOxBERGER/basicmata/raw/master/info/basic-mata-yED-Graph.jpg)

== Pinouts - Where to connect what! ==

Digital Input Pins have their pullup resistors switched on.

![imagename](https://github.com/JOxBERGER/basicmata/raw/master/info/basicmata-pinmapping.jpg)
