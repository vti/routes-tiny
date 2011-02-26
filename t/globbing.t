use strict;
use warnings;

use Test::More tests => 7;

use Routes::Tiny;

my $r = Routes::Tiny->new;

$r->add_route('/photos/*other',         name => 'glob1');
$r->add_route('/books/*section/:title', name => 'glob2');
$r->add_route('/*a/foo/*b',             name => 'glob3');

my $m = $r->match('photos/foo/bar/baz');
is_deeply($m->params, {other => 'foo/bar/baz'});

$m = $r->match('books/some/section/last-words-a-memoir');
is_deeply($m->params,
    {section => 'some/section', title => 'last-words-a-memoir'});

$m = $r->match('zoo/woo/foo/bar/baz');
is_deeply($m->params, {a => 'zoo/woo', b => 'bar/baz'});

is($r->build_path('glob1', other => 'foo/bar/baz'), '/photos/foo/bar/baz');
is( $r->build_path(
        'glob2',
        section => 'fiction/fantasy',
        title   => 'hello'
    ),
    '/books/fiction/fantasy/hello'
);
is($r->build_path('glob3', a => 'foo/bar', b => 'baz/zab'),
    '/foo/bar/foo/baz/zab');

eval { $r->build_path('glob2'); };
ok($@ =~ qr/Required glob param 'section' was not passed when building a path/
);
