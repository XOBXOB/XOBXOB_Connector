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
import javax.swing.ImageIcon;

//String _XOBXOB_DOMAIN = "www.xobxob.com";
//int    _XOBXOB_PORT   = 80;
String _XOBXOB_DOMAIN = "localhost";
int    _XOBXOB_PORT   = 8080;

// Serial and Network clients
Client myClient;
Serial mySerial;

// I/O buffers
String serialIn;
String webIn;

// Colors
color backgroundColor         = #FFFFFF;
color contentBackgroundColor  = #F0F0F0;
color highlightBackgroundColor= #EFEF00;
color textColor               = #999999;
color highlightColor          = #AAAAAA;
color statusColor             = #F8F8F8;
color alertColor              = #FFFFFF;

// Font and logo
PFont font;
PFont alertFont;
PImage logo;

// Screen parameters
int screenWidth = 350;
int screenHeight = 350;
int leftMargin = 53;
int screenCenter = screenWidth/2 ;
int leftMargin2 = leftMargin + 55;
int topMargin = 110;

// State variables
Boolean echoEnabled = false;    // Turns echo feature on/off
Boolean echo = false;
Boolean serialInitialized = false;
Boolean paused = false;

// Serial port parameters
String serialPortList[];
int currentPort = -1;
int baudRate = 57600;

// Valid response characters
String validChars = "abcdefghijklmnopqrstuvwxyz";

void setup() {
  
  // Deal with font 
  textMode(MODEL);
  font = loadFont("Helvetica-12.vlw");
  alertFont = loadFont("Helvetica-Bold-48.vlw");
  textFont(font);
  fill(textColor);
  
  // Connect to www.xobxob.com
  myClient = null;
  while (myClient == null) {
    myClient = new Client(this, _XOBXOB_DOMAIN, _XOBXOB_PORT);
  }
  
  // Load logo
  logo = loadImage("XOBXOB_logo.png");

  // Set up the application window
  size(screenWidth, screenHeight);
  this.frame.setTitle("XOBXOB Connector");
  
  // Finally the title bar icon for Windows
  ImageIcon titlebaricon = new ImageIcon(loadBytes("XOBXOB_icon.gif"));
  frame.setIconImage(titlebaricon.getImage());
  
  // Text
  textSize (12);

}
 
void draw() {
  
    // If the current port is set, start communicating
    if ((currentPort >= 0) && !paused){
      
      // Pass-through from web to serial
      if (myClient.available() > 0) {
        webIn = myClient.readString();
        mySerial.write(webIn);
        if (echo && echoEnabled) print (webIn);
      };
      
      // Pass-through from serial to web
      if (mySerial.available() > 0) {
        serialIn = mySerial.readString();
        myClient.write(serialIn);
        if (echo && echoEnabled) print (serialIn);
      };

    };
    
    // Screen drawing
    background(backgroundColor);

    // Fill in the content background
    if (paused) {
      fill(highlightBackgroundColor);
      stroke(highlightBackgroundColor);
    } else {
      fill(contentBackgroundColor);
      stroke(contentBackgroundColor);
    }
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
        text ("[" + validChars.charAt(i) + "]  " + serialPortList[i], leftMargin, topMargin+(i*17));
      };
      text ("\nPress letter to select port", leftMargin, topMargin+(serialPortList.length*17));
    
      
    } else {
      
    
      // Paused
      if (paused) {
        pushStyle();
        textFont (alertFont);
        textSize(48);
        fill(alertColor);
        text ("PAUSED", screenCenter, topMargin+90);
        popStyle();
        
      // NOT Paused  
      } else {
        pushStyle();
        textFont (alertFont);
        textSize(48);
        fill(statusColor);
        text ("CONNECTED", screenCenter, topMargin+90);
        popStyle();
      
        // Put the Echo status on the screen
        if (echo && echoEnabled) {
          fill(highlightColor);
          text("ECHO:  " + ((echo)?"ON":"OFF"), screenCenter, topMargin+20);
        }
      }

      // Prompt
      fill(textColor);
      if (paused) {
        text ("Mouse click or keypress to continue", screenCenter, height-30);
      } else {
        String prompt = "Mouse click or 'space' to pause" + ((echoEnabled)?", '.' for echo " + ((echo)?"off":"on"):"");
        text (prompt, screenCenter, height-30);
      }
    }
    
}

//////////////////////////////////////////////////////////////////
//
//  disconnectEvent()
//  Reconnects the client if it is disconnected
//
void disconnectEvent (Client theClient) {
  if (echo && echoEnabled) println ("\nReconnecting.");
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
  serialInitialized = true;

}

//////////////////////////////////////////////////////////////////
//
//  Handle mouse click
//
void mouseClicked() {
  
  // Ignore mouse click if serial port hasn't been initialized
  if (!serialInitialized) return;

  // Toggle paused status
  if (paused) {
    setSerial (currentPort);
    paused = false;
  } else {
    if (mySerial != null) {
      mySerial.stop();
      paused = true;
    }
  }
  
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
  
  // On Mac, don't process the command key
  if (157 == keyCode) return;
  
  // If paused, any key restarts
  if (paused) {
    setSerial (currentPort);
    paused = false;
    return;
  }
  
  // if the echo feature is enabled, check for toggle
  if (key == '.') {
    if (echoEnabled) echo = !echo;
    return;
  }
  
  // Space pauses
  if (key == ' ') {
    if (mySerial != null) {
      mySerial.stop();
      paused = true;
      return;
    }
  }
  
  // If serial is already initialized, then we're done!
  if (serialInitialized) return;
    
  // Check to see if char is a valid port selector
  int newPort = validChars.indexOf(key);
  if ((newPort >= 0) && (newPort < serialPortList.length)) {    
    setSerial (newPort);
    serialInitialized = true;
    textAlign(CENTER);
  }

}

