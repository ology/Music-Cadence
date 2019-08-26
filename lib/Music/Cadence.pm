package Music::Cadence;

# ABSTRACT: Provide musical cadence chords

our $VERSION = '0.0503';

use Moo;
use Music::Chord::Note;
use Music::Scales;
use Music::ToRoman;

use strictures 2;
use namespace::clean;

=head1 SYNOPSIS

  use Music::Cadence;

  my $mc = Music::Cadence->new;

  $mc = Music::Cadence->new( octave => 4 );

  my $chords = $mc->cadence( type => 'perfect' );
  # [['G4','B4','D4'], ['C4','E4','G4']]

  $chords = $mc->cadence(
    type    => 'half',
    leading => 2,
    octave  => 0,
  ); # [['D','F','A'], ['G','B','D']]

  $mc = Music::Cadence->new(
    key    => 'C#',
    octave => 5,
  );

  $chords = $mc->cadence( type => 'perfect' );
  # [['G#5','C5','D#5'], ['C#5','F5','G#5']]

  $mc = Music::Cadence->new(
    key    => 'C#',
    octave => 5,
    format => 'midi',
  );

  $chords = $mc->cadence( type => 'perfect' );
  # [['Gs5','C5','Ds5'], ['Cs5','F5','Gs5']]

=head1 DESCRIPTION

C<Music::Cadence> provides musical cadence chords.

* This module is a naive implementation of the actual theory.  YMMV.
Patches welcome.

=head1 ATTRIBUTES

=head2 key

The key or tonal center to use.  Default: C<C>

Examples: C<G#>, C<Eb>

=cut

has key => (
    is      => 'ro',
    default => sub { 'C' },
);

=head2 scale

The scale to use.  Default: C<major>

Supported scales are:

  ionian / major
  dorian
  phrygian
  lydian
  mixolydian
  aeolian / minor
  locrian

=cut

has scale => (
    is      => 'ro',
    default => sub { 'major' },
);

=head2 octave

The octave to append to chord notes.  Default: C<0> meaning "do not
append."

=cut

has octave => (
    is      => 'ro',
    default => sub { 0 },
);

=head2 format

If C<midi>, convert sharp C<#> to C<s> and flat C<b> to C<f> after
chord generation.  Default: C<''> (none)

=cut

has format => (
    is      => 'ro',
    default => sub { '' },
);

=head1 METHODS

=head2 new

  $mc = Music::Cadence->new;  # Use defaults

  $mc = Music::Cadence->new(  # Override defaults
    key    => $key,
    scale  => $scale,
    octave => $octave,
    format => $format,
  );

Create a new C<Music::Cadence> object.

=head2 cadence

  $chords = $mc->cadence;     # Use defaults

  $chords = $mc->cadence(     # Override defaults
    key       => $key,        # Default: C
    scale     => $scale,      # Default: major
    octave    => $octave,     # Default: 0
    type      => $type,       # Default: perfect
    leading   => $leading,    # Default: 1
    variation => $variation,  # Default: 1
  );

Return an array reference of the chords of the cadence B<type> based
on the given B<key> and B<scale> name.

The B<octave> is optional and if given, should be a number greater
than or equal to zero.

The B<variation> applies to the C<deceptive> cadence and determines
the final chord.  If given as C<1>, the C<vi> chord is used.  If given
as C<2>, the C<IV> chord is used.

Supported cadences are:

  perfect
  half
  plagal
  deceptive

The B<leading> chord is a number (1-7) for each diatonic scale chord
to use for the first C<half> cadence chord.  For the key of C<C major>
this is:

  CM: 1
  Dm: 2
  Em: 3
  FM: 4
  GM: 5
  Am: 6
  Bo: 7

=cut

sub cadence {
    my ( $self, %args ) = @_;

    my $cadence = [];

    $args{key}       ||= $self->key;
    $args{scale}     ||= $self->scale;
    $args{octave}    //= $self->octave;
    $args{type}      ||= 'perfect';
    $args{leading}   ||= 1;
    $args{variation} ||= 1;

    die 'unknown leader' if $args{leading} < 1 or $args{leading} > 7;

    my @scale = get_scale_notes( $args{key}, $args{scale} );

    my $mcn = Music::Chord::Note->new;

    my $mtr = Music::ToRoman->new(
        scale_note => $args{key},
        scale_name => $args{scale},
        chords     => 0,
    );

    if ( $args{type} eq 'perfect' ) {
        my $chord = $self->_generate_chord( $args{scale}, $scale[4], $args{octave}, $mtr, $mcn );
        push @$cadence, $chord;

        $chord = $self->_generate_chord( $args{scale}, $scale[0], $args{octave}, $mtr, $mcn );
        push @$cadence, $chord;
    }
    elsif ( $args{type} eq 'plagal' ) {
        my $chord = $self->_generate_chord( $args{scale}, $scale[3], $args{octave}, $mtr, $mcn );
        push @$cadence, $chord;

        $chord = $self->_generate_chord( $args{scale}, $scale[0], $args{octave}, $mtr, $mcn );
        push @$cadence, $chord;
    }
    elsif ( $args{type} eq 'half' ) {
        my $chord = $self->_generate_chord( $args{scale}, $scale[ $args{leading} - 1 ], $args{octave}, $mtr, $mcn );
        push @$cadence, $chord;

        $chord = $self->_generate_chord( $args{scale}, $scale[4], $args{octave}, $mtr, $mcn );
        push @$cadence, $chord;
    }
    elsif ( $args{type} eq 'deceptive' ) {
        my $chord = $self->_generate_chord( $args{scale}, $scale[4], $args{octave}, $mtr, $mcn );
        push @$cadence, $chord;

        my $note = $args{variation} == 1 ? $scale[5] : $scale[3];
        $chord = $self->_generate_chord( $args{scale}, $note, $args{octave}, $mtr, $mcn );
        push @$cadence, $chord;
    }
    else {
        die 'unknown cadence';
    }

    return $cadence;
}

sub _generate_chord {
    my ( $self, $scale, $note, $octave, $mtr, $mcn ) = @_;

    # Know what chords should be diminished
    my %diminished = (
        ionian     => 'vii',
        major      => 'vii',
        dorian     => 'vi',
        phrygian   => 'v',
        lydian     => 'iv',
        mixolydian => 'iii',
        aeolian    => 'ii',
        minor      => 'ii',
        locrian    => 'i',
    );

    die 'unknown scale' unless exists $diminished{$scale};

    # Figure out if the chord is diminished, minor, or major
    my $roman = $mtr->parse($note);
    my $type  = $roman =~ /^$diminished{$scale}$/ ? 'dim' : $roman =~ /^[a-z]/ ? 'm' : '';

    # Generate the chord notes
    my @notes = $mcn->chord( $note . $type );

    if ( $self->format eq 'midi' ) {
        for ( @notes ) {
            s/#/s/;
            s/b/f/;
        }
    }

    # Append the octave if requested
    @notes = map { $_ . $octave } @notes
        if $octave;

    return \@notes;
}

1;
__END__

=head1 SEE ALSO

The F<eg/cadence> and F<t/01-methods.t> files in this distribution.

L<Moo>

L<Music::Chord::Note>

L<Music::Scales>

L<Music::ToRoman>

L<https://en.wikipedia.org/wiki/Cadence>

L<https://www.musictheoryacademy.com/how-to-read-sheet-music/cadences/>

=head1 TO DO

Evaded cadence

Imperfect cadences

=cut
