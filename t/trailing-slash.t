use strict;
use warnings;

use Test::More tests => 6;

use Routes::Tiny;

my $r = Routes::Tiny->new;
$r->add_route('/admin/');

my $m = $r->match('/admin');
ok(!$m);

$m = $r->match('/admin/');
ok($m);

$r = Routes::Tiny->new;
$r->add_route('/admin/:service(/:action)?');

$m = $r->match('/admin/foo');
ok($m);

$m = $r->match('/admin/foo/bar');
ok($m);

$r = Routes::Tiny->new;
$r->add_route('/admin/:service/(:action)?');

$m = $r->match('/admin/foo');
ok(!$m);

$m = $r->match('/admin/foo/');
ok($m);
