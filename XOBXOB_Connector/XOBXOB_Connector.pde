/////////////////////////////////////////////////////////////////////////
//
//  XOBXOB Connector (Version 1.1.0)
//
//  Application to allow connecting to the XOBXOB service through a
//  serial port
//
//  The MIT License (MIT)
//  
//  Copyright (c) 2013 Robert W. Gallup, XOBXOB
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 

import processing.net.*;
import processing.serial.*;

// For adding header to a XOBXOB request
String _LF = "\n";
String _HOST_HEADER = "Host: www.xobxob.com" + _LF;
String _REQUEST_END = _LF + _LF;

String _XOBXOB_DOMAIN = "www.xobxob.com";
int    _XOBXOB_PORT   = 80;

// Serial and Network clients
Client myClient;
Serial mySerial;

// I/O buffers
String serialIn;
String webIn;

// Colors
color backgroundColor         = #FFFFFF;
color contentBackgroundColor  = #FAFAFA;
color textColor               = #999999;
color highlightColor          = #AAAAAA;
color alertColor              = #FF3333;

// Font and logo
PFont font;
PFont alertFont;
PImage logo;

// Screen parameters
int screenWidth = 350;
int screenHeight = 350;
int leftMargin = 53;
int leftMargin2 = leftMargin + 55;
int topMargin = 110;

// State variables
Boolean echo = false;
Boolean serialInitialized = false;
Boolean paused = false;

// Serial port parameters
String serialPortList[];
int currentPort = -1;
int baudRate = 57600;

void setup() {
  
  // Deal with font 
  textMode(MODEL);
  font = loadFont("Helvetica-12.vlw");
  alertFont = loadFont("Helvetica-Bold-48.vlw");
  textFont(font);
  fill(textColor);
  
  // Connect to www.xobxob.com
  myClient = new Client(this, _XOBXOB_DOMAIN, _XOBXOB_PORT);
  //delay (500);
  //myClient.clear();
  
  // Load logo
  logo = loadImage("XOBXOB_logo.png");

  // Set up the application window
  size(screenWidth, screenHeight);
  this.frame.setTitle("XOBXOB Connector");
  
  // Text
  textSize (12);

}
 
void draw() {
  
    // If the current port is set, start communicating
    if ((currentPort > 0) && !paused){
      
      // Pass-through from web to serial
      if (myClient.available() > 0) {
        webIn = myClient.readString();
        mySerial.write(webIn);
        if (echo) print (webIn);
      };
      
      // Pass-through from serial to web
      if (mySerial.available() > 0) {
        serialIn = mySerial.readString();
        myClient.write(serialIn);
        if (echo) print (serialIn);
      };

    };
    
    // Screen drawing
    background(backgroundColor);

    // Fill in the content background
    fill(contentBackgroundColor);
    stroke(contentBackgroundColor);
    rect(0, topMargin-27, width, height);

    // Logo
    float logoWidth = logo.width/2;
    float logoHeight = logo.height/2;
    image(logo, leftMargin, 23, logoWidth, logoHeight);
    
    // Initialize serial port
    if (!serialInitialized) {
      
      // Serial ports
      fill(textColor);
      serialPortList = Serial.list();
      for (int i=0; i<serialPortList.length; i++) {
        text ("[" + i + "]  " + serialPortList[i], leftMargin, topMargin+(i*17));
      };
      text ("\nPress number to select port", leftMargin, topMargin+(serialPortList.length*17));
    
      
    } else {
      
      // Display current serial port
      fill(highlightColor);
      text("SERIAL:", leftMargin, topMargin);
      fill(textColor);
      text ("[" + currentPort + "]  " + serialPortList[currentPort], leftMargin2, topMargin);
      
      // Put the Echo status on the screen
      fill(highlightColor);
      text("ECHO:", leftMargin, topMargin+20);
      fill(textColor);
      text(((echo)?"ON":"OFF"), leftMargin2, topMargin+20);
    
      // Handle Pause
      if (paused) {
        pushStyle();
        textFont (alertFont);
        textSize(48);
        fill(alertColor);
        text ("PAUSED", leftMargin-4, height-52);
        popStyle();
      }
      
      // Prompt
      fill(textColor);
      if (paused) {
        text ("Press any key to continue", leftMargin, height-30);
      } else {
        String prompt = "Press 'space' to pause, 'e' for echo " + ((echo)?"off":"on");
        text (prompt, leftMargin, height-30);
      }
    }
    
}

//////////////////////////////////////////////////////////////////
//
//  disconnectEvent()
//  Reconnects the client if it is disconnected
//
void disconnectEvent (Client theClient) {
  if (echo) println ("\nReconnecting.");
  myClient = new Client(this, _XOBXOB_DOMAIN, _XOBXOB_PORT);
}


//////////////////////////////////////////////////////////////////
//
//  setSerial
//  Actually sets a serial port
void setSerial(int portNumber) {
  
  // Return if port out of range
  if ((portNumber < 0) || (portNumber > serialPortList.length)) return; 

  // Stop the port (if not null) and create a new one
  currentPort = portNumber;
  if (mySerial != null) mySerial.stop();
  mySerial = new Serial(this, serialPortList[currentPort], baudRate);
  delay (500);
  mySerial.clear();
  serialInitialized = true;

}

//////////////////////////////////////////////////////////////////
//
//  keyPressed, keyReleased
//  Key handler for all key presses
//
void keyPressed() {
  if (key == 27) key = 0;
}

void keyReleased () {
  
  if (paused) {
    setSerial (currentPort);
    paused = false;
    return;
  }
  
  switch (key) {
    
    case 'e':
      echo = !echo;
      break;
      
    case 'p':
    case ' ':
      if (mySerial != null) {
        mySerial.stop();
        paused = true;
      }
      break;
      
    case '0':  // This little mess is for
    case '1':  // keys 0-9
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    
      // If serial is already initialized, then we're done!
      if (serialInitialized) break;
      
      // Turn port key into 0-9 and set the serial port
      int newPort = (key - '0');
      setSerial (newPort);
      serialInitialized = true;
      break;
      
    default:
      break;
  };
}

