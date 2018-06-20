$meta->{prereqs}{runtime}{requires}{'MRO::Compat'}   = '0'  if $] < 5.010;

if ($ENV{EXTENDED_TESTING}) {
	$meta->{prereqs}{test}{requires}{'Types::Standard'} = '1.002000';
}

if (eval { require Devel::PPPort }) {
	Devel::PPPort::WriteFile();
}
