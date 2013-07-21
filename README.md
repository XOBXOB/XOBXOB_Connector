XOBXOB_Connector
================

Application on your laptop/desktop that allows the Arduino to connect to the Internet through the USB port

#Instructions:

1. Download and unzip the XOBXOB_Connector zip file from this repository
2. Find the connector folder for your operating system (Mac, Windows, Linux)
3. Run the application inside the folder

When the application starts, you will see the application window along with a list of serial ports on your computer. Type the single digit number of the port to which you want to connect (if you have more than 9 serial ports, you may have problems).
Once connected, the application will take anything coming in the serial port and send it over the
network to www.XOBXOB.com, and anything coming from www.XOBXOB.com and send it back over the serial port to the Arduino. No shield necessary.

On the Arduino side, you can start the Arduino IDE and open the "Connector" sample sketch from the XOBXOB library.
If you try to upload the sketch to your Arduino while the Connector application is running, you will get an error (both Arduino and the application can't use the serial port at the same time). To address this problem, you can press the space bar when the application window is active to pause the Connector.

Once the Connector is paused, you can upload the sketch to the Arduino. Once the Arduino sketch is uploaded, go back to the 
Connector and press any key to resume. This is easier than stopping/starting the Connector every time you upload a sketch.

#Notes

1. You must not delete any of the folders inside the application folder except the source folder.
2. While the Connector application runs like any other, it was written using Processing (www.processing.org). If you're interested, the source code is located inside each application folder.
