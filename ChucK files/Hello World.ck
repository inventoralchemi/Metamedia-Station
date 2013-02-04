// Hello World
//
// this software is protected by the GNU general public license
// created by Les Hall on Monday Feb 4, 2013, 1:26 AM
//
// text ship for the purpose of enteringbtext and lyrics
//



// global variables
"208.52.185.228" => string hostname;
// "localhost" => hostname;
7777 => int portBase;
"127.0.0.0" => string myIP;
"unconfigured user" => string name;
"print" => string command;
"Hello World" => string msg;

// check command line
if( me.args() ) me.arg(0) => hostname;
if( me.args() > 1 ) me.arg(1) => Std.atoi => portBase;

// send object and aim transmitter
OscSend xmitMessageStart;
xmitMessageStart.setHost( hostname, portBase );
OscSend xmitMessageText;
xmitMessageText.setHost( hostname, portBase + 1 );



// infinite time loop
while( true )
{
    // send the command the message
    xmitMessageStart.startMsg( "/metastation/messages", "s s s" );
    myIP => xmitMessageStart.addString;
    name => xmitMessageStart.addString;
    command => xmitMessageStart.addString;
    1::second => now;
    
    // send the data message
    xmitMessageText.startMsg( "/metastation/messages", "s" );
    msg => xmitMessageText.addString;

    // advance time
    29::second => now;
}
