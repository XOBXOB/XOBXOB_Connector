XOBXOB_Connector
================

A Processing sketch to connect to the network through a USB port

#Instructions:

1. Download Processing 2.0 from www.processing.org
2. Download the XOBXOB_Connector zip file from this repository
3. Copy the XOBXOB_Connector folder from the zip into the Processing user sketch folder (check on Processing.org for your operating system to see where)
4. Start Processing and open the XOBXOB_Processing sketch (File > Open)
5. Run the Processing sketch

When the sketch starts, you will see the application window. Type the single digit number of the port
to which you want to connect (if you have more than 9 serial ports, you may have problems).
Once connected, the Processing sketch will take anything coming in the serial port and send it over the
network to www.XOBXOB.com, and anything coming over the network and send it back over the serial port to the Arduino. Easy Peasy.

On the Arduino side, you can start the Arduino IDE and open the sample sketch from the XOBXOB library.
If you try to upload the sketch to your Arduino, you will get an error. Because both Arduino and Processing 
can't use the serial port at the same time. SO, you have to go back to the Processing and press the space bar to 
pause the Connector. THEN, you can upload the sketch to the Arduino. And, finally, go back to the 
Connector and press to resume. A little bit of juggling, but not too bad.
