#!/usr/bin/env perl
use strict;
use warnings;
no warnings 'qw';

use Test::More;

use_ok 'Music::Cadence';

my $mc = Music::Cadence->new;
isa_ok $mc, 'Music::Cadence';

my $chords = $mc->cadence(
    key   => 'C',
    scale => 'major',
    type  => 'unknown',
);
is_deeply $chords, [], 'C unknown';

$chords = $mc->cadence(
    key   => 'C',
    scale => 'major',
    type  => 'perfect',
);
is_deeply $chords, [ [qw/ G B D /], [qw/ C E G /] ], 'C perfect';

$chords = $mc->cadence(
    key    => 'C#',
    scale  => 'major',
    type   => 'perfect',
    octave => 4,
);
is_deeply $chords, [ [qw/ G#4 C4 D#4 /], [qw/ C#4 F4 G#4 /] ], 'C# perfect';

$chords = $mc->cadence(
    key   => 'C',
    scale => 'major',
    type  => 'plagal',
);
is_deeply $chords, [ [qw/ F A C /], [qw/ C E G /] ], 'C plagal';

$chords = $mc->cadence(
    key   => 'C#',
    scale => 'major',
    type  => 'plagal',
);
is_deeply $chords, [ [qw/ F# A# C# /], [qw/ C# F G# /] ], 'C# plagal';

$chords = $mc->cadence(
    key       => 'C',
    scale     => 'major',
    type      => 'imperfect',
    variation => 1,
);
is_deeply $chords, [ [qw/ D F A /], [qw/ G B D /] ], 'C imperfect';

$chords = $mc->cadence(
    key       => 'C#',
    scale     => 'major',
    type      => 'imperfect',
    variation => 5,
);
is_deeply $chords, [ [qw/ A# C# F /], [qw/ G# C D# /] ], 'C# imperfect';

$chords = $mc->cadence(
    key   => 'C',
    scale => 'major',
    type  => 'deceptive',
);
is_deeply $chords, [ [qw/ G B D /], [qw/ F A C /] ], 'C deceptive';

$chords = $mc->cadence(
    key   => 'C#',
    scale => 'major',
    type  => 'deceptive',
);
is_deeply $chords, [ [qw/ G# C D# /], [qw/ F# A# C# /] ], 'C# deceptive';

done_testing();
