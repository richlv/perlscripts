# perlscripts
Simple Perl scripts to help with various tasks

## days-per-month.pl

Takes two arguments of starting and ending date (inclusive), prints out how many days are covered per month in that range.
Example:

```
> perl days-per-month.pl 2019-11-15 2020-02-13
2019-Nov 16
2019-Dec 31
2020-Jan 31
2020-Feb 13
```

## employees-per-month.pl

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

## expand_days.pl

Reads a CSV file of format:

```
3333,EUR_GLOBAL_1,2021-07-30,2021-08-02
4444,EUR_GLOBAL_2,2021-09-02,2021-09-03
```

Prints out all days between ranges along with an in-range index.

```
3333 EUR_GLOBAL_1 1 2021-07-30
3333 EUR_GLOBAL_1 2 2021-07-31
3333 EUR_GLOBAL_1 3 2021-08-01
3333 EUR_GLOBAL_1 4 2021-08-02
4444 EUR_GLOBAL_2 1 2021-09-02
4444 EUR_GLOBAL_2 2 2021-09-03
```

## mapillary_to_gpx.pl

Extracts Mapillary (API v4) image coordinates and creates a GPX out of them.
Can pass sequence or image IDs (one per sequence). In case of image IDs, their sequences will be looked up and all images from those sequences will be included.

Exmple usage:

```
token='MLY|YOUR|TOKEN'; perl mapillary_to_gpx.pl --image 5652368314832935,5496261470483015,567554981851978,1352688202152043,817276516001059,893732341631081,1833835560326099,670881348042382 --token $token --tzoffset 2 --debug > reezekne2.gpx
```
