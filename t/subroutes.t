use strict;
use warnings;

use Test::More;

use Routes::Tiny;

my $r1 = Routes::Tiny->new;
$r1->add_route('/',         name => 'r1_root');
$r1->add_route('/bla/:id/', name => 'r1_id');

my $r2 = Routes::Tiny->new;
$r2->add_route('/',           name => 'r2_root');
$r2->add_route('/bar/:id/',   name => 'r2_bar');
$r2->add_route('/bar/*path/', name => 'r2_path');
ok($r2->mount('/r1/', $r1));

my $r3 = Routes::Tiny->new;
$r3->add_route('/bar/:id/', name => 'r3_bar');

my $ro = Routes::Tiny->new;
ok($ro->mount('/r2/', $r2));
ok($ro->mount('/r3/:parent_id/', $r3, name => 'r3_inc'));
$ro->add_route('/r2/*path/', name => 'parent_foo_path');
$ro->add_route('/*path',     name => 'fallback');

$r2->add_route('/late_route/', name => 'late-route');

my $m1 = $ro->match('/r2/');
ok($m1 && $m1->{name} eq 'r2_root');

my $m2 = $ro->match('/r2/bla/bla/');
ok($m2 && $m2->{name} eq 'parent_foo_path');
ok($m2->{captures}->{path} eq 'bla/bla');

my $m3 = $ro->match('/r2/bar/3/');
ok($m3 && $m3->{name} eq 'r2_bar');
is($m3->{captures}->{id}, 3);

my $m4 = $ro->match('/r2/r1/');
ok($m4 && $m4->{name} eq 'r1_root');

my $m5 = $ro->match('/r2/r1/bla/3/');
ok($m5 && $m5->{name} eq 'r1_id');

my $m6 = $ro->match('/r3/5/bar/7/');
ok($m6 && $m6->{name} eq 'r3_bar');
is($m6->{captures}->{id}, 7);
ok($m6->{parent} && $m6->{parent}->{name} eq 'r3_inc');
is($m6->{parent}->{captures}->{parent_id}, 5);

my $m7 = $ro->match('/r3/5/baz/7/');
ok($m7 && $m7->{name} eq 'fallback');

my $p1 = $ro->build_path('r2_bar', id => 3);
is($p1, '/r2/bar/3/');

my $p2 = $ro->build_path('r3_bar', parent_id => 1, id => 2);
is($p2, '/r3/1/bar/2/');

my $p3 = $ro->build_path('late-route');
is($p3, '/r2/late_route/');

subtest 'pass params to subroutes' => sub {
    my $r1 = Routes::Tiny->new;
    $r1->add_route('/foo', method => 'POST');

    my $ro = Routes::Tiny->new;
    $ro->mount('/subroute/', $r1);

    ok !$ro->match('/subroute/foo', method => 'GET');
    ok $ro->match('/subroute/foo', method => 'POST');
};

subtest 'sub-subroutes' => sub {
  my $r0 = Routes::Tiny->new;
  $r0->mount('/toplevel/:id', $ro);

  my $match = $r0->match('/toplevel/22/r3/5/bar/7/');

  ok($match);
  if($match) {
    my $parent = $match->parent;
    ok($parent);
    is($parent->captures->{parent_id}, 5);
    if($parent) {
      my $grandparent = $parent->parent;
      ok($grandparent);
      is($grandparent->captures->{id}, 22);
    }

    my $cascading_captures = $match->cascading_captures;
    is($cascading_captures->{id}, 7); # Id overrides grandparent id
    is($cascading_captures->{parent_id}, 5);
  }
};


done_testing;
