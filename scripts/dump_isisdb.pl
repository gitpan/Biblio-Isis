#!/usr/bin/perl -w

use strict;
use blib;

use Biblio::Isis;
use Data::Dumper;

my $isisdb = shift @ARGV || '/data/isis_data/ps/LIBRI/LIBRI',
my $debug = shift @ARGV;

my $isis = Biblio::Isis->new (
	isisdb => $isisdb,
	debug => $debug,
	include_deleted => 1,
#	read_fdt => 1,
);

print "rows: ",$isis->count,"\n\n";

for(my $mfn = 1; $mfn <= $isis->count; $mfn++) {
	print STDERR Dumper($isis->to_hash($mfn)),"\n" if ($debug);
	print $isis->to_ascii($mfn),"\n";

}

