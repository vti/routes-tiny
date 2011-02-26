use strict;
use warnings;

use Test::More tests => 3;

use Routes::Tiny;

my $r = Routes::Tiny->new;

$r->add_route('/admin/:service(/:action)?', defaults => {action => 'list'});

my $m = $r->match('/admin/foo');
is_deeply($m->params, {service => 'foo', action => 'list'});

$m = $r->match('/admin/foo/bar');
is_deeply($m->params, {service => 'foo', action => 'bar'});

$m = $r->match('/admin/bar');
is_deeply($m->params, {service => 'bar', action => 'list'});
