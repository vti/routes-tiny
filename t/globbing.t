use strict;
use warnings;

use Test::More tests => 3;

use Routes::Tiny;

my $r = Routes::Tiny->new;
$r->add_route('/photos/*other');
$r->add_route('/books/*section/:title');
$r->add_route('/*a/foo/*b');

my $m = $r->match('photos/foo/bar/baz');
is_deeply($m->params, {other => 'foo/bar/baz'});

$m = $r->match('books/some/section/last-words-a-memoir');
is_deeply($m->params,
    {section => 'some/section', title => 'last-words-a-memoir'});

$m = $r->match('zoo/woo/foo/bar/baz');
is_deeply($m->params, {a => 'zoo/woo', b => 'bar/baz'});
