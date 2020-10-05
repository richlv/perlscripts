use strict;
use warnings;

use Time::Moment;
use Text::Table;

my %months;
my @result;
my $infile = shift;
open(my $fh, '<', $infile) or die $!;

while(my $line = <$fh>){
    chomp $line;
    my ($eid, $startdate, $enddate) = split /,/, $line;
    $startdate = Time::Moment->from_string($startdate . "T00Z");
    $enddate   = Time::Moment->from_string($enddate . "T00Z");
    for (my $curmonth = $startdate->with_day_of_month('1'); $curmonth->delta_months($enddate->with_day_of_month('1')) >= 0; $curmonth = $curmonth->plus_months('1')) {
        $months{$curmonth->strftime('%Y-%m')}->{$eid} = 1;
    }
}

close($fh);

foreach my $month (sort keys %months) {
     push @result, [ $month, scalar keys %{$months{$month}} ];
}

my $table = Text::Table->new;
$table->load(@result);
print $table->body();
