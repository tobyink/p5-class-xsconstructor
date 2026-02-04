$meta->{prereqs}{runtime}{requires}{'MRO::Compat'}   = '0'  if $] < 5.010;

if ($ENV{EXTENDED_TESTING}) {
	$meta->{prereqs}{test}{requires}{'Types::Standard'} = '1.002000';
}

# Only overwrite bundled version of ppport.h if newer than 3.42.
if (eval "use Devel::PPPort 3.42; 1") {
	Devel::PPPort::WriteFile();
}

$dynamic_config{OBJECT} ='$(O_FILES)';

my $STRICT;
$STRICT++ if ( $ENV{GITHUB_REPOSITORY} and $ENV{GITHUB_REPOSITORY} =~ /p5-class-xsconstructor/ );
$STRICT++ if ( $ENV{EXTENDED_TESTING}  and $ENV{USER} and $ENV{USER} eq 'tai' );
$STRICT++ if ( $ENV{PERL_XS_STRICTC89} );
if ( $STRICT ) {
	require Config;
	my $SPACE = q{ };
	$dynamic_config{CCFLAGS} = join $SPACE => (
		$Config::Config{ccflags},
		'-std=c89',
		'-Werror',
	);
}
