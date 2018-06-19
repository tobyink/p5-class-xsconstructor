use strict;
use warnings;
use Benchmark qw( cmpthese );

{
	package Person::CT;
	use Class::Tiny
		{ name => sub { die "name is required" } },
		qw( age phone email );
	sub BUILD { 1 }
}

{
	package Person::Moo;
	use Moo;
	has name => (is => 'rw', required => 1);
	has $_   => (is => 'rw', required => 0) for qw( age phone email );
	sub BUILD { 1 }
}

{
	package Person::Moose;
	use Moose;
	has name => (is => 'rw', required => 1);
	has $_   => (is => 'rw', required => 0) for qw( age phone email );
	sub BUILD { 1 }
}

{
	package Person::XSCON;
	use Class::XSConstructor
		qw( name! age phone email );
	use Class::XSAccessor { accessors => [qw( name age phone email )] };
	sub BUILD { 1 }
}

cmpthese(-1, {
	CT    => sub { Person::CT->new(name => "Alice", age => 40) for 1..1000 },
	Moo   => sub { Person::CT->new(name => "Alice", age => 40) for 1..1000 },
	Moose => sub { Person::CT->new(name => "Alice", age => 40) for 1..1000 },
	XSCON => sub { Person::XSCON->new(name => "Alice", age => 40) for 1..1000 },
})

__END__

Results with BUILD method:

       Rate   Moo Moose    CT XSCON
Moo   307/s    --   -0%   -0%  -51%
Moose 307/s    0%    --   -0%  -51%
CT    308/s    0%    0%    --  -50%
XSCON 621/s  102%  102%  102%    --

Results with the BUILD method commented out:

       Rate    CT Moose   Moo XSCON
CT    339/s    --   -2%   -2%  -50%
Moose 345/s    2%    --   -0%  -50%
Moo   345/s    2%    0%    --  -50%
XSCON 684/s  102%   98%   98%    --

