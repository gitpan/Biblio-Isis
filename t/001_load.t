#!/usr/bin/perl -w

use strict;
use blib;

use Test::More tests => 2;

BEGIN { use_ok( 'Biblio::Isis' ); }

my $object = Biblio::Isis->new (
	isisdb => './data/winisis/BIBL',
);

isa_ok ($object, 'Biblio::Isis');


