package Routes::Tiny::Match;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {params => {}, @_};
    bless $self, $class;

    return $self;
}

sub params {
    my $self = shift;

    return $self->{params};
}

sub pattern {
    my $self = shift;

    return $self->{pattern};
}

1;
__END__

=head1 NAME

Routes::Tiny::Match - Matched object

=head1 SYNOPSIS

    my $match = $r->match('/foo/bar');

    my $pattern = $match->pattern;
    my $params_hashref = $match->params;

=head1 DESCRIPTION

L<Routes::Tiny::Match> is a Value Object that holds params of a matched route.

=head1 ATTRIBUTES

=head2 C<pattern>

    my $pattern = $match->pattern;

Get original route's pattern.

=head2 C<params>

    my $params_hashref = $match->params;

Get params.

=head1 METHODS

=head2 C<new>

    my $match = Routes::Tiny::Match->new;

Create new instance of L<Routes::Tiny::Match>.

=cut
