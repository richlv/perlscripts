use strict;
use warnings;

use LWP::UserAgent;
use Getopt::Long qw(GetOptions);
use XML::LibXML;
use JSON::XS;
use POSIX qw(strftime);
use Data::Dumper;

my $finalgpxversion = '1.0';
my $mly_endpoint    = 'https://graph.mapillary.com';
my $mly_fields      = 'geometry,captured_at';

my (@sequences, @images, @imgdata, %sequences_uniq, $token, $gpxfile, $track, $debug);
my $tzoffset=0;

GetOptions(
    'sequence|s=s' => \@sequences,
    'image|i=s'    => \@images,
    'token|t=s'    => \$token,
    'tzoffset|z=s' => \$tzoffset,
    'debug'        => \$debug,
) or die;

@sequences = split(/,/,join(',',@sequences));
@images    = split(/,/,join(',',@images));

if (not @sequences and not @images) {
    print "pass sequence IDs with --sequence or image IDs with --image\n";
    exit;
}

if (!$token) {
    print "pass Mapillary token with --token\n";
    exit;
}

sub debug {
    my $message = shift;
    print STDERR "$message\n" if $debug;
}

sub add_img {
    my $img = shift;

    my $lat = $img->{'geometry'}->{'coordinates'}->[1];
    my $lon = $img->{'geometry'}->{'coordinates'}->[0];

    push @imgdata, {
        lat => $lat,
        lon => $lon,
        time => $img->{'captured_at'},
    };
}

sub add_trkpt {
    my $img       = shift;
    my $final_gpx = shift;
    my $trkseg    = shift;

    my $timestamp = strftime('%FT%TZ', gmtime(($img->{'time'} / 1000) - ($tzoffset * 3600)));

    my $new_trkpt = $final_gpx->createElement('trkpt');
    $new_trkpt->addChild($final_gpx->createAttribute(lat  => $img->{'lat'}));
    $new_trkpt->addChild($final_gpx->createAttribute(lon  => $img->{'lon'}));
    $new_trkpt->appendTextChild('time', $timestamp);
    $new_trkpt = $trkseg->appendChild($new_trkpt);
}

my $ua = LWP::UserAgent->new;
$ua->default_header('Authorization' => "OAuth $token");

my $final_gpx = XML::LibXML::Document->createDocument($finalgpxversion);
my $gpxroot   = $final_gpx->createElement('gpx');
$gpxroot->addChild($final_gpx->createAttribute(version => '1.1'));
$gpxroot->addChild($final_gpx->createAttribute(creator => 'mapillary_to_gpx.pl'));
$gpxroot->addChild($final_gpx->createAttribute(xmlns   => 'http://www.topografix.com/GPX/1/1'));
$gpxroot->setNamespace('http://www.w3.org/2001/XMLSchema-instance', 'xsi', 0);
$gpxroot->setAttributeNS('http://www.w3.org/2001/XMLSchema-instance', 'schemaLocation', 'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd');        

my $new_trk = $final_gpx->createElement('trk');
$new_trk->addChild($final_gpx->createAttribute(name => "Track from Mapillary images"));

foreach my $image (@images) {
    debug("Extracting sequence info from image $image");
    my $imageinfo = $ua->get("https://graph.mapillary.com/$image?fields=sequence");
    my $parsed_image_json = decode_json($imageinfo->decoded_content);
    debug("Sequence $parsed_image_json->{'sequence'} found");
    if (grep{$_ eq $parsed_image_json->{'sequence'}} @sequences) {
        debug("Sequence $parsed_image_json->{'sequence'} already seen, skipping");
    } else {
        push(@sequences, $parsed_image_json->{'sequence'});
    }
}

foreach my $seq (@sequences) {
    debug("Processing sequence $seq");
    my $imagedata = $ua->get("$mly_endpoint/images?sequence_ids=$seq&fields=$mly_fields");

    my $parsed_image_json = decode_json($imagedata->decoded_content);

    my $new_trkseg = $new_trk->addChild($final_gpx->createElement('trkseg'));
    $new_trkseg->addChild($final_gpx->createAttribute(name => "Segment from Mapillary sequence $seq"));
    foreach my $img (@{$parsed_image_json->{'data'}}) {
        add_img($img);
    }
    # Sort images by timestamp - Mapillary returns them unordered
    @imgdata = sort {$a->{'time'} <=> $b->{'time'}} @imgdata;
    foreach my $ordered_img (@imgdata) {
        add_trkpt($ordered_img, $final_gpx, $new_trkseg);
    }
    $new_trkseg = $new_trk->appendChild($new_trkseg);
    @imgdata = ();
}

$new_trk = $gpxroot->appendChild($new_trk);
$gpxroot = $final_gpx->addChild($gpxroot);
print $final_gpx->toString(1);
