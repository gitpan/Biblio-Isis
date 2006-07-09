#!/usr/bin/perl -w

use strict;
use blib;

use Biblio::Isis;
use Getopt::Std;

BEGIN {
	eval "use Data::Dump";

	if (! $@) {
		*Dumper = *Data::Dump::dump;
	} else {
		use Data::Dumper;
	}
}

my %opt;
getopts('dn:', \%opt);

my $isisdb = shift @ARGV || die "usage: $0 [-n number] [-d] /path/to/isis/BIBL\n";

my $isis = Biblio::Isis->new (
	isisdb => $isisdb,
	debug => $opt{'d'} ? 2 : 0,
	include_deleted => 1,
#	read_fdt => 1,
);

print "rows: ",$isis->count,"\n\n";

my $min = 1;
my $max = $isis->count;
$max = $opt{n} if ($opt{n});

for my $mfn ($min .. $max) {
	print STDERR Dumper($isis->to_hash($mfn)),"\n" if ($opt{'d'});
	print $isis->to_ascii($mfn),"\n";

}

