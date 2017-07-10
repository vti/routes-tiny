use strict;
use warnings;

use Test::More;

use Routes::Tiny;

subtest 'match simple route case insensetive' => sub {
    my $r = Routes::Tiny->new();
    $r->add_route('/ADMIN/', name => 'route');
    ok $r->match('/admin/');
    ok $r->match('/ADMIN/');
    ok $r->match('/AdMiN/');
};

subtest 'match simple route case sensetive' => sub {
    my $r = Routes::Tiny->new(strict_case => 1);
    $r->add_route('/admin/', name => 'route');
    ok $r->match('/admin/');
    my $res = $r->match('/ADMIN/');
    ok!$res;
    ok!$r->match('/AdMiN/');
};

subtest 'match subroutes case sensetinve' => sub {
    my $r = Routes::Tiny->new(strict_case => 1);
    my $r2 = Routes::Tiny->new();
    $r2->add_route('/info/', name => 'info');
    $r->mount('/admin/', $r2);
    ok $r->match('/admin/info/');
    ok $r->match('/admin/INFO/');
    ok!$r->match('/ADMIN/info/');
    ok!$r->match('/AdMiN/info/');
};

done_testing;
