// Hello World
//
// this software is protected by the GNU general public license
// created by Les Hall on Monday Feb 4, 2013, 1:26 AM
//
// testing client entity
//



// global variables
5000 => int recvPortBase;
recvPortBase + 1000 => int xmitPortBase;
"208.52.185.228" => string hostname;
"127.0.0.0" => string myIP;
"unconfigured user" => string name;
"print" => string command;
"Hello World" => string msg;


// class instantiations
RECV recv;
XMIT xmit;
BLASTER blaster;

// receive class
class RECV
{
    // define global variables
    "/metastation/messages" => string metastationOSCpath;
    
    // create our OSC receivers and start listening
    OscRecv recvMessageStart;
    recvPortBase => recvMessageStart.port;
    recvMessageStart.listen();
    OscRecv recvMessageInt;
    recvPortBase + 1 => recvMessageInt.port;
    recvMessageInt.listen();
    OscRecv recvMessageFloat;
    recvPortBase + 2 => recvMessageFloat.port;
    recvMessageFloat.listen();
    OscRecv recvMessageString;
    recvPortBase + 3 => recvMessageString.port;
    recvMessageString.listen();
    
    // define messages8
    recvMessageStart.event( metastationOSCpath + ", s s s" ) @=> OscEvent @ oe;
    recvMessageInt.event( metastationOSCpath + ", i" ) @=> OscEvent @ ie;
    recvMessageFloat.event( metastationOSCpath + ", f" ) @=> OscEvent @ fe;
    recvMessageString.event( metastationOSCpath + ", s" ) @=> OscEvent @ se;
    
    
    
    // infinite event loop
    fun void loop()
    {
        while( true )
        {
            // wait for event to arrive
            oe => now;
            // <<<"client oe event occurred", "">>>;

            // grab the next message from the queue. 
            while( oe.nextMsg() )
            { 
                string ip; // ip address of sender
                string name; // name of client (nickname)
                string command; // the command being sent
                
                oe.getString() => ip;
                oe.getString() => name;
                oe.getString() => command;
                
                // do different things depending on the message
                if (command == "verify print")
                {
                    // <<<"print verification received", "">>>;
                    se => now;
                    se.nextMsg();
                    se.getString() => string msg;
                    <<<ip, name, command, msg>>>;
                }
            }
        }
    }
    spork ~ loop();
}


// transmit class
class XMIT
{
    // define global variables
    "/metastation/messages" => string metastationOSCpath;
    
    // declare send objects and aim transmitters
    OscSend xmitMessageStart;
    xmitMessageStart.setHost( hostname, xmitPortBase );
    OscSend xmitMessageInt;
    xmitMessageInt.setHost( hostname, xmitPortBase + 1 );
    OscSend xmitMessageFloat;
    xmitMessageFloat.setHost( hostname, xmitPortBase + 2 );
    OscSend xmitMessageString;
    xmitMessageString.setHost( hostname, xmitPortBase + 3 );
    
    // infinite time loop
    fun void loop()
    {
        while( true )
        {
            // send the command message
            xmitMessage(myIP, name, "print");
            
            // send the data message
            xmitString(msg);
            1::second => now;
            
            // make a blaster sound
            spork ~ blaster.beeooo();
            
            // advance time
            29::second => now;
        }
    }
    spork ~ loop();
    
    // send a command message
    fun void xmitMessage(string myIP, string name, string command)
    {
        xmitMessageStart.startMsg( metastationOSCpath, "s s s" );
        myIP => xmitMessageStart.addString;
        name => xmitMessageStart.addString;
        command => xmitMessageStart.addString;
    }
    
    
    // send an integer data message
    fun void xmitInt(int num)
    {          
        xmitMessageInt.startMsg( metastationOSCpath, "i" );
        num => xmitMessageInt.addInt;
    }
    
    
    // send a floating point data message
    fun void xmitFloat(float num)
    {          
        xmitMessageFloat.startMsg( metastationOSCpath, "f" );
        num => xmitMessageFloat.addFloat;
    }
    
    
    // send a text data message
    fun void xmitString(string msg)
    {          
        xmitMessageString.startMsg( metastationOSCpath, "s" );
        msg => xmitMessageString.addString;
    }
}




// Blaster class, makes weapon sounds
class BLASTER
{
    // makes a computery beeooo sound
    fun void beeooo()
    {
        // define variables
        1.0 / 12.0 => float tStep;
        1.0 => float tau;
        3.0 * tau => float tMax;
        0.2 => float r;
        0.333 => float amplitude;
        220.0 => float frequency;
        0.0 => float phase;
        
        // loop thru time calculate beeooo frequencies, and xmit to vco
        for ( 0.0 => float t; t <= tMax; tStep +=> t )
        {
            // do frequency calculations
            0.25 + 0.25 * riseAndFall(t, tau) => amplitude;
            1.25 + riseAndFall(t, tau) * Math.random2f(-r, r) => float freqFrac;
            Math.round(50.0 * freqFrac) => float midiNumber;
            if (midiNumber < 0)
                0.0 => midiNumber;
            else if (midiNumber > 127)
                127.0 => midiNumber;
            Std.mtof(midiNumber) => frequency;
            // <<<"client vco data: ", midiNumber, frequency>>>;
            
            // send vco control message
            xmit.xmitMessage(myIP, name, "vco");
            xmit.xmitFloat(amplitude);
            xmit.xmitFloat(frequency);
            xmit.xmitFloat(phase);
            
            //advance time
            tStep::second => now;
        }
        
        // send final vco control message to silence vco
        xmit.xmitMessage(myIP, name, "vco");
        xmit.xmitFloat(0.0);
        xmit.xmitFloat(220.0);
        xmit.xmitFloat(0.0);
    }
    
    
    // beeooo math function
    fun float riseAndFall(float t, float tau)
    {
        if (t == 0.0)
            return 0.0;  // prevent divide by zero error
        else
            return Math.exp(-t / tau);  // send e^-x/x value
    }
}



// main time loop
while( true )
{
    second => now;
}









