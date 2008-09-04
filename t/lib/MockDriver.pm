package # Hide from CPAN
    MockDriver;
use Moose;

use Geometry::Primitive::Rectangle;

has 'height' => ( is => 'rw', isa => 'Num' );
has 'width' => ( is => 'rw', isa => 'Num' );

sub get_text_bounding_box {
    my ($self, $font, $text) = @_;

    my $height = int(rand(3) + 2);

    return (
        Geometry::Primitive::Rectangle->new(
            origin => [0, 0],
            width => length($text),
            height => 4#$height
        ),
        Geometry::Primitive::Rectangle->new(
            origin => [0, 0],
            width => length($text),
            height => 4#$height
        ),
    );
}

sub prepare {};

1;