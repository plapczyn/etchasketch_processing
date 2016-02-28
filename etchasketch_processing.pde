/*
 littleBits Arduino Module
 Original code by David Mellis http://www.arduino.cc/en/Tutorial/Graph
 created Jan 2009 by Trevor Shannon http://www.trevorshp.com/creations/etchasketch.htm
 modified Jan 2014 for littleBits by Kristin Salomon
 modified Mar 2014 for littleBits by Matt Richard
 modified Feb 2016 by Philip Lapczynski
   Increased sample size to 512 samples
   Added support for a reset button input to clear buffer
 
 _Etch-a-Sketch_
 
 What is supposed to happen:
 * Use two dimmers to draw in a Processing Etch-a-Sketch program
 
 Important Note:
 * You will need to download Processing to run the Processing sketch.
 Processing can be downloaded here: https://processing.org/download/?processing
 
 Circuit:
 * littleBits dimmer or slide dimmer on analog pin A0
 * littleBits dimmer or slide dimmer on analog pin A1
 * littleBits push button input on digital pin D0
 * Optional:
 Use two littBits wire modules to properly orient the slide dimmers
 * Note:
 The following other input modules can be used: bend, light, pressure sensor
 However, their min and max range will need to be adjusted in Processing:
 */

import processing.serial.*;

// Serial Port variables
Serial myPort;
String buff = "";
String buff1 = "";
String buff2 = "";
int index = 0;
int NEWLINE = 10;

// Store the last 512 values from the sensors so we can draw them.
int[] valuesx = new int[512];
int[] valuesy = new int[512];

// setup() is where the Processing sketch is intitialized. This happens first thing
// sketch is run and only executes once.
void setup()
{ 
  // set size of drawing window 
  size(512, 512);
  // turn on anti-aliasing, this makes things look smoother 
  smooth();

  // initialize the Serial Port that will be recieving data from the littleBits Arduino Module
  // display all serial ports in text window
  println(Serial.list()); // use this to determine which serial port is your littleBits Arduino
  // count, starting with 0, the serial ports until you reach your littleBits Arduino
  // place that number in the command below
  // EXAMPLE: myPort = new Serial(this, Serial.list()[ your serial port number ], 9600);
  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.bufferUntil('\n');
}

// draw() happens every frame of the sketch. This is where all the calculations are made.
// When draw() is finsihed executing, it executes again, over and over.
void draw() {
  // set the background to littleBits purple
  background(87, 36, 124);
  // set stroke weight(thickness of the line) to 5 pixels
  strokeWeight(5);

  // Graph the stored values by drawing a line between each adjacent value.
  for (int i = 0; i < 511; i++) {
    // set stroke color to littleBits white (247)
    // set the alpha(transparency) of the stroke to match the position of the data point in the array
    // newer points are brighter, older points fade away
    stroke(247, i);
    // draw the line (x1, y1, x2, y2)
    line(valuesx[i], height - valuesy[i], valuesx[i + 1], height - valuesy[i + 1]);
  }
  
  // Check the Serial port for incoming data
  while (myPort.available () > 0) {
    // if there is data waiting...
    // execute serialEvent() function. Look below to see how SerialEvent works.
    serialEvent(myPort.read());
  }
}

// serialEvent controls how incoming serial data from the littleBits Arduino module is handled
void serialEvent(int serial)
{
  if (serial != NEWLINE) {
    // Store all the characters on the line.
    buff += char(serial);
  } 
  else {
    // The end of each line is marked by two characters, a carriage
    // return and a newline.  We're here because we've gotten a newline,
    // but we still need to strip off the carriage return.
    buff = buff.substring(0, buff.length()-1);
      
    /* Check for reset */
    if (buff.equals("RESET"))
    {
      // Set all of the samples to our last sample
      for (int i = 0; i < 511; i++)
      {
        valuesx[i] = valuesx[511];
        valuesy[i] = valuesy[511];
      }
      
      // Clear the value of buff
      buff = "";
    }
    else 
    {
    
      index = buff.indexOf(",");
      buff1 = buff.substring(0, index);
      buff2 = buff.substring(index+1, buff.length());
  
      // Parse the String into an integer.  We divide by 2 because
      // analog inputs go from 0 to 1023 while our window size is
      // only 512 by 512 pixels.
      int x = Integer.parseInt(buff1)/2;
      int y = Integer.parseInt(buff2)/2;
  
      // Clear the value of "buff"
      buff = "";
  
      // Shift over the existing values to make room for the new one.
      for (int i = 0; i < 511; i++)
      {
        valuesx[i] = valuesx[i + 1];
        valuesy[i] = valuesy[i + 1];
      }
  
      // Add the received value to the array.
      valuesx[511] = x;
      valuesy[511] = y;
    }
  }
}