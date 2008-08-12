use strict;
use Test::More tests => 7;
use lib qw(lib t/lib);

use Document::Writer;
use Document::Writer::Page;

use MockDriver;

my $doc = Document::Writer->new;
isa_ok($doc, 'Document::Writer');

my $tpage = $doc->next_page(80, 5);
cmp_ok($doc->page_count, '==', 1, '1 page');

my $text = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

my $driver = MockDriver->new;

$doc->add_text_to_page($driver, Graphics::Primitive::Font->new, $text);

use Forest::Tree::Writer::ASCIIWithBranches;
my $w = Forest::Tree::Writer::ASCIIWithBranches->new(tree => $doc->get_tree);
print $w->as_string;
