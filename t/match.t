use strict;
use warnings;

use Test::More tests => 2;

use Routes::Tiny;

my $r = Routes::Tiny->new;
$r->add_route('/foo');
$r->add_route('/:foo/:bar');

my $m = $r->match('foo');
is_deeply($m->params, {});

$m = $r->match('hello/there');
is_deeply($m->params, {foo => 'hello', bar => 'there'});
