use strict;
use warnings;

use Time::Moment;
use Text::Table;

my @dayspermonth;

my $startdate = Time::Moment->from_string(shift . "T00Z");
my $enddate   = Time::Moment->from_string(shift . "T00Z");
my $endmonth  = $enddate->with_day_of_month('1');

# First month
push @dayspermonth, [ $startdate->strftime('%Y-%b'), ($startdate->delta_days($startdate->at_last_day_of_month) + 1) ];

# Full months
for (my $curmonth = $startdate->with_day_of_month('1')->plus_months('1'); $curmonth->delta_months($endmonth) > 0; $curmonth = $curmonth->plus_months('1')) {
    push @dayspermonth, [ $curmonth->strftime('%Y-%b'), $curmonth->length_of_month ];
}

# Last month
push @dayspermonth, [ $endmonth->strftime('%Y-%b'), ($endmonth->delta_days($enddate)) + 1 ];

# Output
my $table = Text::Table->new;
$table->load(@dayspermonth);
print $table->body();
