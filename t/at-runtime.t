use Test::More;

BEGIN {
	package Thingy;
	$INC{'Thingy.pm'} = __FILE__;
	use Class::XSConstructor::AtRuntime ();
	sub import {
		my $caller = caller;
		&Class::XSConstructor::AtRuntime::at_runtime( sub {
			no strict 'refs';
			::is( ${"$caller\::FOO"}, 42 );
		} );
	}
};

our $FOO = 42;
use Thingy;

done_testing;
