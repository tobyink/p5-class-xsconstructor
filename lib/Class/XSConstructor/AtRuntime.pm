use 5.008008;
use strict;
use warnings;

package Class::XSConstructor::AtRuntime;

use Class::XSConstructor ();
use Exporter::Tiny 1.000000 qw( _croak _carp );
our @ISA        = qw( Exporter::Tiny );
our @EXPORT_OK  = qw( at_runtime after_runtime );

BEGIN {
	our $AUTHORITY = 'cpan:TOBYINK';
	our $VERSION   = '0.023000';

	if ( eval { require Sub::Util; 1 } ) {
		*set_subname = \&Sub::Util::set_subname;
	}
	elsif ( eval { require Sub::Name; 1 } ) {
		*set_subname = \&Sub::Name::subname;
	}
	else {
		*set_subname = sub { pop @_ };
	}
	
	for my $f ( qw/ compiling_string_eval remaining_text count_BEGINs run / ) {
		no strict 'refs';
		*$f = \&{"Class::XSConstructor::$f"};
	}
};

my $USE_FILTER = defined $ENV{PERL_B_HOOKS_ATRUNTIME}
	? $ENV{PERL_B_HOOKS_ATRUNTIME} eq "filter"
	: not defined &Class::XSConstructor::lex_stuff;

if ( $USE_FILTER ) {
	require Filter::Util::Call;
	no warnings "redefine";
	*lex_stuff = set_subname lex_stuff => sub {
		my ( $str ) = @_;
		compiling_string_eval() and _croak "Can't stuff into a string eval";
		if (defined(my $extra = remaining_text())) {
			$extra =~ s/\n+\z//;
			_carp "Extra text '$extra' after call to lex_stuff";
		}
		Filter::Util::Call::filter_add( sub {
			$_ = $str;
			Filter::Util::Call::filter_del();
			return 1;
		} );
	};
}
else {
	*lex_stuff = \&Class::XSConstructor::lex_stuff;
}

my @Hooks;
sub replace_hooks {
	my ($new) = @_;
	delete $Class::XSConstructor::AtRuntime::{hooks};
	no strict "refs";
	$new and *{"hooks"} = $new;
}

sub clear {
	my ($depth) = @_;
	$Hooks[$depth] = undef;
	replace_hooks $Hooks[$depth - 1];
}

sub find_hooks {
	$USE_FILTER and compiling_string_eval() and _croak "Can't use at_runtime from a string eval";
	my $depth = count_BEGINs() or _croak "You must call at_runtime at compile time";
	my $hk;
	unless ($hk = $Hooks[$depth]) {
		my @hooks;
		$hk = $Hooks[$depth] = \@hooks;
		replace_hooks $hk;
		lex_stuff(
			q{Class::XSConstructor::AtRuntime::run(@Class::XSConstructor::AtRuntime::hooks);} .
			"BEGIN{Class::XSConstructor::AtRuntime::clear($depth)}"
		);
	}
	return $hk;
}

sub at_runtime (&) {
	my ($cv) = @_;
	my $hk = find_hooks;
	push @$hk, set_subname scalar(caller) . "::(at_runtime)", $cv;
}

sub after_runtime (&) {
	my ($cv) = @_;
	my $hk = find_hooks;
	push @$hk, \set_subname scalar(caller) . "::(after_runtime)", $cv;
}

1;
