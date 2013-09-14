XOBXOB_Connector_Application
============================

This is an application that runs on your laptop/desktop to allow the Arduino to connect to the Internet through the USB port

#Instructions:

1. Download and unzip the XOBXOB_Connector zip file for your operating system (Mac, Windows, Linux)
2. Run the application inside the folder

Note: if you are using a 64-bit version of Linux, you must use the Linux64 connector application.

When the application starts, you will see the application window along with a list of serial ports on your computer. Type the single digit number of the port to which you want to connect (if you have more than 9 serial ports, you may have problems).
Once connected, the application will take anything coming in the serial port and send it over the
network to www.XOBXOB.com, and anything coming from www.XOBXOB.com and send it back over the serial port to the Arduino. No shield necessary.

On the Arduino side, you can start the Arduino IDE and open the "Connector" sample sketch from the XOBXOB library.
If you try to upload the sketch to your Arduino while the Connector application is running, you will get an error (both Arduino and the application can't use the serial port at the same time). To address this problem, you can press the space bar when the application window is active, or click in the window with a mouse, to pause the Connector.

Once the Connector is paused, you can upload the sketch to the Arduino. After the Arduino sketch is uploaded, go back to the 
Connector and press any key/mouse click to resume.

#Note

1. You may delete the source folders, but other than those you must not delete any of the folders inside the application folders.
