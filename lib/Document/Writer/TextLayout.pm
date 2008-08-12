package Document::Writer::TextLayout;
use Moose;

use Text::Flow;

has 'font' => (
    is => 'rw',
    isa => 'Graphics::Primitive::Font',
    required => 1
);
has 'lines' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] }
);
has 'text' => (
    is => 'rw',
    isa => 'Str',
    required => 1
);
has 'width' => (
    is => 'rw',
    isa => 'Num',
    required => 1
);

sub height {
    my ($self) = @_;

    my $h = 0;
    foreach my $l (@{ $self->lines }) {
        $h += $l->{cb}->height;
    }
    return $h;
}

sub layout {
    my ($self, $driver) = @_;

    my $font = $self->font;
    my $width = $self->width;

    my $size;
    my $flow = Text::Flow->new(
        check_height => sub {
            return 1;
        },
        wrapper => Text::Flow::Wrap->new(
            check_width => sub {
                my $str = shift;
                my $r = $driver->get_text_bounding_box(
                    $font, $str
                );
                if($r->width > $width) {
                    return 0;
                }
                return 1;
            }
        )
    );

    my @text = $flow->flow($self->text);

    my $p = $text[0];
    my @lines = split(/\n/, $p);
    foreach my $l (@lines) {
        my ($cb, $tb) = $driver->get_text_bounding_box(
            $font, $l
        );

        push(@{ $self->lines }, {
            text => $l,
            box => $tb,
            cb => $cb
        });
    }
}

sub slice {
    my ($self, $offset, $size) = @_;

    unless(defined($size)) {
        $size = $self->height;
    }

    my @new;
    my $accum = 0;
    my $found = 0;
    for(my $i = 0; $i < scalar(@{ $self->lines }); $i++) {
        my $l = $self->lines->[$i];
        my $lh = $l->{cb}->height;

        if($accum < $offset) {
            $accum += $lh;
            next;
        }
        if(($accum + $lh) <= ($offset + $size)) {
            push(@new, $l);
            $accum += $lh;
            $found += $lh;
        }
    }

    my %ret = (
        size => $found,
        lines => \@new
    );
    return \%ret;
}

no Moose;
1;
__END__