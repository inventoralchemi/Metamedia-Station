// Hello World
//
// this software is protected by the GNU general public license
// created by Les Hall on Monday Feb 4, 2013, 1:26 AM
//
// testing client entity
//



// global variables
7777 => int portBase;
"208.52.185.228" => string hostname;
"127.0.0.0" => string myIP;
"unconfigured user" => string name;
"print" => string command;
"Hello World" => string msg;


// class instantiations
RECV recv;
XMIT xmit;


// receive class
class RECV
{
    // create our OSC receivers and start listening
    OscRecv recvMessageStart;
    portBase => recvMessageStart.port;
    recvMessageStart.listen();
    OscRecv recvMessageText;
    portBase + 1 => recvMessageText.port;
    recvMessageText.listen();
    
    // define messages8
    recvMessageStart.event( "/metastation/messages, s s s" ) @=> OscEvent @ oe;
    recvMessageText.event( "/metastation/messages, s" ) @=> OscEvent @ text;
    
    
    // infinite event loop
    fun void loop()
    {
        while( true )
        {
            // wait for event to arrive
            oe => now;
            
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
                    text => now;
                    while( text.nextMsg() )
                    {
                        text.getString() => string msg;
                        <<<ip, name, command, msg>>>;
                    }
                }
            }
        }
    }
    spork ~ loop();
}


// transmit class
class XMIT
{
    // send object and aim transmitter
    OscSend xmitMessageStart;
    xmitMessageStart.setHost( hostname, portBase );
    OscSend xmitMessageText;
    xmitMessageText.setHost( hostname, portBase + 1 );
    
    // infinite time loop
    fun void loop()
    {
        while( true )
        {
            // send the command the message
            xmitMessageStart.startMsg( "/metastation/messages", "s s s" );
            myIP => xmitMessageStart.addString;
            name => xmitMessageStart.addString;
            command => xmitMessageStart.addString;
            
            // send the data message
            xmitMessageText.startMsg( "/metastation/messages", "s" );
            msg => xmitMessageText.addString;
            
            // advance time
            29::second => now;
        }
    }
    spork ~ loop();
}




// main time loop
while( true )
{
    second => now;
}





