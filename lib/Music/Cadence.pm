package Music::Cadence;

# ABSTRACT: Provides the chords of musical cadences

our $VERSION = '0.0100';

use Music::Chord::Note;
use Music::Scales;
use Music::ToRoman;

use Moo;
use strictures 2;
use namespace::clean;

=head1 SYNOPSIS

  use Music::Cadence;

  my $mc = Music::Cadence->new;

  my $notes = $mc->cadence(
    key    => 'C',
    scale  => 'major',
    type   => 'perfect',
    octave => 4,
  ); # [['G4','B4','D4'], ['C4','E4','G4']]

  $notes = $mc->cadence(
    key       => 'C',
    scale     => 'major',
    type      => 'imperfect',
    variation => 1,
    octave    => 0,
  ); # [['D','F','A'], ['G','B','D']]

=head1 DESCRIPTION

C<Music::Cadence> provides the chords of musical cadences.

* This a naive attempt with not enough knowledge of music theory.

Supported cadences are:

  perfect
  imperfect
  plagal
  deceptive

Supported scales are:

  ionian / major
  dorian
  phrygian
  lydian
  mixolydian
  aeolian / minor
  locrian

=head1 ATTRIBUTES

None.

=head1 METHODS

=head2 new

  $mc = Music::Cadence->new;

Create a new C<Music::Cadence> object.

=head2 cadence

  $notes = $mc->cadence;        # Use defaults

  $notes = $mc->cadence(
    key       => $key,          # Default: C
    scale     => $scale,        # Default: major
    type      => $type,         # Default: perfect
    variation => $variation,    # Default: 0
    octave    => $octave,       # Default: 0
  );

Return an array reference of the notes of the cadence B<type> (and
B<variation> when B<type> is C<imperfect>) based on the given B<key>
and B<scale> name.  The B<octave> is optional.

The B<variation> is a number for each diatonic scale chord to use for
the first C<imperfect> cadence chord.  So for the key of C<C major>
this is:

  CM: 0
  Dm: 1
  EM: 2
  Fm: 3
  GM: 4
  Am: 5
  Bo: 6

=cut

sub cadence {
    my ( $self, %args ) = @_;

    my $cadence = [];

    $args{key}       ||= 'C';
    $args{scale}     ||= 'major';
    $args{type}      ||= 'perfect';
    $args{variation} //= 0;
    $args{octave}    //= 0;

    my $n     = 0;
    my @scale = get_scale_notes( $args{key}, $args{scale} );
    my %notes = map { $n++ => $_ } @scale;

    my $mcn = Music::Chord::Note->new;

    my $mtr = Music::ToRoman->new(
        scale_note => $args{key},
        scale_name => $args{scale},
        chords     => 0,
    );

    if ( $args{type} eq 'perfect' ) {
        $cadence = _generate_chord( $notes{4}, $args{octave}, $mtr, $mcn, $cadence );
        $cadence = _generate_chord( $notes{0}, $args{octave}, $mtr, $mcn, $cadence );
    }
    elsif ( $args{type} eq 'plagal' ) {
        $cadence = _generate_chord( $notes{3}, $args{octave}, $mtr, $mcn, $cadence );
        $cadence = _generate_chord( $notes{0}, $args{octave}, $mtr, $mcn, $cadence );
    }
    elsif ( $args{type} eq 'imperfect' ) {
        $cadence = _generate_chord( $notes{ $args{variation} }, $args{octave}, $mtr, $mcn, $cadence );
        $cadence = _generate_chord( $notes{4}, $args{octave}, $mtr, $mcn, $cadence );
    }
    elsif ( $args{type} eq 'deceptive' ) {
        $cadence = _generate_chord( $notes{4}, $args{octave}, $mtr, $mcn, $cadence );
        $cadence = _generate_chord( $notes{3}, $args{octave}, $mtr, $mcn, $cadence );
    }

    return $cadence;
}

sub _generate_chord {
    my ( $note, $octave, $mtr, $mcn, $cadence ) = @_;

    my $roman   = $mtr->parse($note);
    my $valance = $roman =~ /o/ ? 'dim' : /^[a-z]/ ? 'm' : '';

    my @notes = $mcn->chord( $note . $valance );

    @notes = map { $_ . $octave } @notes
        if $octave;

    push @$cadence, \@notes;

    return $cadence;
}

1;
__END__

=head1 SEE ALSO

L<Moo>

L<Music::Chord::Note>

L<Music::Scales>

L<Music::ToRoman>

L<https://en.wikipedia.org/wiki/Cadence>

L<https://www.musictheoryacademy.com/how-to-read-sheet-music/cadences/>

=head1 TO DO

Evaded cadence

Half cadences

=cut
