#!/usr/bin/env perl
#

use warnings;
use strict;

my $line = 0;
my $num_fields = 0;
while ( <STDIN> ) { 
    $line++;
    #$_ =~ s/^(?:\357\273\277|\377\376\0\0|\0\0\376\377|\376\377|\377+\376)//g;
    $_ =~ s/[\n\r]+$//g;

    next if ( $_ eq '' );

    my @fields = split(/[\037]/, $_);

    if ( $line == 1 ) {
	$num_fields = $#fields;
    }
    else {
	for ( my $i = 0; $i <= $num_fields; $i++ ) {
	    if ( $i <= $#fields ) {
		$fields[$i] =~ s/[\r\n]/ /g;
		$fields[$i] =~ s/[,]/./g;
		$fields[$i] =~ s/^[\s]+//g;
		$fields[$i] =~ s/[\s]+$//g;
	    }
	    else {
		$fields[$i] = '';
	    }
	}
    }

    print join(',', @fields) . "\n";
    #print $fields[0] . "\n";
}

