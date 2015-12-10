#!/usr/bin/perl

BEGIN {push @INC, '/usr/share/perl/'}
BEGIN {push @INC, '/usr/lib/perl/'}

use Device::Modem;
use Data::Dumper;

print "Searching for modems...\n";

my $modemA = new Device::Modem( port => '/dev/ttyUSB3' );
my $modemB = new Device::Modem( port => '/dev/ttyUSB8' );

$modemA->connect( baudrate => 115200 );
$modemA->attention();
$modemA->echo(0);

$modemB->connect( baudrate => 115200 );
$modemB->attention();
$modemB->echo(0);

$modemA->atsend('AT+CGSN' . Device::Modem::CR);
($result, $answerA) = $modemA->parse_answer();
print "Modem found:\n IMEI: " . $answerA . "\n ";
getICCID($modemA);

$modemB->atsend('AT+CGSN' . Device::Modem::CR);
($result, $answerB) = $modemB->parse_answer();
print "Modem found:\n IMEI: " . $answerB . "\n ";
getICCID($modemB);

if($answerA =~ /7960/) {
	testModem($modemA);
} else {
	testModem($modemB);
}


sub testModem {
	my $modem = shift;

	print "\n----------------------------------------\n\nTesting SIM switch...\n\n";

        $modem->atsend('AT+ICCID' . Device::Modem::CR);
        ($result, $answerFirst) = $modem->parse_answer();
	print $answerFirst . "\n";

	print "Switching SIM card...\n";

	$modem->atsend('AT+CFUN=0' . Device::Modem::CR);
	
	sleep 2;

#	`echo 9 > /sys/class/gpio/export`;
#	`echo out > /sys/class/gpio/gpio9/direction`;
#ara	`echo 0 > /sys/class/gpio/gpio9/value`;

	sleep 3;
	
	$modem->atsend('AT+CFUN=1' . Device::Modem::CR);

	sleep 3;

        $modem->atsend('AT+ICCID' . Device::Modem::CR);
        ($result, $answerSecond) = $modem->parse_answer();
	print $answerSecond . "\n";

	print "Going back to first SIM card...\n";

	sleep 2;

	$modem->atsend('AT+CFUN=0' . Device::Modem::CR);

#	`echo 1 > /sys/class/gpio/gpio9/value`;

	sleep 3;

	$modem->atsend('AT+CFUN=1' . Device::Modem::CR);

	sleep 3;

	getICCID($modem);

	if($answerFirst ne $answerSecond) {
		print "\nSIM cards switched successfully!\nAll done.\n";
	}
}

sub getICCID {
	my $modem = shift;
        $modem->atsend('AT+ICCID' . Device::Modem::CR);
        ($result, $answer) = $modem->parse_answer();
        if($result eq 'OK') {
                @iccid = split(' ', $answer);
                print "ICCID: " . $iccid[1] . "\n";
        } else {
                print "Error getting ICCID\n";
                exit;
        }
}

sub enableProperitary {
	my $modem = shift;
        $modem->atsend('AT!ENTERCND="A710"' . Device::Modem::CR);
        ($result, $answer) = $modem->parse_answer();
        if($result eq 'OK') {
                print "Access to properitary commands enabled\n";
        } else {
                print "Error enabling properitary commands\n";
                exit;
        }
}

sub setSIMLPM() {
	$modem = shift;
        $modem->atsend('AT!CUSTOM="SIMLPM", 2' . Device::Modem::CR);
        ($result, $answer) = $modem->parse_answer();
        if($result eq 'OK') {
                print "Access to properitary commands enabled\n";
        } else {
                print "Error enabling properitary commands\n";
                exit;
        }
}
