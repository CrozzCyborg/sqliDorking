#!/usr/bin/perl
use CPAN;

if($< != 0){
	print "¡You need to run this as root!";
	exit;
}

install 'HTTP::Request';
install 'LWP';
install 'Benchmark';
install 'POSIX';
install 'threads';
install 'Time::HiRes';
