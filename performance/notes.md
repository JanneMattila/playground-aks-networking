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

```

```

## Kubenet

```

```

## Azure CNI

```

```