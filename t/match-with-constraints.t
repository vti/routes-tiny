use strict;
use warnings;

use Test::More tests => 2;

use Routes::Tiny;

my $r = Routes::Tiny->new;

$r->add_route('/articles/:id', constraints => {id => qr/\d+/});

my $m = $r->match('articles/abc');
ok(!$m);

$m = $r->match('articles/123');
is_deeply($m->params, {id => 123});
