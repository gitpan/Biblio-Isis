#!/usr/bin/perl -w

use strict;
use blib;

use Data::Dumper;

use Test::More tests => 110;

BEGIN { use_ok( 'Biblio::Isis' ); }

my $debug = shift @ARGV;
my $isis;

sub test_data {

	my $args = {@_};

	isa_ok ($isis, 'Biblio::Isis');

	cmp_ok($isis->count, '==', 5, "count is 5");

	# test .CNT data

	SKIP: {
		skip "no CNT file for this database", 5 unless $isis->{cnt_file};

		ok(my $isis_cnt = $isis->read_cnt, "read_cnt");

		cmp_ok(scalar keys %{$isis_cnt}, '==', 2, "returns 2 elements");

		my $cnt = {
			'1' => {
				'N' => 15,
				'K' => 5,
				'FMAXPOS' => 8,
				'POSRX' => 1,
				'ABNORMAL' => 1,
				'ORDN' => 5,
				'LIV' => 0,
				'ORDF' => 5,
				'NMAXPOS' => 1
				},
			'2' => {
				'N' => 15,
				'K' => 5,
				'FMAXPOS' => 4,
				'POSRX' => 1,
				'ABNORMAL' => 0,
				'ORDN' => 5,
				'LIV' => 0,
				'ORDF' => 5,
				'NMAXPOS' => 1
				}
		};

		foreach my $c (keys %{$cnt}) {
			foreach my $kn (keys %{$cnt->{$c}}) {
				cmp_ok($isis_cnt->{$c}->{$kn}, '==', $cnt->{$c}->{$kn}, "cnt $c $kn same");
			}
		}
	}

	# test fetch

	my $data = [ {
		'801' => [ '^aFFZG' ],
		'702' => [ '^aHolder^bElizabeth' ],
		'990' => [ '2140', '88', 'HAY' ],
		'675' => [ '^a159.9' ],
		'210' => [ '^aNew York^cNew York University press^dcop. 1988' ],
	}, {
		'210' => [ '^aNew York^cUniversity press^d1989' ],
		'700' => [ '^aFrosh^bStephen' ],
		'990' => [ '2140', '89', 'FRO' ],
		'200' => [ '^aPsychoanalysis and psychology^eminding the gap^fStephen Frosh' ],
		'215' => [ '^aIX, 275 str.^d23 cm' ],
	}, {
		'210' => [ '^aLondon^cFree Associoation Books^d1992' ],
		'700' => [ '^aTurkle^bShirlie' ],
		'990' => [ '2140', '92', 'LAC' ],
		'200' => [ '^aPsychoanalitic politics^eJacques Lacan and Freud\'s French Revolution^fSherry Turkle' ],
		'686' => [ '^a2140', '^a2140' ],
	
	}, {
		'700' => [ '^aGross^bRichard' ],
		'200' => [ '^aKey studies in psychology^fRichard D. Gross' ],
		'210' => [ '^aLondon^cHodder & Stoughton^d1994' ],
		'10' => [ '^a0-340-59691-0' ],
	}, {
		# identifier test
		'225' => [ '1#^aMcGraw-Hill series in Psychology' ],
		'200' => [ '1#^aPsychology^fCamille B. Wortman, Elizabeth F. Loftus, Mary E. Marshal' ],
	} ];
		
	foreach my $mfn (1 .. $isis->count) {
		my $rec;
		ok($rec = $isis->fetch($mfn), "fetch $mfn");

		foreach my $f (keys %{$data->[$mfn-1]}) {
			my $i = 0;
			foreach my $v (@{$data->[$mfn-1]->{$f}}) {
				$v =~ s/^[01# ][01# ]// if ($args->{no_ident});
				cmp_ok($v, '==', $rec->{$f}->[$i], "MFN $mfn $f:$i $v");
				$i++;
			}
		}
	}

	# test to_ascii

	SKIP: {
		eval "use Digest::MD5 qw(md5_hex)";

		skip "no Digest::MD5 module", 5 if ($@);

		foreach my $mfn (1 .. $isis->count) {
			my $md5 = md5_hex($isis->to_ascii($mfn));
			cmp_ok($md5, 'eq', $args->{md5_ascii}[$mfn - 1], "md5 $mfn");
		}
	}

}

$isis = Biblio::Isis->new (
	isisdb => './data/winisis/BIBL',
	include_deleted => 1,
	debug => $debug,
);

print Dumper($isis);

test_data(
	no_ident => 1,
	md5_ascii => [ qw(
		a369eff702307ba12eb81656ee0587fe
		4fb38537a94f3f5954e40d9536b942b0
		579a7c6901c654bdeac10547a98e5b71
		7d2adf1675c83283aa9b82bf343e3d85
		daf2cf86ca7e188e8360a185f3b43423
	) ],
);

$isis = Biblio::Isis->new (
	isisdb => './data/isismarc/BIBL',
	include_deleted => 1,
);

test_data(
	md5_ascii => [ qw(
		f5587d9bcaa54257a98fe27d3c17a0b6
		3be9a049f686f2a36af93a856dcae0f2
		3961be5e3ba8fb274c89c08d18df4bcc
		5f73ec00d08af044a2c4105f7d889e24
		843b9ebccf16a498fba623c78f21b6c0
	) ],
);

# check logically deleted

$isis = Biblio::Isis->new (
	isisdb => './data/winisis/BIBL',
	include_deleted => 1,
);

ok($isis->fetch(3), "deleted found");
cmp_ok($isis->{deleted}, '==', 3, "MFN 3 is deleted");

$isis = Biblio::Isis->new (
	isisdb => './data/winisis/BIBL',
	debug => $debug,
);

ok(! $isis->fetch(3), "deleted not found");
cmp_ok($isis->{deleted}, '==', 3, "MFN 3 is deleted");

