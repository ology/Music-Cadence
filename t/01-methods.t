#!/usr/bin/env perl
use strict;
use warnings;
no warnings 'qw';

use Test::More;

use_ok 'Music::Cadence';

my $obj = Music::Cadence->new;
isa_ok $obj, 'Music::Cadence';

my $notes = $obj->cadence(
    key   => 'C',
    scale => 'major',
    type  => 'perfect',
);
is_deeply $notes, [ [qw/ G B D /], [qw/ C E G /] ], 'C perfect';

$notes = $obj->cadence(
    key   => 'C#',
    scale => 'major',
    type  => 'perfect',
);
is_deeply $notes, [ [qw/ G# C D# /], [qw/ C# F G# /] ], 'C# perfect';

$notes = $obj->cadence(
    key   => 'C',
    scale => 'major',
    type  => 'plagal',
);
is_deeply $notes, [ [qw/ F A C /], [qw/ C E G /] ], 'C plagal';

$notes = $obj->cadence(
    key   => 'C#',
    scale => 'major',
    type  => 'plagal',
);
is_deeply $notes, [ [qw/ F# A# C# /], [qw/ C# F G# /] ], 'C# plagal';

$notes = $obj->cadence(
    key       => 'C',
    scale     => 'major',
    type      => 'imperfect',
    variation => 1,
);
is_deeply $notes, [ [qw/ D F A /], [qw/ G B D /] ], 'C imperfect';

$notes = $obj->cadence(
    key       => 'C#',
    scale     => 'major',
    type      => 'imperfect',
    variation => 5,
);
is_deeply $notes, [ [qw/ A# C# F /], [qw/ G# C D# /] ], 'C# imperfect';

$notes = $obj->cadence(
    key   => 'C',
    scale => 'major',
    type  => 'deceptive',
);
is_deeply $notes, [ [qw/ G B D /], [qw/ F A C /] ], 'C deceptive';

$notes = $obj->cadence(
    key   => 'C#',
    scale => 'major',
    type  => 'deceptive',
);
is_deeply $notes, [ [qw/ G# C D# /], [qw/ F# A# C# /] ], 'C# deceptive';

done_testing();
