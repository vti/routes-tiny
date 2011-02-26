package Routes::Tiny::Pattern;

use strict;
use warnings;

use Routes::Tiny::Match;

my $TOKEN = '[^\/()]+';

sub new {
    my $class = shift;

    my $self = {captures => [], constraints => {}, @_};
    bless $self, $class;

    return $self;
}

sub name { return shift->{name} }

sub pattern {
    my $self = shift;

    return $self->{pattern} if ref $self->{pattern} eq 'Regexp';

    $self->_compile;

    return $self->{pattern};
}

sub match {
    my $self = shift;
    my ($path, %args) = @_;

    return unless $self->_match_method($args{method});

    unless ($path =~ m{ ^ / }xms) {
        $path = "/$path";
    }

    my $pattern = $self->pattern;

    my @captures = ($path =~ m/ $pattern /xms);
    return unless @captures;

    my $params = {};
    $params = {%{$self->{defaults} || {}}};

    foreach my $capture (@{$self->{captures}}) {
        last unless @captures;

        my $value = shift @captures;

        if (defined($value) || !exists $params->{$capture}) {
            $params->{$capture} = $value;
        }
    }

    return $self->_build_match(pattern => $pattern, params => $params);
}

sub build_path {
    my $self   = shift;
    my %params = @_;

    my $path = q{};

    my @parts;

    my $optional_depth = 0;

    foreach my $part (@{$self->_parts}) {
        my $type = $part->{type};
        my $name = $part->{name};

        if ($type eq 'capture') {
            if ($part->{optional} && exists $params{$name}) {
                $optional_depth = $part->{optional};
            }

            if (!exists $params{$name}) {
                next
                  if $part->{optional} && $part->{optional} > $optional_depth;

                Carp::croak(
                    "Required param '$part->{name}' was not passed when building a path"
                );
            }

            my $param = $params{$name};

            if (defined(my $constraint = $part->{constraint})) {
                Carp::croak("Param '$name' fails a constraint")
                  unless $param =~ m/^ $constraint $/xms;
            }

            push @parts, $param;
        }
        elsif ($type eq 'glob') {
            Carp::croak(
                "Required glob param '$name' was not passed when building a path"
            ) unless exists $params{$name};

            push @parts, $params{$name};
        }
        elsif ($type eq 'text') {
            push @parts, $part->{text};
        }
    }

    if (length $path) {
        unshift @parts, $path;
    }

    return join q{/} => @parts;
}

sub _parts {
    my $self = shift;

    return $self->{parts} if ref $self->{pattern} eq 'Regexp';

    $self->_compile;

    return $self->{parts};
}

sub _match_method {
    my $self  = shift;
    my ($value) = @_;

    my $method = $self->{method};

    return 1 unless defined $method;

    return unless defined $value;

    my $methods = $method;
    $methods = [$methods] unless ref $methods eq 'ARRAY';

    return !! scalar grep { $_ eq $value } @{$methods};
}

sub _compile {
    my $self = shift;

    my $pattern = $self->{pattern};

    $self->{captures} = [];

    my $re = q{};

    if ($pattern !~ m{ \A / }xms) {
        $pattern = q{/} . $pattern;
    }

    my $par_depth = 0;

    my @parts;

    pos $pattern = 0;
    while (pos $pattern < length $pattern) {
        if ($pattern =~ m{ \G \/ }gcxms) {
            $re .= q{/};
        }
        elsif ($pattern =~ m{ \G :($TOKEN) }gcxms) {
            my $name = $1;
            my $constraint;
            if (exists $self->{constraints}->{$name}) {
                $constraint = $self->{constraints}->{$name};
                $re .= "($constraint)";
            }
            else {
                $re .= '([^\/]+)';
            }

            push @parts,
              { type       => 'capture',
                name       => $name,
                constraint => $constraint ? qr/^ $constraint $/xms : undef,
                optional   => $par_depth
              };

            push @{$self->{captures}}, $name;
        }
        elsif ($pattern =~ m{ \G \*($TOKEN) }gcxms) {
            my $name = $1;

            $re .= '(.*)';

            push @parts, {type => 'glob', name => $name};

            push @{$self->{captures}}, $name;
        }
        elsif ($pattern =~ m{ \G ($TOKEN) }gcxms) {
            my $text = $1;
            $re .= quotemeta $text;

            push @parts, {type => 'text', text => $text};
        }
        elsif ($pattern =~ m{ \G \( }gcxms) {
            $par_depth++;
            $re .= '(?: ';
        }
        elsif ($pattern =~ m{ \G \)\? }gcxms) {
            $par_depth--;
            $re .= ' )?';
        }
        elsif ($pattern =~ m{ \G \) }gcxms) {
            $par_depth--;
            $re .= ' )';
        }
    }

    if ($par_depth != 0) {
        Carp::croak("Parentheses are not balanced in pattern '$pattern'");
    }

    $re = qr/^ $re $/xmsi;

    $self->{parts}   = [@parts];
    $self->{pattern} = $re;

    return $self;
}

sub _build_match { shift; return Routes::Tiny::Match->new(@_) }

1;
__END__

=head1 NAME

Routes::Tiny::Pattern - Routes pattern

=head1 SYNOPSIS

    my $pattern = Routes::Tiny::Pattern->new(
        pattern  => '/:foo/:bar',
        defaults => {bar => 'index'},
        name     => 'route'
    );

    my $match = $pattern->match('/hello/world');

    my $path = $pattern->build_path('route', foo => 'hello', bar => 'world');

=head1 DESCRIPTION

L<Routes::Tiny::Pattern> is an Object that incapsulates pattern matching and
path building.

=head1 ATTRIBUTES

=head2 C<defaults>

Pass default values for captures.

=head2 C<constraints>

Pass constraints.

=head2 C<name>

Pass route name.

=head2 C<pattern>

Pass actual pattern.

=head1 METHODS

=head2 C<new>

    my $pattern = Routes::Tiny::Pattern->new;

Create new instance of L<Routes::Tiny::Pattern>.

=head2 C<match>

Match pattern agains a path.

=head2 C<build_path>

    $pattern->build_path('name', {foo => 'bar'});

Build path from a given name and params.

=cut
