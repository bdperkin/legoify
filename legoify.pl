#! /usr/bin/perl -w

use strict;
use warnings;

$ENV{PATH}="/bin:/sbin:/usr/bin:/usr/sbin";

if (@ARGV != 2) {
   die "Usage: $0 [NUM KNOBS] [SVG FILE]\n";
}

my($knobs, $file) = @ARGV;
chomp $file;

if($knobs !~ /^\d+$/) {
    die "$knobs is an invalid value for knobs\n";
}

my $widthmm = $knobs * 8;
my $widthpx = $widthmm * 10;

my %colormap = (
    'srgb(244,244,244)' => 'WHITE',
    'srgb(222,0,13)' => 'BR.RED',
    'srgb(0,87,168)' => 'BR.BLUE',
    'srgb(254,196,0)' => 'BR.YEL',
    'srgb(1,1,1)' => 'BLACK',
    'srgb(0,123,40)' => 'DK.GREEN',
    'srgb(217,187,123)' => 'BRICK-YEL',
    'srgb(149,185,11)' => 'BR.YEL-GREEN',
    'srgb(231,99,24)' => 'BR.ORANGE',
    'srgb(71,140,198)' => 'MD.BLUE',
    'srgb(76,81,86)' => 'DK. ST. GREY',
    'srgb(91,28,12)' => 'RED. BROWN',
    'srgb(156,146,145)' => 'MED. ST-GREY',
    'srgb(128,8,27)' => 'NEW DARK RED',
    'srgb(238,157,195)' => 'LGH. PURPLE',
);

if(!-f $file) {
    die "Cannot find file $file\n";
}

if(system("file $file | grep 'SVG Scalable Vector Graphics image\$'")) {
    die "$file is not an SVG Scalable Vector Graphics image\n";
}

system("inkscape $file --export-background=#FFFFFF --export-png=$file.png -w$widthpx --export-area-drawing");

my @WIDTH=`identify -verbose $file.png | grep png:IHDR.width,height | cut -d: -f3 | cut -d, -f1 | awk '{print \$1}'`;
my $wtest=$WIDTH[0];
chomp $wtest;
if($wtest != $widthpx) {
    die "Generated $wtest doesn't match expected $widthpx\n";
}

my @HEIGHT=`identify -verbose $file.png | grep png:IHDR.width,height | cut -d: -f3 | cut -d, -f2 | awk '{print \$1}'`;
my $heightpx=$HEIGHT[0];
chomp $heightpx;

my $xoffset = 0;
my $yoffset = 0;
my $plate = 0;

while($xoffset < ( $widthpx - 1 )) {
    while($yoffset < ( $heightpx - 1 )) {
        $plate++;
        my $geom="80x32+$xoffset+$yoffset";
        print "Plate $plate: $geom: ";
        system("convert -extract $geom $file.png $file.px");
        my @COLOR=`convert $file.px -scale 1x1\! -remap 3023_colormap.gif -format '%[pixel:s]' info:-`;
        my $srgbcolor=$COLOR[0];
        chomp $srgbcolor;
        print $colormap{$srgbcolor} . "\n";
        $yoffset = $yoffset + 32;
    }
    $yoffset = 0;
    $xoffset = $xoffset + 80;
}
