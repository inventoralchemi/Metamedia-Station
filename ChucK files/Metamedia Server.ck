// Metamedia Server
//
// this software is protected by the GNU general public license
// created by Les Hall on Monday Feb 4, 2013, 12:05 AM (midnight)
//
// file repository snd meta data storage server entity
//


// global variables
5000 => int xmitPortBase;
xmitPortBase + 1000 => int recvPortBase;
"208.52.185.228" => string hostname;
"127.0.0.0" => string myIP;
"unconfigured user" => string name;
"print" => string command;
"Hello World" => string msg;


// class instantiations
RECV recv;
XMIT xmit;
SYNTH synth;


// receive class
class RECV
{
    // define global variables
    "/metastation/messages" => string metastationOSCpath;
    0.0 => float amplitude;
    220.0 => float frequency;
    0.0 => float phase;
    
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
    
    // define message events
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
            // <<<"server oe event occurred", "">>>;
            
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
                if (command == "print")
                {
                    // <<<"print command recognized", "">>>;
                    se => now;
                    se.nextMsg();
                    se.getString() => string msg;
                    <<<ip, name, command, msg>>>;
                    xmit.xmitText(ip, name, "verify " + command, msg);
                    <<<"print response sent", "">>>;
                }
                else if (command == "vco")
                {
                    // <<<"vco command recognized", "">>>;
                    fe => now;
                    fe.nextMsg();
                    fe.getFloat() => amplitude;
                    fe => now;
                    fe.nextMsg();
                    fe.getFloat() => frequency;
                    fe => now;
                    fe.nextMsg();
                    fe.getFloat() => phase;
                    synth.setVCO( amplitude, frequency, phase );
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
    
    // send object and aim transmitter
    OscSend xmitMessageStart;
    xmitMessageStart.setHost( hostname, xmitPortBase );
    OscSend xmitMessageInt;
    xmitMessageInt.setHost( hostname, xmitPortBase + 1 );
    OscSend xmitMessageFloat;
    xmitMessageFloat.setHost( hostname, xmitPortBase + 2 );
    OscSend xmitMessageString;
    xmitMessageString.setHost( hostname, xmitPortBase + 3 );
    
    // transmit text verification response
    fun void xmitText(string ip, string name, string command, string msg)
    {
        // send the command the message
        xmitMessage(myIP, name, command);
        
        // send the data message
        xmitString(msg);
    }
    
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



// Synthesizer class
class SYNTH
{
    // define  the patch
    SinOsc vco => ADSR adsr => Gain volume => dac;
    
    // initialize the patch
    10::ms => dur A;
    10::ms => dur D;
    0.8 => float S;
    40::ms => dur R;
    adsr.set(A, D, S, R);
    setVCO(0.0, 220.0, 0.0);
    
    // set the vco controls
    fun void setVCO( float amplitude, float frequency, float phase )
    {
        adsr.keyOff(1);
        R => now;
        amplitude => vco.gain;
        frequency => vco.freq;
        phase => vco.phase;
        adsr.keyOn(1);
    }
}




// main time loop
while( true )
{
    second => now;
}

