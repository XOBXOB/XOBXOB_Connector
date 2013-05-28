XOBXOB_Connector
================

A Processing sketch to connect to the network through a USB port

#Instructions:

1. Download Processing 2.0 from www.processing.org
2. Download the XOBXOB_Connector zip file from this repository
3. Copy the XOBXOB_Connector folder from the zip into the Processing user sketch folder (check on Processing.org for your operating system to see where)
4. Start Processing and open the XOBXOB_Processing sketch (File > Open)
5. Run the Processing sketch

When the sketch starts, you will see the application window. It won't be connected to any serial port.
You can press 's' which will display the list of available ports, followed by the single digit number of the port
to which you want to connect (if you have more than 10 serial ports, you ay have problems).
Once connected, the Processing sketch will take anything coming in the serial port and send it over the
network to XOBXOB.com, and anything coming over the network and send it back over the serial port. Easy Peasy.

On the Arduino side, you can start the Arduino IDE and open the sample sketch from the XOBXOB library.
If you try to upload the sketch to your Arduino, you will get an error. Because both Arduino and Processing 
can't use the serial port at the same time. SO, you have to go back to the Processing and press 'd' to 
disconnect the serial port. THEN, you can upload the sketch to the Arduino. And, finally, go back to the 
Connector and press 'c' to connect to the serial port again. A little bit of juggling, but not too bad.
