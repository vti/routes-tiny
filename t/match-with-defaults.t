use strict;
use warnings;

use Test::More tests => 3;

use Routes::Tiny;

my $r = Routes::Tiny->new;

$r->add_route('/articles',
    defaults => {controller => 'foo', action => 'bar'});
$r->add_route('/articles/:id',
    defaults => {controller => 'bar', action => 'foo', id => 1});

my $m = $r->match('articles');
is_deeply($m->params, {controller => 'foo', action => 'bar'});

$m = $r->match('articles/123');
is_deeply($m->params, {controller => 'bar', action => 'foo', id => 123});

$m = $r->match('articles/321');
is_deeply($m->params, {controller => 'bar', action => 'foo', id => 321});
