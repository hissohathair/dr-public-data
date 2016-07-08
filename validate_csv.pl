#!/usr/bin/perl -w
#

BEGIN {
    unshift @INC, $ENV{PERL5LIB};
}


use warnings;
use strict;

use Text::CSV;

require 5.8.1;


my $csv_in_settings = {
    binary   => 1,
#    sep_char => "\037",
#    quote_char => undef,
#    escape_char => undef,
};
my $csv_out_settings = {
    binary   => 1,
    eol      => $\,
    sep_char => ',',
};

my $csv_in  = Text::CSV->new ( $csv_in_settings )
    or die "Cannot use CSV in: ".Text::CSV->error_diag ();
my $csv_out = Text::CSV->new ( $csv_out_settings )
    or die "Cannot use CSV out: ".Text::CSV->error_diag ();

binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
binmode(STDIN, ":utf8");

my @rows;
my $line_num = 0;
my $num_fields = -1;

while ( <STDIN> ) {
    $line_num++;
    $_ =~ s/[\r\n]+$//g;

    if ( ! utf8::valid($_) ) {
	warn "Line $line_num is not valid UTF8 -- skipping\n";
	next;
    }

    my $status = $csv_in->parse( $_ );
    if ( ! $status ) {
	warn "Cannot parse($line_num): $_ [Error: " . $csv_in->error_diag() . "]\n";
	next;
    }

    my @fields = $csv_in->fields();
    print STDERR "$line_num...\r" if ( $line_num % 1000 == 0 );
    #print STDERR join("\t|||\t", @fields) . "\n";

    if ( $line_num == 1 ) {
	my @fixed_head = check_header(@fields);
	$csv_out->combine( @fixed_head );
	print $csv_out->string() . "\n";

	$num_fields = $#fields;
	print STDERR "Columns:\t" . ($num_fields+1) . "\n";
    }
    else {
	for ( my $i = $#fields+1; $i <= $num_fields; $i++ ) {
	    $fields[$i] = '';
	}
	if ( check_fields($line_num, $num_fields, @fields) ) {
	    $csv_out->combine( @fields );
	    print $csv_out->string() . "\n";
	}
    }
}
print STDERR "Rows:\t\t$line_num\n";


sub check_header {
    my @head = @_;
    my @fixed_head = @_;
    my %heads = ();
    for (my $i = 0; $i <= $#head; $i++ ) {
	if ( $head[$i] !~ m/^[a-z0-9_]+$/ ) {
	    warn "Header field $i has invalid characters: $head[$i] -- fixing\n";

	    my $h = $head[$i];

	    if ( $h =~ m/^[A-Z]+$/ ) {
		$h = lc $h;
	    }
	    else {
		$h =~ s/([A-Z][a-z])/_$1/g;
		$h = lc $h;
		$h =~ s/[^a-z0-9_]+//g;
		$h =~ s/__/_/g;
		$h =~ s/^_//g;
	    }
	    $fixed_head[$i] = $h;
	}

	if ( defined $heads{$fixed_head[$i]} ) {
	    warn "Duplicate header $fixed_head[$i] -- skipping\n";
	}
	$heads{$fixed_head[$i]} = 1;
    }
    return @fixed_head;
}

sub check_fields {
    my ($line_num_no, $num_fields, @fields) = @_;

    my $ok = 1;
    if ( $num_fields != $#fields ) {
	warn "$line_num_no: Should have $num_fields, has " . ($#fields+1) . "\n";
	$ok = 0;
    }
    return $ok;
}
