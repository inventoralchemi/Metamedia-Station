// Metamedia Server
//
// this software is protected by the GNU general public license
// created by Les Hall on Monday Feb 4, 2013, 12:05 AM (midnight)
//
// file repository snd meta data storage entity
//


// global variables
7777 => int portBase;


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
        if (command == "print")
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
