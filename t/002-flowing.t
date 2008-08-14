use strict;
use Test::More tests => 3;
use lib qw(lib t/lib);

use Document::Writer;
use Document::Writer::Page;

use Graphics::Color::RGB;

use MockDriver;

my $doc = Document::Writer->new(
    default_color => Graphics::Color::RGB->new(red => 0, green => 0, blue => 0, alpha => 1)
);

isa_ok($doc, 'Document::Writer');

my $tpage = $doc->next_page(80, 5);
cmp_ok($doc->page_count, '==', 1, '1 page');

my $text = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

my $driver = MockDriver->new;

$doc->add_text_to_page($driver, Graphics::Primitive::Font->new, $text);

cmp_ok($doc->page_count, '==', 6, '6 pages');
