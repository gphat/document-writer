package Document::Writer;
use Moose;
use MooseX::AttributeHelpers;

use Carp;
use Forest;
use Paper::Specs units => 'pt';

use Document::Writer::Page;

our $AUTHORITY = 'cpan:GPHAT';
our $VERSION = '0.08';

has 'components' => (
    metaclass => 'Collection::Array',
    is => 'rw',
    isa => 'ArrayRef[Graphics::Primitive::Component]',
    default => sub { [] },
    provides => {
        'clear'=> 'clear_components',
        'count'=> 'component_count',
        'get' => 'get_component',
        'push' => 'add_component',
        'first'=> 'first_component',
        'last' => 'last_component'
    }
);
has 'last_page' => (
    is => 'rw',
    isa => 'Document::Writer::Page',
);

sub draw {
    my ($self, $driver) = @_;

    my @pages;
    foreach my $c (@{ $self->components }) {

        next unless(defined($c));

        $driver->prepare($c);

        if($c->isa('Document::Writer::Page')) {
            # $driver->prepare($c);
            $c->layout_manager->do_layout($c);

            push(@pages, $c);
        } else {
            #  Seed the current page
            my $currpage = $pages[-1];

            die('First component must be a Page') unless defined($currpage);

            if($c->isa('Document::Writer::TextArea')) {
                $c->width($currpage->inside_width);
                my $layout = $driver->get_textbox_layout($c);
                my $lh = $layout->height;

                my $used = 0;

                while($used < $lh) {
                    my $avail = $currpage->body->inside_height
                        - $currpage->body->layout_manager->used->[1];
                    if($avail == 0) {
                        $currpage = $self->add_page_break($driver);
                        push(@pages, $currpage);
                        $driver->prepare($currpage);
                        $currpage->layout_manager->do_layout($currpage);
                        $avail = $currpage->body->inside_height
                            - $currpage->body->layout_manager->used->[1];
                        next;
                    }

                    if($avail > $layout->height) {
                        my $tb = $layout->slice($used);
                        $currpage->body->add_component($tb);

                        $used += $tb->minimum_height;
                    } else {
                        # print "B\n";
                        my $tb = $layout->slice($used, $avail);
                        # print "AXXX: $used $avail\n";
                        # print "MH: ".$tb->minimum_height."\n";
                        $currpage->body->add_component($tb);
                        $used += $tb->minimum_height;
                    }
                    $driver->prepare($currpage);
                    $currpage->layout_manager->do_layout($currpage);
                    $currpage = $self->add_page_break($driver);
                }
            } else {
                my $pageadded = 0 ;
                my $avail = $currpage->body->inside_height
                    - $currpage->body->layout_manager->used->[1];
                if($avail >= $c->height) {
                    $currpage->add_component($c);
                    $driver->prepare($c);
                    $c->layout_manager->do_layout($c);
                } else {
                    if($pageadded) {
                        die("Stopping possible endless loop: $c too big for page");
                    }
                    $pageadded = 1;
                    $self->add_page_break($driver);
                    push(@pages, $currpage);
                }
            }
        }
    }

    foreach my $p (@pages) {

        # Prepare all the pages...
        $driver->prepare($p);
        # Layout each page...
        if($p->layout_manager) {
            $p->layout_manager->do_layout($p);
        }
        $driver->finalize($p);
        $driver->reset;
        $driver->draw($p);
        # use Forest::Tree::Writer::ASCIIWithBranches;
        # my $t = Forest::Tree::Writer::ASCIIWithBranches->new(tree => $p->get_tree);
        # print $t->as_string;
    }

    return \@pages;
}

sub find {
    my ($self, $predicate) = @_;

    my $newlist = Graphics::Primitive::ComponentList->new;
    foreach my $c (@{ $self->components }) {

        return unless(defined($c));

        unless($c->can('components')) {
            return $newlist;
        }
        my $list = $c->find($predicate);
        if(scalar(@{ $list->components })) {
            $newlist->push_components(@{ $list->components });
            $newlist->push_constraints(@{ $list->constraints });
        }
    }

    return $newlist;
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

    foreach my $c (@{ $self->components }) {
        $tree->add_child($c->get_tree);
    }

    return $tree;
}

