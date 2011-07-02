package Routes::Tiny;

use strict;
use warnings;

require Carp;
use Routes::Tiny::Pattern;

our $VERSION = 0.009013;

sub new {
    my $class = shift;

    my $self = {patterns => []};
    bless $self, $class;

    return $self;
}

sub add_route {
    my $self    = shift;
    my $pattern = shift;

    $pattern = $self->_build_pattern(pattern => $pattern, @_);

    push @{$self->{patterns}}, $pattern;

    return $pattern;
}

sub match {
    my $self = shift;
    my $path = shift;
    my @args = @_;

    foreach my $pattern (@{$self->{patterns}}) {
        if (my $m = $pattern->match($path, @args)) {
            return $m;
        }
    }

    return;
}

sub build_path {
    my $self = shift;
    my $name = shift;

    my $pattern = $self->_find_route($name);

    return $pattern->build_path(@_) if $pattern;

    Carp::croak("Unknown name '$name' used to build a path");
}

sub _find_route {
    my $self = shift;
    my ($name) = @_;

    foreach my $pattern (@{$self->{patterns}}) {
        return $pattern if $pattern->name && $pattern->name eq $name;
    }

    return;
}

sub _build_pattern { shift; return Routes::Tiny::Pattern->new(@_) }

1;
__END__

=head1 NAME

Routes::Tiny - Routes

=head1 SYNOPSIS

    my $routes = Routes::Tiny->new;

    # Constraints
    $routes->add_route('/articles/:id', constraints => {id => qr/\d+/});

    # Optional placeholders
    $routes->add_route('/archive/:year/(:month)?');

    # Defaults
    $routes->add_route('/articles/:id',
        defaults => {controller => 'bar', action => 'foo'});

    # Grouping (matches 'hello-bar')
    $routes->add_route('/(:foo)-bar');

    # Globbing (matches 'photos/foo/bar/baz')
    $routes->add_route('/photos/*other');

    # Path building
    $routes->add_route('/:foo/:bar', name => 'default');
    $routes->build_path('default', foo => 'hello', bar => 'world');

    # Matching
    my $match = $routes->match('/hello/world');
    my $params_hashref = $match->params;

    # Matching with method
    my $match = $routes->match('/hello/world', method => 'GET');

=head1 DESCRIPTION

L<Routes::Tiny> is a lightweight routes implementation.

L<Routes::Tiny> aims to be easy to use in any web framework.

=head1 FEATURES

=head2 C<Constraints>

    $routes->add_route('/articles/:id', constraints => {id => qr/\d+/});

    $match = $routes->match('/articles/1');  # Routes::Tiny::Match object
    $match = $routes->match('/article/foo'); # undef

It is possible to specify a constraint that a placeholder must match using a
normal Perl regular expression.

=head2 C<Optional placeholders>

    $routes->add_route('/admin/:service(/:action)?', defaults => {action => 'list'});

    my $match = $routes->match('/admin/foo');
    # $m->params is {service => 'foo', action => 'list'}

It is possible to specify an optional placeholder with a default value.

=head2 C<Grouping>

    $routes->add_route('/(:foo)-bar');

    $match = $routes->match('/hello-bar');
    # $match->params is {foo => 'hello'}

It is possible to create a placeholder that doesn't occupy all the space between
slashes.

=head2 C<Globbing>

    $routes->add_route('/photos/*other');
    $routes->add_route('/books/*section/:title');
    $routes->add_route('/*a/foo/*b');

    $match = $routes->match('photos/foo/bar/baz');
    # $match->params is {other => 'foo/bar/baz'}

    $match = $routes->match('books/some/section/last-words-a-memoir');
    # $match->params is {section => 'some/section', title => 'last-words-a-memoir'}

    $match = $routes->match('zoo/woo/foo/bar/baz');
    # $match->params is {a => 'zoo/woo', b => 'bar/baz'}

It is possible to specify a globbing placeholder.

=head2 C<Path building>

    $routes->add_route('/articles/:id', name => 'article');

    $path = $routes->build_path('article', id => 123);
    # $path is '/articles/123'

It is possible to reconstruct a path from route's name and parameters.

=head1 WARNINGS

=head2 C<Trailing slash issue>

Trailing slash is important. Maybe this will be changed in the future.

    $routes->add_route('/articles');

    # is different from

    $routes->add_route('/articles/');

=head1 METHODS

=head2 C<new>

    my $routes = Routes::Tiny->new;

=head2 C<add_route>

    $routes->add_route('/:service/:action');

Add a new route.

=head2 C<match>

    $routes->match('/hello/world');

Match against a path.

=head2 C<build_path>

    $pattern->build_path('name', {foo => 'bar'});

Build path from a given name and params.

=head1 DEVELOPMENT

=head2 Repository

    http://github.com/vti/routes-tiny

=head1 AUTHOR

Viacheslav Tykhanovskyi, C<vti@cpan.org>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011, Viacheslav Tykhanovskyi

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
