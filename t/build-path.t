use strict;
use warnings;

use Test::More tests => 17;

use Routes::Tiny;

my $r = Routes::Tiny->new;

$r->add_route('/',          name => 'root');
$r->add_route('/foo',       name => 'one');
$r->add_route('/:foo/:bar', name => 'two');
$r->add_route(
    '/articles/:id',
    name        => 'article',
    constraints => {id => qr/\d+/}
);
$r->add_route('/photos/*other',                   name => 'glob1');
$r->add_route('/books/*section/:title',           name => 'glob2');
$r->add_route('/*a/foo/*b',                       name => 'glob3');
$r->add_route('/archive/:year(/:month/:day)?',    name => 'optional1');
$r->add_route('/archive/:year(/:month(/:day)?)?', name => 'optional2');

eval { $r->build_path('unknown') };
ok($@ =~ qr/Unknown name 'unknown' used to build a path/);

eval { $r->build_path('article'); };
ok($@ =~ qr/Required param 'id' was not passed when building a path/);

eval { $r->build_path('glob2'); };
ok($@ =~ qr/Required glob param 'section' was not passed when building a path/
);

eval { $r->build_path('article', id => 'abc'); };
ok($@ =~ qr/Param 'id' fails a constraint/);

is('/', $r->build_path('root'));

is('/foo', $r->build_path('one'));
is('/foo/bar', $r->build_path('two', foo => 'foo', bar => 'bar'));
is('/articles/123',       $r->build_path('article', id    => 123));
is('/photos/foo/bar/baz', $r->build_path('glob1',   other => 'foo/bar/baz'));
is( '/books/fiction/fantasy/hello',
    $r->build_path(
        'glob2',
        section => 'fiction/fantasy',
        title   => 'hello'
    )
);
is('/foo/bar/foo/baz/zab',
    $r->build_path('glob3', a => 'foo/bar', b => 'baz/zab'));

is('/archive/2010', $r->build_path('optional1', year => 2010));

eval { $r->build_path('optional1', year => 2010, month => 5); };
ok($@ =~ qr/Required param 'day' was not passed when building a path/);

is('/archive/2010/5/4',
    $r->build_path('optional1', year => 2010, month => 5, day => 4));

is('/archive/2010', $r->build_path('optional2', year => 2010));
is('/archive/2010/3', $r->build_path('optional2', year => 2010, month => 3));
is('/archive/2010/3/4',
    $r->build_path('optional2', year => 2010, month => 3, day => 4));