sub add_page_break {
    my ($self, $driver, $page) = @_;

    my $newpage;
    if(defined($page)) {
        $newpage = $page;
    } else {
        die('Must add a first page to create implicit ones.') unless defined($self->last_page);
        my $last = $self->last_page;
        $newpage = Document::Writer::Page->new(
            color   => $last->color,
            width   => $last->width,
            height  => $last->height,
        );
    }

    $driver->prepare($newpage);
    $newpage->layout_manager->do_layout($newpage);

    $self->add_component($newpage);
    $self->last_page($newpage);

    return $newpage;
}

__PACKAGE__->meta->make_immutable;

1;
__END__
=head1 NAME

Document::Writer - Library agnostic document creation

=head1 SYNOPSIS

    use Document::Writer;
    # Use whatever you like
    use Graphics::Primitive::Driver::Cairo;

    my $doc = Document::Writer->new(
        default_color => Graphics::Color::RGB->new(...)
    );
    # Create the first page
    my $p = $doc->next_page(Document::Writer->get_paper_dimensions('letter'));
    $doc->add_text_to_page($driver, $long_multiline_text);
    my $p2 = $doc->next_page;
    # ... Do some other stuff
    $self->draw($driver);
    $driver->write('/Users/gphat/foo.pdf');

=head1 DESCRIPTION

Document::Writer is a document creation library that is built on the
L<Graphics::Primitive> stack.  It aims to provide convenient abstractions for
creating documents and a library-agnostic base for the embedding of other
components that use Graphics::Primitive.

When you create a new Document::Writer, it has no pages.  You can add pages
to the document using either C<add_page($page)> or C<next_page>.  If calling
next_page to create your first page you'll need to provide a width and height
(which can conveniently be gotten from C<get_paper_dimensions>).  Subsequent
calls to C<next_page> will default the newly created page to the size of the
last page in the document.

=head1 WARNING

This is an early release meant to shake support out of the underlying
libraries.  Further abstractions are forthcoming to make adding content to the
pages easier than using L<Graphics::Primitive> directly.

=head1 METHODS

=over 4

=item I<add_text_to_page ($driver, $font, $string, [$color])>

Adds the text supplied to the current page.  Lines are automatically wrapped
based on the current page's width.  If the text exceeds the space available
on the current page then a new page will be created via C<next_page>.  This
will be repeated until all the text has been added to the document.

The supplied font will be used to determine how to display the text.

=item I<add_to_page ($driver, $component)>

Add a L<Graphics::Primitive::Component> to the page.  The component must
have a width and height set.  If the component exceeds the space available
on the current page then another page will be added via C<next_page>.  If the
component is bigger than the current page size except bad things to happen.

=item I<add_page ($page)>

Add an already created page object to this document.

=item I<clear_pages>

Remove all pages from this document.

=item I<current_page>

The index of the current page.  This value is updated when calling next_page
and is undefined when the document is created. TODO

=item I<draw ($driver)>

Convenience method that hides all the Graphics::Primitive magic when you
give it a driver.  After this method completes the entire document will have
been rendered into the driver.  You can retrieve the output by using
L<Driver's|Graphics::Primitive::Driver> I<data> or I<write> methods.

=item I<find ($CODEREF)>

Compatability and convenience method matching C<find> in
Graphics::Primitive::Container.

Returns a new ComponentList containing only the components for which the
supplied CODEREF returns true.  The coderef is called for each component and
is passed the component and it's constraints.  Undefined components (the ones
left around after a remove_component) are automatically skipped.

  my $flist = $list->find(
    sub{
      my ($component, $constraint) = @_; return $comp->class eq 'foo'
    }
  );

If no matching components are found then a new list is returned so that simple
calls liked $container->find(...)->each(...) don't explode.

=item I<find_page ($name)>

Finds a page by name, if it exists.

=item I<first_page>

Return the first page.

=item I<get_paper_dimensions>

Given a paper name, such as letter or a4, returns a height and width in points
as an array.  Uses L<Paper::Specs>.

=item I<get_page ($pos)>

Returns the page at the given position

=item I<get_tree>

Returns a L<Forest::Tree> object with this document at it's root and each
page (and it's children) as children.  Provided for convenience.

=item I<next_page ([$width, $height])>

Return the next page. Increments the C<current_page> by one.  If a page exists
at that index it is returned.  If a page does not exist then a new page is
added to this document.

If there are pages already in the document then width and height information
will be copied from the last page.  Prodiving width and height as arguments
to this method override that behaviour and are necessary if there are no pages
from which to copy it.

Note: Color is copied from the last page.  If there is no last page then
the C<default_color> is used.

For less sugar use I<add_page>.

=item I<page_count>

Get the number of pages in this document.

=item I<pages>

Get the pages in this document.

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