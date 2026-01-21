$meta->{prereqs}{runtime}{requires}{'MRO::Compat'}   = '0'  if $] < 5.010;

if ($ENV{EXTENDED_TESTING}) {
	$meta->{prereqs}{test}{requires}{'Types::Standard'} = '1.002000';
}

# Only overwrite bundled version of ppport.h if newer than 3.42.
if (eval "use Devel::PPPort 3.42; 1") {
	Devel::PPPort::WriteFile();
}

%dynamic_config = (
	OBJECT => '$(O_FILES)',
);
