package Document::Writer;
use Moose;
use MooseX::AttributeHelpers;

use Carp;
use Forest;
use Paper::Specs units => 'pt';

our $AUTHORITY = 'cpan:GPHAT';
our $VERSION = '0.01';

has 'pages' => (
    metaclass => 'Collection::Array',
    is => 'rw',
    isa => 'ArrayRef[Document::Writer::Page]',
    default => sub { [] },
    provides => {
        'clear'=> 'clear_pages',
        'count'=> 'page_count',
        'get' => 'get_page',
        'push' => 'add_page',
        'first'=> 'first_page',
        'last' => 'last_page'
    }
);

sub find_page {
    my ($self, $name) = @_;

    foreach my $p ($self->pages) {
        return $p if($p->name eq $name);
    }
    return undef;
}

sub get_paper_dimensions {
    my ($self, $name) = @_;

    my $form = Paper::Specs->find(brand => 'standard', code => uc($name));
    if(defined($form)) {
        return $form->sheet_size;
    } else {
        return (undef, undef);
    }
}

sub get_tree {
    my ($self) = @_;

    my $tree = Forest::Tree->new(node => $self);

    foreach my $p (@{ $self->pages }) {
        $tree->add_child($p->get_tree);
    }

    return $tree;
}

sub turn_page {
    my ($self, $width, $height) = @_;

    my $newpage;
    if($width && $height) {
       $newpage = Document::Writer::Page->new(
           width => $width, height => $height
       );
    } else {
        my $currpage = $self->last_page;
        if($currpage) {
            $newpage = Document::Writer::Page->new(
                width => $currpage->width, height => $currpage->height
            );
        } else {
            croak("Need a height and width for first page.");
        }
    }
    $self->add_page($newpage);
    return $newpage;
}

sub write {
    my ($self, $driver, $name) = @_;

    foreach my $p (@{ $self->pages }) {
        # Prepare all the pages...
        $driver->prepare($p);
        # Layout each page...
        if($p->layout_manager) {
            $p->layout_manager->do_layout($p);
        }
        $driver->pack($p);
        $driver->reset;
        $driver->draw($p);
    }
    $driver->write($name);
}

1;
__END__
=head1 NAME

Document::Writer - Library agnostic document creation

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Document::Writer;

    my $foo = Document::Writer->new;
    ...

=head1 METHODS

=over 4

=item I<add_page ($page)>

Add an already created page object to this document.

=item I<clear_pages>

Remove all pages from this document.

=item I<components>

Provided for compatability with Graphics::Primitive::Driver.

=item I<find_page ($name)>

Finds a page by name, if it exists.

=item I<first_page>

Return the first page.

=item I<get_paper_dimensions>

Given a paper name, such as letter or a4, returns a height and width in points
as an array.  Uses L<Paper::Specs>.

=item I<get_page ($pos)>

Returns the page at the given position

=item I<height>

Returns the height of the first page, provided for compatibility with
Graphics::Primitive.

=item I<page_count>

Get the number of pages in this document.

=item I<pages>

Get the pages in this document.

=item I<turn_page>

"Turn" to a new page by creating a new one and add it to the list of pages
in this document.  If there are pages already in the document then the last
one will be used to provided height and width information.

For less sugar use I<add_page>.

=item I<width>

Returns the width of the first page, provided for compatibility with
Graphics::Primitive.

=back

=head1 SEE ALSO

L<Graphics::Primitive>, L<Paper::Specs>

=head1 AUTHOR

Cory Watson, C<< <gphat@cpan.org> >>

Infinity Interactive, L<http://www.iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests to C<bug-geometry-primitive at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Geometry-Primitive>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.