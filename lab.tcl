#Lan Simulation
set ns [new Simulator]
#define color for data flows
$ns color 1 Green
$ns color 2 Red 
$ns color 3 Blue

#Create the trace files
set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1

#Create the nam files
set namfile [open out.nam w]
$ns namtrace-all $namfile

#Defining the finish procedure
proc finish {} {
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}

#Creating 11 nodes  
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

#Red for 1 to 10 UDP : source box sink circle
$n1 color Red
$n1 shape box
$n10 color Red
#Blue for 8 to 0 UDP : source box sink circle
$n8 color Blue
$n8 shape box
$n0 color Blue
#Green for 2 to 7 FTP : source box sink circle
$n2 color Green
$n2 shape box
$n7 color Green


#Creating links between nodes
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 2Mb 10ms DropTail
$ns duplex-link $n4 $n5 2Mb 10ms DropTail
$ns duplex-link $n4 $n6 2Mb 10ms DropTail
$ns duplex-link $n5 $n6 2Mb 10ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail

#Setting the LAN connection
set lan [$ns newLan "$n2 $n4 $n9" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]


#Orientation 
$ns duplex-link-op $n0 $n1 orient left-down
$ns duplex-link-op $n0 $n3 orient right-down
$ns duplex-link-op $n1 $n2 orient right-down
$ns duplex-link-op $n2 $n3 orient right-up
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link-op $n5 $n6 orient down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n9 $n10 orient right

#TCP connection 
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 552

#Intialization of FTP over TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#Setup a UDP connection-1 
set udp1 [new Agent/UDP] 
$ns attach-agent $n1 $udp1
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp1 $null
$udp1 set fid_ 2

#Set CBR1 over UDP1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_ size_ 1000
$cbr1 set rate_ 0.01Mb
$cbr1 set random_ false

#Setup a UDP connection-2
set udp2 [new Agent/UDP]
$ns attach-agent $n8 $udp2
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp2 $null
$udp2 set fid_ 3

#Set CBR2 over UDP2
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_ size_ 1000
$cbr2 set rate_ 0.01Mb
$cbr2 set random_ false

#Scheduling the events
$ns at 1.0 "$cbr1 start"
$ns at 2.0 "$cbr1 stop"
$ns at 2.0 "$cbr2 start"
$ns at 3.0 "$cbr2 stop"
$ns at 3.0 "$ftp start"
$ns at 4.0 "$ftp stop"



proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
 $ns at [expr $now+$time] "plotWindow $tcpSource $file"
}
$ns at 0.1 "plotWindow $tcp $winfile"

#End the program
 $ns at 5.0 "finish"

#Start the simulation process
 $ns run
