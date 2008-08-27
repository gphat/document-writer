use strict;
use lib qw(t t/lib);

use Test::More tests => 7;

use Graphics::Primitive::Font;

use Graphics::Color::RGB;

use MockDriver;

BEGIN {
    use_ok('Document::Writer::TextLayout');
}

my $text = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

my $tl = Document::Writer::TextLayout->new(
    default_color => Graphics::Color::RGB->new(
        red => 0, green => 0, blue => 0, alpha => 1
    ),
    font => Graphics::Primitive::Font->new(
        size => 12
    ),
    text => $text,
    width => 80
);

my $driver = new MockDriver;
$tl->layout($driver);

# cmp_ok(scalar(@{ $tl->lines }), '==', 6, 'line count');
# cmp_ok($tl->height, '==', 6, 'height');

my $ret = $tl->slice(0, 5);
cmp_ok($ret->{size}, '<=', 5, '0 offset, 5 size');
my $ret2 = $tl->slice(3, 2);
cmp_ok($ret2->{size}, '==', 0, '3 offset, 2 size');
my $ret3 = $tl->slice(4, 1);
cmp_ok($ret3->{size}, '==', 0, '4 offset, 1 size');

# 
my $lines3 = $tl->slice(4);
# use Data::Dumper;
# print Dumper($lines3);
cmp_ok(scalar(@{ $lines3->{lines} }), '==', 5, '8 offset slice');

my $lines4 = $tl->slice(0, 24);
cmp_ok(scalar(@{ $lines4->{lines} }), '==', 2, '0 offset, 24 size slice');

my $text2 = "One\nTwo\n\nThree";
my $tl2 = Document::Writer::TextLayout->new(
    font => Graphics::Primitive::Font->new,
    text => $text2,
    width => 80
);

$tl2->layout($driver);
cmp_ok(scalar(@{ $tl2->{lines} }), '==', 7, 'layout');


