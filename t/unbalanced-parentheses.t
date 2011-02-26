use strict;
use warnings;

use Test::More tests => 1;

use Routes::Tiny;

my $r = Routes::Tiny->new;
$r->add_route('/((((');

eval { $r->match('foo/bar') };
ok($@ =~ qr/are not balanced/);
