use strict;
use warnings;

use Test::More tests => 2;

use Routes::Tiny;

my $r = Routes::Tiny->new;

$r->add_route('/(:foo)-bar');

my $m = $r->match('/hello-bar');
is_deeply($m->params, {foo => 'hello'});

$m = $r->match('/-bar');
ok(!$m);
