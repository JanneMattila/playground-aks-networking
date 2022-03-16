# Notes

Perf testing is always tricky. Here are some
numbers with *very* **very** limited testing.
Your mileage *will* vary.

## Summary

*Summary from perf tests below:*

| Scenario                | iperf3 (Gbps) | ntttcp (Gbps) | qperf (us) | sockperf (us) |
| ----------------------- | ------------- | ------------- | ---------- | ------------- |
| Azure CNI (single node) | 25.7          | 98.39         | 16.9       | 16.791        |
| Azure CNI (AZ1 - AZ1)   | 11.8          | 11.82         | 38.8       | 37.645        |
| Azure CNI (AZ1 - AZ2)   | 11.8          | 11.82         | 60.5       | 60.563        |
| Azure CNI (AZ2 - AZ3)   | 8.25          | 11.91         | 718        | 708.390       |
| Azure CNI (AZ1 - AZ3)   | 7.91          | 11.87         | 699        | 698.945       |

Tested with [Standard_D8ds_v4](https://docs.microsoft.com/en-us/azure/virtual-machines/ddv4-ddsv4-series#ddsv4-series)
which has expected network bandwidth `4000 Mbps` => `4 Gbps`.

Tested region is `West Europe`.

## Azure CNI

### Inside single node

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.58, port 5201
[  5] local 10.2.0.72 port 37944 connected to 10.2.0.58 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  2.98 GBytes  25.6 Gbits/sec    0   1.38 MBytes       (omitted)
[  5]   1.00-2.00   sec  2.92 GBytes  25.1 Gbits/sec    0   1.45 MBytes       (omitted)
[  5]   0.00-1.00   sec  3.01 GBytes  25.9 Gbits/sec    0   1.45 MBytes       
[  5]   1.00-2.00   sec  2.94 GBytes  25.3 Gbits/sec    0   1.45 MBytes       
[  5]   2.00-3.00   sec  2.89 GBytes  24.9 Gbits/sec    0   1.52 MBytes       
[  5]   3.00-4.00   sec  2.93 GBytes  25.2 Gbits/sec    0   1.52 MBytes       
[  5]   4.00-5.00   sec  3.04 GBytes  26.1 Gbits/sec    0   1.52 MBytes       
[  5]   5.00-6.00   sec  3.06 GBytes  26.3 Gbits/sec  542   1.64 MBytes       
[  5]   6.00-7.00   sec  2.98 GBytes  25.6 Gbits/sec    0   1.64 MBytes       
[  5]   7.00-8.00   sec  3.01 GBytes  25.8 Gbits/sec    0   1.94 MBytes       
[  5]   8.00-9.00   sec  3.04 GBytes  26.1 Gbits/sec    0   1.94 MBytes       
[  5]   9.00-10.00  sec  3.02 GBytes  26.0 Gbits/sec    0   1.94 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  29.9 GBytes  25.7 Gbits/sec  542             sender
[  5]   0.00-10.00  sec  29.9 GBytes  25.7 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
17:17:07 INFO: Test cycle time negotiated is: 60 seconds
17:17:07 INFO: 64 threads created
17:17:07 INFO: 64 connections created in 19898 microseconds
17:17:07 INFO: Network activity progressing...
17:17:09 INFO: Test warmup completed.
17:17:20 INFO: Test run completed.
17:17:20 INFO: Test cooldown is in progress...
17:18:07 INFO: Test cycle finished.
17:18:07 INFO: receiver exited from current test
17:18:07 INFO: 64 connections tested
17:18:07 INFO: #####  Totals:  #####
17:18:07 INFO: test duration    :10.80 seconds
17:18:07 INFO: total bytes      :132878434304
17:18:07 INFO:   throughput     :98.39Gbps
17:18:07 INFO:   retrans segs   :7079
17:18:07 INFO: cpu cores        :8
17:18:07 INFO:   cpu speed      :2593.903MHz
17:18:07 INFO:   user           :2.57%
17:18:07 INFO:   system         :78.00%
17:18:07 INFO:   idle           :0.05%
17:18:07 INFO:   iowait         :0.00%
17:18:07 INFO:   softirq        :19.38%
17:18:07 INFO:   cycles/byte    :1.69
17:18:07 INFO: cpu busy (all)   :461.15%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     2.82 GB/sec
    msg_rate    =     43.1 K/sec
    send_bytes  =     28.2 GB
    send_msgs   =  430,972 
    recv_bytes  =     28.2 GB
    recv_msgs   =  430,972 
tcp_lat:
    latency         =     16.9 us
    msg_rate        =       59 K/sec
    loc_send_bytes  =      295 KB
    loc_recv_bytes  =      295 KB
    loc_send_msgs   =  295,150 
    loc_recv_msgs   =  295,149 
    rem_send_bytes  =      295 KB
    rem_recv_bytes  =      295 KB
    rem_send_msgs   =  295,149 
    rem_recv_msgs   =  295,150 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.58       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=296842; ReceivedMessages=296841
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=283507; ReceivedMessages=283507
sockperf: ====> avg-latency=16.791 (std-dev=3.064, mean-ad=0.949, median-ad=0.660, siqr=0.446, cv=0.182, std-error=0.006, 99.0% ci=[16.776, 16.806])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 16.791 usec
sockperf: Total 283507 observations; each percentile contains 2835.07 observations
sockperf: ---> <MAX> observation = 1051.690
sockperf: ---> percentile 99.999 =  271.066
sockperf: ---> percentile 99.990 =   71.764
sockperf: ---> percentile 99.900 =   34.491
sockperf: ---> percentile 99.000 =   24.549
sockperf: ---> percentile 90.000 =   17.920
sockperf: ---> percentile 75.000 =   16.917
sockperf: ---> percentile 50.000 =   16.493
sockperf: ---> percentile 25.000 =   16.023
sockperf: ---> <MIN> observation =   10.847
```

### AZ1 - AZ1

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.21, port 5201
[  5] local 10.2.0.160 port 46874 connected to 10.2.0.21 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.38 GBytes  11.8 Gbits/sec  5151   1.08 MBytes       (omitted)
[  5]   1.00-2.00   sec  1.38 GBytes  11.9 Gbits/sec  2304    939 KBytes       (omitted)
[  5]   0.00-1.00   sec  1.38 GBytes  11.9 Gbits/sec  2758    520 KBytes       
[  5]   1.00-2.00   sec  1.38 GBytes  11.9 Gbits/sec  3527   1.11 MBytes       
[  5]   2.00-3.00   sec  1.38 GBytes  11.9 Gbits/sec  1833    647 KBytes       
[  5]   3.00-4.00   sec  1.38 GBytes  11.8 Gbits/sec  2696    665 KBytes       
[  5]   4.00-5.00   sec  1.37 GBytes  11.7 Gbits/sec  1706    942 KBytes       
[  5]   5.00-6.00   sec  1.38 GBytes  11.9 Gbits/sec  2507    783 KBytes       
[  5]   6.00-7.00   sec  1.37 GBytes  11.7 Gbits/sec  1683    773 KBytes       
[  5]   7.00-8.00   sec  1.39 GBytes  11.9 Gbits/sec  1932   1.27 MBytes       
[  5]   8.00-9.00   sec  1.36 GBytes  11.7 Gbits/sec  3053    493 KBytes       
[  5]   9.00-10.00  sec  1.38 GBytes  11.9 Gbits/sec  2398    514 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.8 GBytes  11.8 Gbits/sec  24093             sender
[  5]   0.00-10.00  sec  13.8 GBytes  11.8 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
16:48:34 INFO: Test cycle time negotiated is: 60 seconds
16:48:34 INFO: 64 threads created
16:48:34 INFO: 64 connections created in 25423 microseconds
16:48:34 INFO: Network activity progressing...
16:48:36 INFO: Test warmup completed.
16:48:47 INFO: Test run completed.
16:48:47 INFO: Test cooldown is in progress...
16:49:34 INFO: Test cycle finished.
16:49:34 INFO: receiver exited from current test
16:49:34 INFO: 64 connections tested
16:49:34 INFO: #####  Totals:  #####
16:49:34 INFO: test duration    :10.28 seconds
16:49:34 INFO: total bytes      :15189147648
16:49:34 INFO:   throughput     :11.82Gbps
16:49:34 INFO:   retrans segs   :91360
16:49:34 INFO: cpu cores        :8
16:49:34 INFO:   cpu speed      :2593.907MHz
16:49:34 INFO:   user           :0.85%
16:49:34 INFO:   system         :7.61%
16:49:34 INFO:   idle           :85.23%
16:49:34 INFO:   iowait         :0.01%
16:49:34 INFO:   softirq        :6.29%
16:49:34 INFO:   cycles/byte    :2.07
16:49:34 INFO: cpu busy (all)   :58.32%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.44 GB/sec
    msg_rate    =       22 K/sec
    send_bytes  =     14.4 GB
    send_msgs   =  219,958 
    recv_bytes  =     14.4 GB
    recv_msgs   =  219,910 
tcp_lat:
    latency         =     38.8 us
    msg_rate        =     25.7 K/sec
    loc_send_bytes  =      129 KB
    loc_recv_bytes  =      129 KB
    loc_send_msgs   =  128,726 
    loc_recv_msgs   =  128,725 
    rem_send_bytes  =      129 KB
    rem_recv_bytes  =      129 KB
    rem_send_msgs   =  128,726 
    rem_recv_msgs   =  128,726 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.21       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=132365; ReceivedMessages=132364
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=126665; ReceivedMessages=126665
sockperf: ====> avg-latency=37.645 (std-dev=17.405, mean-ad=7.149, median-ad=1.418, siqr=1.372, cv=0.462, std-error=0.049, 99.0% ci=[37.519, 37.771])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 37.645 usec
sockperf: Total 126665 observations; each percentile contains 1266.65 observations
sockperf: ---> <MAX> observation = 3066.221
sockperf: ---> percentile 99.999 = 1325.140
sockperf: ---> percentile 99.990 =  697.360
sockperf: ---> percentile 99.900 =  141.809
sockperf: ---> percentile 99.000 =   78.568
sockperf: ---> percentile 90.000 =   55.034
sockperf: ---> percentile 75.000 =   35.422
sockperf: ---> percentile 50.000 =   33.408
sockperf: ---> percentile 25.000 =   32.677
sockperf: ---> <MIN> observation =   25.581
```

### AZ1 - AZ2

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.21, port 5201
[  5] local 10.2.0.58 port 48332 connected to 10.2.0.21 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.38 GBytes  11.9 Gbits/sec  4240   1.16 MBytes       (omitted)
[  5]   1.00-2.00   sec  1.39 GBytes  11.9 Gbits/sec  1731    860 KBytes       (omitted)
[  5]   0.00-1.00   sec  1.38 GBytes  11.9 Gbits/sec  1786   1.04 MBytes       
[  5]   1.00-2.00   sec  1.38 GBytes  11.9 Gbits/sec  1114   1.12 MBytes       
[  5]   2.00-3.00   sec  1.38 GBytes  11.9 Gbits/sec  1529    806 KBytes       
[  5]   3.00-4.00   sec  1.38 GBytes  11.9 Gbits/sec  2025    843 KBytes       
[  5]   4.00-5.00   sec  1.36 GBytes  11.7 Gbits/sec  568    903 KBytes       
[  5]   5.00-6.00   sec  1.38 GBytes  11.9 Gbits/sec  940    827 KBytes       
[  5]   6.00-7.00   sec  1.38 GBytes  11.9 Gbits/sec  1416    497 KBytes       
[  5]   7.00-8.00   sec  1.38 GBytes  11.9 Gbits/sec  797   1.08 MBytes       
[  5]   8.00-9.00   sec  1.38 GBytes  11.9 Gbits/sec  1341   1.06 MBytes       
[  5]   9.00-10.00  sec  1.36 GBytes  11.7 Gbits/sec  1403   1.08 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.8 GBytes  11.8 Gbits/sec  12919             sender
[  5]   0.00-10.00  sec  13.8 GBytes  11.8 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
16:52:21 INFO: Test cycle time negotiated is: 60 seconds
16:52:21 INFO: 64 threads created
16:52:21 INFO: 64 connections created in 23328 microseconds
16:52:21 INFO: Network activity progressing...
16:52:23 INFO: Test warmup completed.
16:52:33 INFO: Test run completed.
16:52:33 INFO: Test cooldown is in progress...
16:53:21 INFO: Test cycle finished.
16:53:21 INFO: receiver exited from current test
16:53:21 INFO: 64 connections tested
16:53:21 INFO: #####  Totals:  #####
16:53:21 INFO: test duration    :10.34 seconds
16:53:21 INFO: total bytes      :15270543360
16:53:21 INFO:   throughput     :11.82Gbps
16:53:21 INFO:   retrans segs   :98227
16:53:21 INFO: cpu cores        :8
16:53:21 INFO:   cpu speed      :2593.903MHz
16:53:21 INFO:   user           :0.92%
16:53:21 INFO:   system         :7.93%
16:53:21 INFO:   idle           :84.47%
16:53:21 INFO:   iowait         :0.01%
16:53:21 INFO:   softirq        :6.67%
16:53:21 INFO:   cycles/byte    :2.18
16:53:21 INFO: cpu busy (all)   :61.61%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.47 GB/sec
    msg_rate    =     22.4 K/sec
    send_bytes  =     14.7 GB
    send_msgs   =  224,605 
    recv_bytes  =     14.7 GB
    recv_msgs   =  224,551 
tcp_lat:
    latency         =    60.5 us
    msg_rate        =    16.5 K/sec
    loc_send_bytes  =    82.6 KB
    loc_recv_bytes  =    82.6 KB
    loc_send_msgs   =  82,628 
    loc_recv_msgs   =  82,627 
    rem_send_bytes  =    82.6 KB
    rem_recv_bytes  =    82.6 KB
    rem_send_msgs   =  82,626 
    rem_recv_msgs   =  82,627 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.21       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=83039; ReceivedMessages=83038
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=78739; ReceivedMessages=78739
sockperf: ====> avg-latency=60.563 (std-dev=24.021, mean-ad=11.365, median-ad=3.939, siqr=10.973, cv=0.397, std-error=0.086, 99.0% ci=[60.342, 60.784])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 60.563 usec
sockperf: Total 78739 observations; each percentile contains 787.39 observations
sockperf: ---> <MAX> observation = 4612.731
sockperf: ---> percentile 99.999 = 1284.202
sockperf: ---> percentile 99.990 =  701.971
sockperf: ---> percentile 99.900 =  233.266
sockperf: ---> percentile 99.000 =   91.646
sockperf: ---> percentile 90.000 =   76.204
sockperf: ---> percentile 75.000 =   72.830
sockperf: ---> percentile 50.000 =   52.745
sockperf: ---> percentile 25.000 =   50.883
sockperf: ---> <MIN> observation =   42.910
```

### AZ2 - AZ3

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.58, port 5201
[  5] local 10.2.0.141 port 41472 connected to 10.2.0.58 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.02 GBytes  8.74 Gbits/sec  776   1.50 MBytes       (omitted)
[  5]   1.00-2.00   sec  1.01 GBytes  8.65 Gbits/sec   25   1.53 MBytes       (omitted)
[  5]   0.00-1.00   sec  1.02 GBytes  8.80 Gbits/sec   46   1.62 MBytes       
[  5]   1.00-2.00   sec  1.02 GBytes  8.73 Gbits/sec  146   1.20 MBytes       
[  5]   2.00-3.00   sec   916 MBytes  7.69 Gbits/sec   46   1.20 MBytes       
[  5]   3.00-4.00   sec   921 MBytes  7.73 Gbits/sec   27   1.24 MBytes       
[  5]   4.00-5.00   sec   972 MBytes  8.16 Gbits/sec   18   1.29 MBytes       
[  5]   5.00-6.00   sec   992 MBytes  8.32 Gbits/sec  106   1.27 MBytes       
[  5]   6.00-7.00   sec   955 MBytes  8.01 Gbits/sec   12   1.32 MBytes       
[  5]   7.00-8.00   sec   988 MBytes  8.28 Gbits/sec   22   1.34 MBytes       
[  5]   8.00-9.00   sec  1.05 GBytes  9.01 Gbits/sec   29   1.36 MBytes       
[  5]   9.00-10.00  sec   929 MBytes  7.79 Gbits/sec   43   1.30 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  9.61 GBytes  8.25 Gbits/sec  495             sender
[  5]   0.00-10.00  sec  9.61 GBytes  8.25 Gbits/sec                  receiver
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
17:08:21 INFO: Test cycle time negotiated is: 60 seconds
17:08:21 INFO: 64 threads created
17:08:21 INFO: 64 connections created in 30504 microseconds
17:08:21 INFO: Network activity progressing...
17:08:23 INFO: Test warmup completed.
17:08:34 INFO: Test run completed.
17:08:34 INFO: Test cooldown is in progress...
17:09:21 INFO: Test cycle finished.
17:09:21 INFO: receiver exited from current test
17:09:21 INFO: 64 connections tested
17:09:21 INFO: #####  Totals:  #####
17:09:21 INFO: test duration    :10.30 seconds
17:09:21 INFO: total bytes      :15331753984
17:09:21 INFO:   throughput     :11.91Gbps
17:09:21 INFO:   retrans segs   :23632
17:09:21 INFO: cpu cores        :8
17:09:21 INFO:   cpu speed      :2593.907MHz
17:09:21 INFO:   user           :0.95%
17:09:21 INFO:   system         :7.36%
17:09:21 INFO:   idle           :84.81%
17:09:21 INFO:   iowait         :0.00%
17:09:21 INFO:   softirq        :6.88%
17:09:21 INFO:   cycles/byte    :2.12
17:09:21 INFO: cpu busy (all)   :58.11%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =      993 MB/sec
    msg_rate    =     15.2 K/sec
    send_bytes  =      9.9 GB
    send_msgs   =  151,615 
    recv_bytes  =      9.9 GB
    recv_msgs   =  151,564 
tcp_lat:
    latency         =    718 us
    msg_rate        =   1.39 K/sec
    loc_send_bytes  =   6.96 KB
    loc_recv_bytes  =   6.96 KB
    loc_send_msgs   =  6,963 
    loc_recv_msgs   =  6,962 
    rem_send_bytes  =   6.96 KB
    rem_recv_bytes  =   6.96 KB
    rem_send_msgs   =  6,962 
    rem_recv_msgs   =  6,962 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.58       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=7049; ReceivedMessages=7048
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.549 sec; SentMessages=6738; ReceivedMessages=6738
sockperf: ====> avg-latency=708.390 (std-dev=54.558, mean-ad=42.583, median-ad=53.064, siqr=35.740, cv=0.077, std-error=0.665, 99.0% ci=[706.678, 710.102])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 708.390 usec
sockperf: Total 6738 observations; each percentile contains 67.38 observations
sockperf: ---> <MAX> observation = 1149.838
sockperf: ---> percentile 99.999 = 1149.838
sockperf: ---> percentile 99.990 = 1123.308
sockperf: ---> percentile 99.900 =  861.365
sockperf: ---> percentile 99.000 =  819.736
sockperf: ---> percentile 90.000 =  775.819
sockperf: ---> percentile 75.000 =  746.987
sockperf: ---> percentile 50.000 =  711.131
sockperf: ---> percentile 25.000 =  675.506
sockperf: ---> <MIN> observation =  560.656
```

### AZ1 - AZ3

```
# iperf3 -c $ip -b 0 -O 2 -p 5522
Connecting to host 10.2.0.21, port 5522
[  5] local 10.2.0.141 port 40680 connected to 10.2.0.21 port 5522
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   770 MBytes  6.45 Gbits/sec   30   1.30 MBytes       (omitted)
[  5]   1.00-2.00   sec   895 MBytes  7.51 Gbits/sec  116    984 KBytes       (omitted)
[  5]   0.00-1.00   sec   865 MBytes  7.26 Gbits/sec    0   1.48 MBytes       
[  5]   1.00-2.00   sec   996 MBytes  8.36 Gbits/sec   86   1.44 MBytes       
[  5]   2.00-3.00   sec   991 MBytes  8.32 Gbits/sec   99   1.40 MBytes       
[  5]   3.00-4.00   sec  1005 MBytes  8.43 Gbits/sec   40   1.35 MBytes       
[  5]   4.00-5.00   sec   984 MBytes  8.26 Gbits/sec   60   1.31 MBytes       
[  5]   5.00-6.00   sec  1.01 GBytes  8.67 Gbits/sec   24   1.31 MBytes       
[  5]   6.00-7.00   sec   920 MBytes  7.72 Gbits/sec   85   1.26 MBytes       
[  5]   7.00-8.00   sec   916 MBytes  7.69 Gbits/sec   69   1.22 MBytes       
[  5]   8.00-9.00   sec   808 MBytes  6.77 Gbits/sec   74   1.27 MBytes       
[  5]   9.00-10.00  sec   909 MBytes  7.62 Gbits/sec   79   1.23 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  9.21 GBytes  7.91 Gbits/sec  616             sender
[  5]   0.00-10.00  sec  9.21 GBytes  7.91 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
16:59:25 INFO: Test cycle time negotiated is: 60 seconds
16:59:25 INFO: 64 threads created
16:59:25 INFO: 64 connections created in 26163 microseconds
16:59:25 INFO: Network activity progressing...
16:59:27 INFO: Test warmup completed.
16:59:37 INFO: Test run completed.
16:59:37 INFO: Test cooldown is in progress...
17:00:25 INFO: Test cycle finished.
17:00:25 INFO: receiver exited from current test
17:00:25 INFO: 64 connections tested
17:00:25 INFO: #####  Totals:  #####
17:00:25 INFO: test duration    :10.32 seconds
17:00:25 INFO: total bytes      :15314321408
17:00:25 INFO:   throughput     :11.87Gbps
17:00:25 INFO:   retrans segs   :47780
17:00:25 INFO: cpu cores        :8
17:00:25 INFO:   cpu speed      :2593.907MHz
17:00:25 INFO:   user           :0.73%
17:00:25 INFO:   system         :7.42%
17:00:25 INFO:   idle           :84.97%
17:00:25 INFO:   iowait         :0.00%
17:00:25 INFO:   softirq        :6.88%
17:00:25 INFO:   cycles/byte    :2.10
17:00:25 INFO: cpu busy (all)   :58.48%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =      918 MB/sec
    msg_rate    =       14 K/sec
    send_bytes  =     9.19 GB
    send_msgs   =  140,185 
    recv_bytes  =     9.18 GB
    recv_msgs   =  140,124 
tcp_lat:
    latency         =    699 us
    msg_rate        =   1.43 K/sec
    loc_send_bytes  =   7.16 KB
    loc_recv_bytes  =   7.16 KB
    loc_send_msgs   =  7,159 
    loc_recv_msgs   =  7,158 
    rem_send_bytes  =   7.16 KB
    rem_recv_bytes  =   7.16 KB
    rem_send_msgs   =  7,158 
    rem_recv_msgs   =  7,158 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.21       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.001 sec; Warm up time=400 msec; SentMessages=7153; ReceivedMessages=7152
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=6829; ReceivedMessages=6829
sockperf: ====> avg-latency=698.945 (std-dev=49.453, mean-ad=36.385, median-ad=45.198, siqr=30.430, cv=0.071, std-error=0.598, 99.0% ci=[697.404, 700.486])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 698.945 usec
sockperf: Total 6829 observations; each percentile contains 68.29 observations
sockperf: ---> <MAX> observation = 1862.908
sockperf: ---> percentile 99.999 = 1862.908
sockperf: ---> percentile 99.990 = 1281.876
sockperf: ---> percentile 99.900 =  894.177
sockperf: ---> percentile 99.000 =  798.420
sockperf: ---> percentile 90.000 =  753.400
sockperf: ---> percentile 75.000 =  730.096
sockperf: ---> percentile 50.000 =  700.618
sockperf: ---> percentile 25.000 =  669.235
sockperf: ---> <MIN> observation =  573.378
```
