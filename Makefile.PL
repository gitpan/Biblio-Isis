use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	NAME => 'Biblio::Isis',
	VERSION_FROM => 'lib/Biblio/Isis.pm', # finds $VERSION
	AUTHOR => 'Dobrica Pavlinusic (dpavlin@rot13.org)',
	ABSTRACT_FROM => 'lib/Biblio/Isis.pm',
	PREREQ_PM => {
		'Test::Simple' => 0.44,
		'Carp' => 0,
		'File::Glob' => 0,
	},
	depend => {
		dist => 'changelog',
	},
);

sub MY::postamble {
	return <<'MAKE_MORE';

HTML_DIR=pod2html

html: $(TO_INST_PM)
	test -e $(HTML_DIR) && rm -Rf $(HTML_DIR)
	mkdir $(HTML_DIR)
	perl -MPod::Simple::HTMLBatch -e 'Pod::Simple::HTMLBatch::go' lib/ pod2html/
	test ! -z "`which svn2html.pl`" && svn update && svn2html.pl > $(HTML_DIR)/Changes.html

changelog:
	svn update && svn -v log > Changes

tags:
	ctags *.p? */*.p?

cmp:
	time ./scripts/dump_isis.pl > isis.txt
	time ./scripts/dump_openisis.pl > openisis.txt

bench:	all
	cd ./scripts/ && ./bench.pl

MAKE_MORE
}
