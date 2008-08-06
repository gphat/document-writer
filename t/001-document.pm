use Test::More tests => 7;

use Document::Writer;
use Document::Writer::Page;

my $doc = Document::Writer->new;
isa_ok($doc, 'Document::Writer');

my ($w, $h) = Document::Writer->get_paper_dimensions('letter');

eval {
    $doc->turn_page;
};
ok($@ =~ /Need a height/, 'turn_page with no pages');

my $tpage = $doc->turn_page($w, $h);
cmp_ok($doc->page_count, '==', 1, '1 page');

my $page = Document::Writer::Page->new(width => $w, height => $h);
isa_ok($page, 'Document::Writer::Page');

$doc->add_page($page);
cmp_ok($doc->page_count, '==', 2, '2 pages');

my $newpage = $doc->turn_page;
cmp_ok($newpage->width, '==', $page->width, 'new page width');
cmp_ok($newpage->height, '==', $page->height, 'new page height');
