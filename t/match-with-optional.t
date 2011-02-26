use strict;
use warnings;

use Test::More tests => 10;

use Routes::Tiny;

my $r = Routes::Tiny->new;

$r->add_route(':year(/:month/:day)?');

my $m = $r->match('2009');
is_deeply($m->params, {year => 2009, month => undef, day => undef});

$m = $r->match('2009/12/10');
is_deeply($m->params, {year => 2009, month => 12, day => 10});


$r = Routes::Tiny->new;
$r->add_route(':year(/:month)?/:day');

$m = $r->match('2009/12');
is_deeply($m->params, {year => 2009, month => undef, day => 12});

$m = $r->match('2009/12/2');
is_deeply($m->params, {year => 2009, month => 12, day => 2});


$r = Routes::Tiny->new;
$r->add_route(':year/(:month)?/:day');

$m = $r->match('2009/12');
ok(!$m);

$m = $r->match('2009/12/2');
is_deeply($m->params, {year => 2009, month => 12, day => 2});

$m = $r->match('2009//2');
is_deeply($m->params, {year => 2009, month => undef, day => 2});


$r = Routes::Tiny->new;
$r->add_route(':year/month(:month)?/:day');

$m = $r->match('2009/12/2');
ok(!$m);

$m = $r->match('2009/month/2');
is_deeply($m->params, {year => 2009, month => undef, day => 2});

$m = $r->match('2009/month08/2');
is_deeply($m->params, {year => 2009, month => '08', day => 2});
