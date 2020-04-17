#!/bin/env perl -w

use strict;
use 5.010;

use Text::CSV;

my $csv = Text::CSV->new({binary => 1,});

my %user_data = ();

my $data_file = shift @ARGV;

my @ordered_players = ();

open my $user_data, '<', $data_file
  or die "Count not open $data_file for reading: $!\n";

ROW: while (my $row = $csv->getline($user_data)) {
    next ROW if $row->[0] eq '#player';
    next if scalar @{ $row } <= 1;
    my ($name, undef, @lengths) = @{ $row };  ##Toss starts throwing data
    push @ordered_players, $name;
    $user_data{$name} = \@lengths;
}
close $user_data;

my @seconds_countdown = ();

use DateTime;

my $counter = DateTime->new(
    year => 2020,
    month => 4,
    day => 1,
    hour => 0,
    minute => 59,
    second => 59,
);

open my $flourish, '>:encoding(UTF-8)', 'flourish.csv' or
    die "Could not open flourish.csv for writing: $!\n";

##Print header
while ($counter->hour == 0) {
    push @seconds_countdown, $counter->minute.$counter->strftime(":%S");
    $counter->subtract(seconds => 1);
}

$csv->combine('name', @seconds_countdown);
say $flourish $csv->string;
use Clone qw/clone/;
use JSON qw//;

##Process data
foreach my $golfer (@ordered_players) {
    say $golfer;
    my @flourish_data = ($golfer);
    my $golfer_data = clone $user_data{$golfer};  ##Keep the original, just in case
    say JSON::to_json($golfer_data, {pretty => 1, });
    my $distance = 0;
    INSTANT: foreach my $instant (@seconds_countdown) {
        last INSTANT unless $golfer_data->[0];
        say "$instant == ".$golfer_data->[0]." $distance";
        if ($golfer_data->[0] eq $instant) {
            say $distance;
            $distance += 10;
            shift @{ $golfer_data };
        }
        push @flourish_data, $distance;
    }
    $csv->combine(@flourish_data);
    say $flourish $csv->string;
}

close $flourish;
