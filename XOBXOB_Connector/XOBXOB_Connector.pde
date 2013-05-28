/////////////////////////////////////////////////////////////////////////
//
//  XOBXOB Connector
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

// Serial and Network clients
Client myClient;
Serial mySerial;

// I/O buffers
String serialIn;
String webIn;

// Colors
color backgroundColor   = #FFFFFF;
color textColor         = #888888;
color highlightColor    = #A0A0A0;
color subTitleColor     = #8080FF;

// Font and logo
PFont font;
PImage logo;

// Screen parameters
int screenWidth = 350;
int screenHeight = 400;
int leftMargin = 53;
int leftMargin2 = leftMargin + 55;
int topMargin = 110;

// State variables
Boolean echo = false;
Boolean help = true;
Boolean settingSerial = false;

// Serial port parameters
String serialPortList[];
int currentPort = -1;
int baudRate = 57600;
Boolean serialConnected = false;

void setup() {
  
  // Deal with font 
  textMode(MODEL);
  font = loadFont("Helvetica-12.vlw");
  textFont(font);
  fill(textColor);
  
  // Connect to www.xobxob.com
  myClient = new Client(this, "www.xobxob.com", 80);
  delay (500);
  myClient.clear();
  
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
    if ((currentPort > 0) && serialConnected){
      
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
    
    // Logo
    float logoWidth = logo.width/2;
    float logoHeight = logo.height/2;
    image(logo, leftMargin, 10, logoWidth, logoHeight);
    fill (subTitleColor);
    textSize (13);
    text("Simple Internet for Things", leftMargin+40, 67);
    
    // Determine what to display. First try Help
    if (help) {

      fill(textColor);
      showHelp (leftMargin, topMargin);

    // Well, not in help mode. What about setting the serial port?
    } else if (settingSerial) {
      
      // Serial ports
      serialPortList = mySerial.list();
      for (int i=0; i<serialPortList.length; i++) {
        fill(highlightColor);
        text ("[" + i + "]  " + serialPortList[i], leftMargin, topMargin+(i*17));
      };
      text ("\nPress number to select port", leftMargin, topMargin+(serialPortList.length*17));
    
      
    } else {

      // Put the Echo status on the screen
      fill(textColor);
      text("ECHO:", leftMargin, topMargin);
      fill(highlightColor);
      text(((echo)?"ON":"OFF"), leftMargin2, topMargin);
    
      // Display current serial port
      fill(textColor);
      text("SERIAL:", leftMargin, topMargin+20);
      fill(highlightColor);
      if (currentPort < 0) {
        text ("Type 's' then number to select port", leftMargin2, topMargin+20);
      } else {
        if (serialConnected) {
          text ("[" + currentPort + "]  " + serialPortList[currentPort], leftMargin2, topMargin+20);
        } else {
          text ("Type 'c' to reconnect serial port", leftMargin2, topMargin+20);
        }
      }
      
      // Help prompt
      fill(textColor);
      text ("Press 'h' for help", leftMargin, height-30);

    }
    
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
  serialConnected = true;

}

//////////////////////////////////////////////////////////////////
//
//  keyReleased
//  Key handler for all key presses
//
void keyReleased () {
  
  switch (key) {
    
    case 'e':
      help = false;
      echo = !echo;
      break;
      
    case 'h':
      help = !help;
      break;
      
    case 's':
      help = false;
      settingSerial = !settingSerial;
      break;
      
    case 'd':
      if (mySerial != null) {
        mySerial.stop();
        serialConnected = false;
      }
      break;
      
    case 'c':
      setSerial (currentPort);
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
    
      // If we're not in settingSerial mode, then done
      if (!settingSerial) break;
      
      // Turn port key into 0-9 and set the serial port
      int newPort = (key - '0');
      setSerial (newPort);
      settingSerial = false;
      break;
      
    default:
      break;
  };
}

//////////////////////////////////////////////////////////////////
//
//  Help
//  Display help text in draw window
//
void showHelp (int x, int y) {
  
  String helpText[] = { 
    "Keyboard commands:",
    " ",
    "Press 's' followed by a number to set/change",
    "the current port (the one to which you have",
    "your Arduino connected.)",
    " ",
    "Press 'd/c' to disconnect/connect serial port.",
    " ",
    "Press 'e' to toggle character echo",
    "in the standard output pane.",
    " ",
    "Press 'h' to toggle this help text."
  };
  
  int linePos = y;
  for (int i=0; i<helpText.length; i++) {
    fill (textColor);
    //if (i == 0) fill(highlightColor);
    text (helpText[i], x, linePos + (i*17));
  }
}
