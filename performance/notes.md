# Notes

Perf testing is always tricky. Here are some
numbers with *very* **very** limited testing.
Your mileage *will* vary.

## Local laptop

Testing under Surface Book 3 and using WSL.

```
# iperf3 -c 127.0.0.1
Connecting to host 127.0.0.1, port 5201
[  5] local 127.0.0.1 port 35686 connected to 127.0.0.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  6.65 GBytes  57.1 Gbits/sec    4   1.37 MBytes
[  5]   1.00-2.00   sec  7.08 GBytes  60.8 Gbits/sec    0   1.37 MBytes
[  5]   2.00-3.00   sec  7.35 GBytes  63.1 Gbits/sec    0   1.56 MBytes
[  5]   3.00-4.00   sec  7.38 GBytes  63.4 Gbits/sec    0   1.56 MBytes
[  5]   4.00-5.00   sec  7.37 GBytes  63.3 Gbits/sec    0   1.56 MBytes
[  5]   5.00-6.00   sec  6.92 GBytes  59.5 Gbits/sec    0   1.75 MBytes
[  5]   6.00-7.00   sec  6.68 GBytes  57.4 Gbits/sec    0   1.87 MBytes
[  5]   7.00-8.00   sec  6.95 GBytes  59.7 Gbits/sec    0   1.87 MBytes
[  5]   8.00-9.00   sec  6.86 GBytes  58.9 Gbits/sec    0   2.00 MBytes
[  5]   9.00-10.00  sec  7.41 GBytes  63.7 Gbits/sec    0   2.12 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  70.7 GBytes  60.7 Gbits/sec    4             sender
[  5]   0.00-10.00  sec  70.6 GBytes  60.7 Gbits/sec                  receiver

iperf Done.
```

## Docker Desktop

Testing under Surface Book 3 with Docker Desktop.

```
/app # iperf3 -c 10.1.0.48
Connecting to host 10.1.0.48, port 5201
[  5] local 10.1.0.47 port 48318 connected to 10.1.0.48 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  5.58 GBytes  47.9 Gbits/sec  800    735 KBytes       
[  5]   1.00-2.00   sec  6.36 GBytes  54.7 Gbits/sec   95    781 KBytes       
[  5]   2.00-3.00   sec  6.26 GBytes  53.8 Gbits/sec  534    789 KBytes       
[  5]   3.00-4.00   sec  6.47 GBytes  55.6 Gbits/sec    0    789 KBytes       
[  5]   4.00-5.00   sec  6.38 GBytes  54.8 Gbits/sec  178    840 KBytes       
[  5]   5.00-6.00   sec  6.26 GBytes  53.8 Gbits/sec  269    840 KBytes       
[  5]   6.00-7.00   sec  6.24 GBytes  53.6 Gbits/sec    0    840 KBytes       
[  5]   7.00-8.00   sec  6.38 GBytes  54.8 Gbits/sec    0    841 KBytes       
[  5]   8.00-9.00   sec  6.37 GBytes  54.7 Gbits/sec    0    841 KBytes       
[  5]   9.00-10.00  sec  6.22 GBytes  53.5 Gbits/sec    0    843 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  62.5 GBytes  53.7 Gbits/sec  1876             sender
[  5]   0.00-10.00  sec  62.5 GBytes  53.7 Gbits/sec                  receiver

iperf Done.
```

## Kubenet

```
# To be added
```

## Azure CNI

Inside single node:

```
/app # iperf3 -c 10.2.0.30
Connecting to host 10.2.0.30, port 5201
[  5] local 10.2.0.33 port 54218 connected to 10.2.0.30 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  2.93 GBytes  25.2 Gbits/sec    0    386 KBytes       
[  5]   1.00-2.00   sec  2.94 GBytes  25.3 Gbits/sec    0    455 KBytes       
[  5]   2.00-3.00   sec  2.99 GBytes  25.7 Gbits/sec    0    455 KBytes       
[  5]   3.00-4.00   sec  2.94 GBytes  25.2 Gbits/sec    0   1.04 MBytes       
[  5]   4.00-5.00   sec  3.00 GBytes  25.7 Gbits/sec    0   1.04 MBytes       
[  5]   5.00-6.00   sec  2.99 GBytes  25.7 Gbits/sec    0   1.15 MBytes       
[  5]   6.00-7.00   sec  2.98 GBytes  25.6 Gbits/sec    0   1.15 MBytes       
[  5]   7.00-8.00   sec  3.00 GBytes  25.7 Gbits/sec    0   1.40 MBytes       
[  5]   8.00-9.00   sec  2.96 GBytes  25.4 Gbits/sec    0   1.40 MBytes       
[  5]   9.00-10.00  sec  2.98 GBytes  25.6 Gbits/sec    0   1.62 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  29.7 GBytes  25.5 Gbits/sec    0             sender
[  5]   0.00-10.00  sec  29.7 GBytes  25.5 Gbits/sec                  receiver

iperf Done.
```

Two nodes (inside same Availability zone):

```
/app # iperf3 -c 10.2.0.20
Connecting to host 10.2.0.20, port 5201
[  5] local 10.2.0.100 port 41214 connected to 10.2.0.20 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.38 GBytes  11.9 Gbits/sec  2634    827 KBytes       
[  5]   1.00-2.00   sec  1.37 GBytes  11.8 Gbits/sec  1537    949 KBytes       
[  5]   2.00-3.00   sec  1.34 GBytes  11.5 Gbits/sec  1518   1.10 MBytes       
[  5]   3.00-4.00   sec  1.36 GBytes  11.7 Gbits/sec  1587   1.10 MBytes       
[  5]   4.00-5.00   sec  1.37 GBytes  11.8 Gbits/sec  2141    665 KBytes       
[  5]   5.00-6.00   sec  1.38 GBytes  11.9 Gbits/sec  1539    821 KBytes       
[  5]   6.00-7.00   sec  1.37 GBytes  11.8 Gbits/sec  1736    518 KBytes       
[  5]   7.00-8.00   sec  1.38 GBytes  11.9 Gbits/sec  1322    584 KBytes       
[  5]   8.00-9.00   sec  1.38 GBytes  11.9 Gbits/sec  906    579 KBytes       
[  5]   9.00-10.00  sec  1.36 GBytes  11.7 Gbits/sec  874    783 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.7 GBytes  11.8 Gbits/sec  15794             sender
[  5]   0.00-10.00  sec  13.7 GBytes  11.8 Gbits/sec                  receiver

iperf Done.
```
