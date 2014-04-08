#!/usr/bin/perl
use CPAN;

if($< != 0){
	print "¡Necesitas ejecutar esto como root!";
	exit;
}

install 'HTTP::Request';
install 'LWP';
install 'Benchmark';
install 'POSIX';
install 'threads';
install 'Time::HiRes';
