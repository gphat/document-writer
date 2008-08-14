use Test::More tests => 7;

use Graphics::Color::RGB;

use Document::Writer;
use Document::Writer::Page;

my $doc = Document::Writer->new(
    default_color => Graphics::Color::RGB->new(red => 0, green => 0, blue => 0, alpha => 1)
);
isa_ok($doc, 'Document::Writer');

my ($w, $h) = Document::Writer->get_paper_dimensions('letter');

eval {
    $doc->next_page;
};
ok($@ =~ /Need a height/, 'next_page with no pages');

my $tpage = $doc->next_page($w, $h);
cmp_ok($doc->page_count, '==', 1, '1 page');

my $page = Document::Writer::Page->new(
    width => $w,
    height => $h,
    color => Graphics::Color::RGB->new(red => 0, green => 0, blue => 0, alpha => 1)
);
isa_ok($page, 'Document::Writer::Page');

$doc->add_page($page);
cmp_ok($doc->page_count, '==', 2, '2 pages');

my $newpage = $doc->next_page;
cmp_ok($newpage->width, '==', $page->width, 'new page width');
cmp_ok($newpage->height, '==', $page->height, 'new page height');
