package Document::Writer::Page;
use Moose;

extends 'Graphics::Primitive::Container';

use Graphics::Primitive::Insets;
use Layout::Manager::Compass;

has 'footer' => (
    is => 'rw',
    isa => 'Graphics::Primitive::Component'
);
has 'header' => (
    is => 'rw',
    isa => 'Graphics::Primitive::Component'
);
has '+margins' => ( default => sub {
    Graphics::Primitive::Insets->new( left => 90, right => 90, top => 72, bottom => 72);
});
has '+layout_manager' => ( default => sub { Layout::Manager::Compass->new });
has '+page' => ( default => sub { 1 });

override('prepare', sub {
    my ($self, $driver) = @_;

    if(defined($self->header)) {
        $self->header->border->color(Graphics::Color::RGB->new(red => 1, green => 0, blue => 0, alpha => 1));
        $self->header->border->width(2);
        $self->add_component($self->header, 'n');
    }
    if(defined($self->footer)) {
        $self->footer->border->color(Graphics::Color::RGB->new(red => 1, green => 0, blue => 0, alpha => 1));
        $self->footer->border->width(2);
        $self->add_component($self->footer, 's');
    }
});

1;
__END__
=head1 NAME

Document::Writer::Page - A page in a document

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Document::Writer;

    my $foo = Document::Writer->new();
    ...

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