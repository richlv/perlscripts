# perlscripts
Simple Perl scripts to help with various tasks

# days-per-month.pl

Takes two arguments of starting and ending date (inclusive), prints out how many days are covered per month in that range.
Example:

```
> perl days-per-month.pl 2019-11-15 2020-02-13
2019-Nov 16
2019-Dec 31
2020-Jan 31
2020-Feb 13
```

# employees-per-month.pl

Reads a CSV file of format:

```
id,startdate,enddate
id,startdate,enddate
...
```

Prints out all covered months and how many unique ids were present in each.

Example input file:

```
1,2019-10-01,2020-01-30
2,2019-10-30,2020-01-01
3,2020-01-01,2020-02-05
4,2020-01-05,2020-02-01
1,2019-10-01,2019-12-03
```

Example invocation and output:

```
> perl employees-per-month.pl in.csv 
2019-10 2
2019-11 2
2019-12 2
2020-01 4
2020-02 2
```
