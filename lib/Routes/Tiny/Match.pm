package Routes::Tiny::Match;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{name}      = $params{name};
    $self->{arguments} = $params{arguments};
    $self->{captures}  = $params{captures};
    $self->{parent}    = $params{parent};

    return $self;
}

sub arguments {
    my $self = shift;

    return $self->{arguments};
}

sub params { &captures }

sub captures {
    my $self = shift;

    return $self->{captures};
}

sub cascading_captures {
    my $self = shift;

    my $captures = { %{$self->captures} };

    if($self->parent) {
        my $parent_captures = $self->parent->captures;

        for my $key (keys %$parent_captures) {
            if(exists $captures->{$key}) {
                my $parent_capture = $parent_captures->{$key};
                $captures->{$key} = [
                    (ref $parent_capture eq 'ARRAY' ? @$parent_capture : $parent_capture),
                    $captures->{$key}
                ];
            }
        }
    }

    return $self->parent ? {
        %{$self->parent->cascading_captures},
        %$captures
    } : $captures;
}

sub name {
    my $self = shift;

    return $self->{name};
}

sub parent {
    my $self = shift;

    return $self->{parent};
}

1;
__END__

=head1 NAME

Routes::Tiny::Match - Matched object

=head1 SYNOPSIS

    my $match = $r->match('/foo/bar');

    my $name = $match->name;
    my $params_hashref = $match->params;
    my $parent_match = $match->parent

=head1 DESCRIPTION

L<Routes::Tiny::Match> is a Value Object that holds params of a matched route.

=head1 ATTRIBUTES

=head2 C<name>

    my $name = $match->name;

Get original route's pattern name.

=head2 C<arguments>

    my $arguments = $match->arguments;

Get route's pattern arguments.

=head2 C<captures>

    my $hashref = $match->captures;

Get params.

=head2 cascading_captures

Get params as well as parent and ancestor params in one hash.

=head2 C<params>

An alias to C<captures>.

=head2 C<parent>

Reference to parent match in case of matching subroutes.

=head1 METHODS

=head2 C<new>

    my $match = Routes::Tiny::Match->new;

Create new instance of L<Routes::Tiny::Match>.

=cut
