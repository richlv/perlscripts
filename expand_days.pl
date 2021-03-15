use strict;
use warnings;

use Time::Moment;
use Text::Table;

my @result;
my $infile = shift;
open(my $fh, '<', $infile) or die $!;

while(my $line = <$fh>){
    my $index;
    chomp $line;
    my ($eid, $code, $startdate, $enddate) = split /,/, $line;
    $startdate = Time::Moment->from_string($startdate . "T00Z");
    $enddate   = Time::Moment->from_string($enddate . "T00Z");
    for (my $curday = $startdate; $curday < $enddate->plus_days('1'); $curday = $curday->plus_days('1')) {
        $index++;
        push @result, [ $eid, $code, $index, $curday->strftime('%Y-%m-%d') ];
    }

}

close($fh);

my $table = Text::Table->new;
$table->load(@result);
print $table->body();
