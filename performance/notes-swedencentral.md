# Notes

Perf testing is always tricky. Here are some
numbers with *very* **very** limited testing.
Your mileage *will* vary.

## Summary

*Summary from perf tests below:*

| Scenario                | iperf3 (Gbps) | ntttcp (Gbps) | qperf (us) | sockperf (us) |
| ----------------------- | ------------- | ------------- | ---------- | ------------- |
| Azure CNI (single node) | 25.9          | 94.89         | 17.7       | 17.293        |
| Azure CNI (AZ1 - AZ1)   | 2.51          | 10.62         | 176        | 178.094       |
| Azure CNI (AZ1 - AZ2)   | 2.47          | 9.39          | 436        | 379.227       |
| Azure CNI (AZ2 - AZ3)   | 2.48          | 10.51         | 587        | 687.607       |
| Azure CNI (AZ1 - AZ3)   | 2.62          | 8.29          | 478        | 433.464       |

Tested with [Standard_D8ds_v4](https://docs.microsoft.com/en-us/azure/virtual-machines/ddv4-ddsv4-series#ddsv4-series)
which has expected network bandwidth `4000 Mbps` => `4 Gbps`.

Tested region is `Sweden Central`.

## Azure CNI

### Inside single node

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.119, port 5201
[  5] local 10.2.0.126 port 34710 connected to 10.2.0.119 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  2.70 GBytes  23.2 Gbits/sec    0   4.23 MBytes       (omitted)
[  5]   1.00-1.00   sec  3.06 GBytes  13.1 Gbits/sec    0   4.23 MBytes       
[  5]   1.00-2.00   sec  3.02 GBytes  25.9 Gbits/sec    0   4.23 MBytes       
[  5]   2.00-3.00   sec  3.01 GBytes  25.9 Gbits/sec    0   4.23 MBytes       
[  5]   3.00-4.00   sec  3.01 GBytes  25.9 Gbits/sec  1445   1.45 MBytes       
[  5]   4.00-5.00   sec  3.03 GBytes  26.1 Gbits/sec    0   1.45 MBytes       
[  5]   5.00-6.00   sec  3.09 GBytes  26.5 Gbits/sec    0   1.45 MBytes       
[  5]   6.00-7.00   sec  3.01 GBytes  25.8 Gbits/sec    0   1.80 MBytes       
[  5]   7.00-8.00   sec  2.99 GBytes  25.7 Gbits/sec    0   1.80 MBytes       
[  5]   8.00-9.00   sec  2.98 GBytes  25.6 Gbits/sec    0   1.80 MBytes       
[  5]   9.00-10.00  sec  2.94 GBytes  25.3 Gbits/sec    0   1.80 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  30.1 GBytes  25.9 Gbits/sec  1445             sender
[  5]   0.00-10.00  sec  30.1 GBytes  25.9 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
13:19:26 INFO: Test cycle time negotiated is: 60 seconds
13:19:26 INFO: 64 threads created
13:19:26 INFO: 64 connections created in 14830 microseconds
13:19:26 INFO: Network activity progressing...
13:19:28 INFO: Test warmup completed.
13:19:39 INFO: Test run completed.
13:19:39 INFO: Test cooldown is in progress...
13:20:26 INFO: Test cycle finished.
13:20:26 INFO: receiver exited from current test
13:20:26 INFO: 64 connections tested
13:20:26 INFO: #####  Totals:  #####
13:20:26 INFO: test duration    :11.28 seconds
13:20:26 INFO: total bytes      :133812977664
13:20:26 INFO:   throughput     :94.89Gbps
13:20:26 INFO:   retrans segs   :11167
13:20:26 INFO: cpu cores        :8
13:20:26 INFO:   cpu speed      :2593.907MHz
13:20:26 INFO:   user           :2.95%
13:20:26 INFO:   system         :76.56%
13:20:26 INFO:   idle           :0.14%
13:20:26 INFO:   iowait         :0.00%
13:20:26 INFO:   softirq        :20.34%
13:20:26 INFO:   cycles/byte    :1.75
13:20:26 INFO: cpu busy (all)   :429.93%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     2.66 GB/sec
    msg_rate    =     40.5 K/sec
    send_bytes  =     26.6 GB
    send_msgs   =  405,405 
    recv_bytes  =     26.6 GB
    recv_msgs   =  405,379 
tcp_lat:
    latency         =     17.7 us
    msg_rate        =     56.5 K/sec
    loc_send_bytes  =      283 KB
    loc_recv_bytes  =      283 KB
    loc_send_msgs   =  282,583 
    loc_recv_msgs   =  282,582 
    rem_send_bytes  =      283 KB
    rem_recv_bytes  =      283 KB
    rem_send_msgs   =  282,582 
    rem_recv_msgs   =  282,582 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.119      PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=288306; ReceivedMessages=288305
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=275317; ReceivedMessages=275317
sockperf: ====> avg-latency=17.293 (std-dev=4.713, mean-ad=0.872, median-ad=0.678, siqr=0.467, cv=0.273, std-error=0.009, 99.0% ci=[17.270, 17.316])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 17.293 usec
sockperf: Total 275317 observations; each percentile contains 2753.17 observations
sockperf: ---> <MAX> observation = 1724.017
sockperf: ---> percentile 99.999 =  285.085
sockperf: ---> percentile 99.990 =   78.455
sockperf: ---> percentile 99.900 =   38.033
sockperf: ---> percentile 99.000 =   23.459
sockperf: ---> percentile 90.000 =   18.369
sockperf: ---> percentile 75.000 =   17.540
sockperf: ---> percentile 50.000 =   17.022
sockperf: ---> percentile 25.000 =   16.605
sockperf: ---> <MIN> observation =   11.187
```

###### AZ1 - AZ1

```
```


```
```

```
```

```
```



### AZ1 - AZ1

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.20, port 5201
[  5] local 10.2.0.166 port 33838 connected to 10.2.0.20 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   292 MBytes  2.45 Gbits/sec  137   2.27 MBytes       (omitted)
[  5]   1.00-2.00   sec   300 MBytes  2.52 Gbits/sec    0   2.45 MBytes       (omitted)
[  5]   0.00-1.00   sec   296 MBytes  2.48 Gbits/sec    0   2.60 MBytes       
[  5]   1.00-2.00   sec   301 MBytes  2.53 Gbits/sec    0   2.72 MBytes       
[  5]   2.00-3.00   sec   298 MBytes  2.50 Gbits/sec    2   2.01 MBytes       
[  5]   3.00-4.00   sec   300 MBytes  2.52 Gbits/sec    0   2.11 MBytes       
[  5]   4.00-5.00   sec   300 MBytes  2.52 Gbits/sec    0   2.20 MBytes       
[  5]   5.00-6.00   sec   296 MBytes  2.49 Gbits/sec    0   2.29 MBytes       
[  5]   6.00-7.00   sec   300 MBytes  2.52 Gbits/sec   33   2.38 MBytes       
[  5]   7.00-8.00   sec   299 MBytes  2.51 Gbits/sec    0   2.47 MBytes       
[  5]   8.00-9.00   sec   299 MBytes  2.51 Gbits/sec    0   2.55 MBytes       
[  5]   9.00-10.00  sec   298 MBytes  2.50 Gbits/sec    0   2.63 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  2.92 GBytes  2.51 Gbits/sec   35             sender
[  5]   0.00-10.00  sec  2.92 GBytes  2.50 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
13:32:33 INFO: Test cycle time negotiated is: 60 seconds
13:32:33 INFO: 64 threads created
13:32:33 INFO: 64 connections created in 18294 microseconds
13:32:33 INFO: Network activity progressing...
13:32:35 INFO: Test warmup completed.
13:32:46 INFO: Test run completed.
13:32:46 INFO: Test cooldown is in progress...
13:33:33 INFO: Test cycle finished.
13:33:33 INFO: receiver exited from current test
13:33:34 INFO: 64 connections tested
13:33:34 INFO: #####  Totals:  #####
13:33:34 INFO: test duration    :10.29 seconds
13:33:34 INFO: total bytes      :13659275264
13:33:34 INFO:   throughput     :10.62Gbps
13:33:34 INFO:   retrans segs   :1968
13:33:34 INFO: cpu cores        :8
13:33:34 INFO:   cpu speed      :2593.906MHz
13:33:34 INFO:   user           :0.55%
13:33:34 INFO:   system         :5.71%
13:33:34 INFO:   idle           :89.89%
13:33:34 INFO:   iowait         :0.00%
13:33:34 INFO:   softirq        :3.85%
13:33:34 INFO:   cycles/byte    :1.58
13:33:34 INFO: cpu busy (all)   :50.14%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     311 MB/sec
    msg_rate    =    4.75 K/sec
    send_bytes  =    3.12 GB
    send_msgs   =  47,552 
    recv_bytes  =    3.11 GB
    recv_msgs   =  47,495 
tcp_lat:
    latency         =     176 us
    msg_rate        =    5.69 K/sec
    loc_send_bytes  =    28.4 KB
    loc_recv_bytes  =    28.4 KB
    loc_send_msgs   =  28,450 
    loc_recv_msgs   =  28,449 
    rem_send_bytes  =    28.4 KB
    rem_recv_bytes  =    28.4 KB
    rem_send_msgs   =  28,450 
    rem_recv_msgs   =  28,450 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.20       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=27945; ReceivedMessages=27944
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=26804; ReceivedMessages=26804
sockperf: ====> avg-latency=178.094 (std-dev=251.434, mean-ad=116.344, median-ad=32.314, siqr=33.198, cv=1.412, std-error=1.536, 99.0% ci=[174.138, 182.050])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 178.094 usec
sockperf: Total 26804 observations; each percentile contains 268.04 observations
sockperf: ---> <MAX> observation = 5297.046
sockperf: ---> percentile 99.999 = 5297.046
sockperf: ---> percentile 99.990 = 4104.651
sockperf: ---> percentile 99.900 = 2667.794
sockperf: ---> percentile 99.000 = 1401.261
sockperf: ---> percentile 90.000 =  285.444
sockperf: ---> percentile 75.000 =  155.082
sockperf: ---> percentile 50.000 =  106.005
sockperf: ---> percentile 25.000 =   88.684
sockperf: ---> <MIN> observation =   66.031
```

### AZ1 - AZ2

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.20, port 5201
[  5] local 10.2.0.79 port 50092 connected to 10.2.0.20 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   274 MBytes  2.30 Gbits/sec   22   2.28 MBytes       (omitted)
[  5]   1.00-2.00   sec   295 MBytes  2.47 Gbits/sec    0   2.46 MBytes       (omitted)
[  5]   0.00-1.00   sec   296 MBytes  2.48 Gbits/sec    0   2.62 MBytes       
[  5]   1.00-2.00   sec   292 MBytes  2.45 Gbits/sec    0   2.74 MBytes       
[  5]   2.00-3.00   sec   298 MBytes  2.50 Gbits/sec    0   2.84 MBytes       
[  5]   3.00-4.00   sec   294 MBytes  2.46 Gbits/sec   70   2.09 MBytes       
[  5]   4.00-5.00   sec   295 MBytes  2.47 Gbits/sec    0   2.20 MBytes       
[  5]   5.00-6.00   sec   296 MBytes  2.49 Gbits/sec    0   2.28 MBytes       
[  5]   6.00-7.00   sec   292 MBytes  2.45 Gbits/sec    0   2.35 MBytes       
[  5]   7.00-8.00   sec   292 MBytes  2.45 Gbits/sec    0   2.44 MBytes       
[  5]   8.00-9.00   sec   295 MBytes  2.47 Gbits/sec    0   2.52 MBytes       
[  5]   9.00-10.00  sec   295 MBytes  2.47 Gbits/sec    0   2.60 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  2.88 GBytes  2.47 Gbits/sec   70             sender
[  5]   0.00-10.00  sec  2.88 GBytes  2.47 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
13:01:12 INFO: Test cycle time negotiated is: 60 seconds
13:01:12 INFO: 64 threads created
13:01:12 INFO: 64 connections created in 20729 microseconds
13:01:12 INFO: Network activity progressing...
13:01:14 INFO: Test warmup completed.
13:01:24 INFO: Test run completed.
13:01:24 INFO: Test cooldown is in progress...
13:02:12 INFO: Test cycle finished.
13:02:12 INFO: receiver exited from current test
13:02:12 INFO: 64 connections tested
13:02:12 INFO: #####  Totals:  #####
13:02:12 INFO: test duration    :10.28 seconds
13:02:12 INFO: total bytes      :12065964032
13:02:12 INFO:   throughput     :9.39Gbps
13:02:12 INFO:   retrans segs   :38716
13:02:12 INFO: cpu cores        :8
13:02:12 INFO:   cpu speed      :2593.905MHz
13:02:12 INFO:   user           :0.84%
13:02:12 INFO:   system         :5.09%
13:02:12 INFO:   idle           :90.48%
13:02:12 INFO:   iowait         :0.00%
13:02:12 INFO:   softirq        :3.59%
13:02:12 INFO:   cycles/byte    :1.68
13:02:12 INFO: cpu busy (all)   :42.73%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     314 MB/sec
    msg_rate    =    4.79 K/sec
    send_bytes  =    3.14 GB
    send_msgs   =  47,931 
    recv_bytes  =    3.14 GB
    recv_msgs   =  47,874 
tcp_lat:
    latency         =     436 us
    msg_rate        =    2.29 K/sec
    loc_send_bytes  =    11.5 KB
    loc_recv_bytes  =    11.5 KB
    loc_send_msgs   =  11,464 
    loc_recv_msgs   =  11,463 
    rem_send_bytes  =    11.5 KB
    rem_recv_bytes  =    11.5 KB
    rem_send_msgs   =  11,463 
    rem_recv_msgs   =  11,463 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.20       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=13286; ReceivedMessages=13285
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=12589; ReceivedMessages=12589
sockperf: ====> avg-latency=379.227 (std-dev=304.569, mean-ad=174.733, median-ad=41.389, siqr=64.303, cv=0.803, std-error=2.715, 99.0% ci=[372.235, 386.219])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 379.227 usec
sockperf: Total 12589 observations; each percentile contains 125.89 observations
sockperf: ---> <MAX> observation = 4758.307
sockperf: ---> percentile 99.999 = 4758.307
sockperf: ---> percentile 99.990 = 4686.962
sockperf: ---> percentile 99.900 = 3165.415
sockperf: ---> percentile 99.000 = 1654.454
sockperf: ---> percentile 90.000 =  680.367
sockperf: ---> percentile 75.000 =  369.621
sockperf: ---> percentile 50.000 =  262.716
sockperf: ---> percentile 25.000 =  241.015
sockperf: ---> <MIN> observation =  217.766
```

### AZ2 - AZ3

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.121, port 5201
[  5] local 10.2.0.79 port 49988 connected to 10.2.0.121 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   299 MBytes  2.51 Gbits/sec   25   2.30 MBytes       (omitted)
[  5]   1.00-1.00   sec   299 MBytes  1.25 Gbits/sec    0   2.63 MBytes       
[  5]   1.00-2.00   sec   299 MBytes  2.51 Gbits/sec  110   1.93 MBytes       
[  5]   2.00-3.00   sec   295 MBytes  2.47 Gbits/sec    0   2.05 MBytes       
[  5]   3.00-4.00   sec   299 MBytes  2.51 Gbits/sec    0   2.14 MBytes       
[  5]   4.00-5.00   sec   299 MBytes  2.51 Gbits/sec    0   2.23 MBytes       
[  5]   5.00-6.00   sec   301 MBytes  2.53 Gbits/sec    0   2.33 MBytes       
[  5]   6.00-7.00   sec   284 MBytes  2.38 Gbits/sec    0   2.41 MBytes       
[  5]   7.00-8.00   sec   292 MBytes  2.45 Gbits/sec    0   2.50 MBytes       
[  5]   8.00-9.00   sec   291 MBytes  2.44 Gbits/sec    0   2.58 MBytes       
[  5]   9.00-10.00  sec   301 MBytes  2.53 Gbits/sec    0   2.66 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  2.89 GBytes  2.48 Gbits/sec  110             sender
[  5]   0.00-10.00  sec  2.89 GBytes  2.48 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
13:09:34 INFO: Test cycle time negotiated is: 60 seconds
13:09:34 INFO: 64 threads created
13:09:34 INFO: 64 connections created in 27041 microseconds
13:09:34 INFO: Network activity progressing...
13:09:36 INFO: Test warmup completed.
13:09:46 INFO: Test run completed.
13:09:46 INFO: Test cooldown is in progress...
13:10:34 INFO: Test cycle finished.
13:10:34 INFO: receiver exited from current test
13:10:34 INFO: 64 connections tested
13:10:34 INFO: #####  Totals:  #####
13:10:34 INFO: test duration    :10.24 seconds
13:10:34 INFO: total bytes      :13453099008
13:10:34 INFO:   throughput     :10.51Gbps
13:10:34 INFO:   retrans segs   :64147
13:10:34 INFO: cpu cores        :8
13:10:34 INFO:   cpu speed      :2593.905MHz
13:10:34 INFO:   user           :0.54%
13:10:34 INFO:   system         :5.68%
13:10:34 INFO:   idle           :90.05%
13:10:34 INFO:   iowait         :0.00%
13:10:34 INFO:   softirq        :3.73%
13:10:34 INFO:   cycles/byte    :1.57
13:10:34 INFO: cpu busy (all)   :48.09%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     253 MB/sec
    msg_rate    =    3.85 K/sec
    send_bytes  =    2.53 GB
    send_msgs   =  38,586 
    recv_bytes  =    2.53 GB
    recv_msgs   =  38,534 
tcp_lat:
    latency         =    587 us
    msg_rate        =    1.7 K/sec
    loc_send_bytes  =   8.52 KB
    loc_recv_bytes  =   8.52 KB
    loc_send_msgs   =  8,524 
    loc_recv_msgs   =  8,523 
    rem_send_bytes  =   8.52 KB
    rem_recv_bytes  =   8.52 KB
    rem_send_msgs   =  8,523 
    rem_recv_msgs   =  8,523 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.121      PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=7253; ReceivedMessages=7252
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=6943; ReceivedMessages=6943
sockperf: ====> avg-latency=687.607 (std-dev=239.956, mean-ad=170.518, median-ad=228.075, siqr=149.875, cv=0.349, std-error=2.880, 99.0% ci=[680.189, 695.025])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 687.607 usec
sockperf: Total 6943 observations; each percentile contains 69.43 observations
sockperf: ---> <MAX> observation = 3031.926
sockperf: ---> percentile 99.999 = 3031.926
sockperf: ---> percentile 99.990 = 2755.036
sockperf: ---> percentile 99.900 = 2313.222
sockperf: ---> percentile 99.000 = 1520.710
sockperf: ---> percentile 90.000 =  951.395
sockperf: ---> percentile 75.000 =  782.533
sockperf: ---> percentile 50.000 =  681.034
sockperf: ---> percentile 25.000 =  482.782
sockperf: ---> <MIN> observation =  417.305
```

### AZ1 - AZ3

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.20, port 5201
[  5] local 10.2.0.121 port 33084 connected to 10.2.0.20 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   300 MBytes  2.51 Gbits/sec   13   2.31 MBytes       (omitted)
[  5]   1.00-2.00   sec   306 MBytes  2.57 Gbits/sec    0   2.50 MBytes       (omitted)
[  5]   0.00-1.00   sec   315 MBytes  2.64 Gbits/sec    0   2.65 MBytes       
[  5]   1.00-2.00   sec   316 MBytes  2.65 Gbits/sec    0   2.77 MBytes       
[  5]   2.00-3.00   sec   315 MBytes  2.64 Gbits/sec    0   2.86 MBytes       
[  5]   3.00-4.00   sec   314 MBytes  2.63 Gbits/sec    2   2.06 MBytes       
[  5]   4.00-5.00   sec   312 MBytes  2.62 Gbits/sec    0   2.19 MBytes       
[  5]   5.00-6.00   sec   311 MBytes  2.61 Gbits/sec    0   2.28 MBytes       
[  5]   6.00-7.00   sec   308 MBytes  2.58 Gbits/sec    0   2.36 MBytes       
[  5]   7.00-8.00   sec   309 MBytes  2.59 Gbits/sec    0   2.45 MBytes       
[  5]   8.00-9.00   sec   311 MBytes  2.61 Gbits/sec    0   2.54 MBytes       
[  5]   9.00-10.00  sec   312 MBytes  2.62 Gbits/sec    0   2.62 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  3.05 GBytes  2.62 Gbits/sec    2             sender
[  5]   0.00-10.00  sec  3.05 GBytes  2.62 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
12:51:00 INFO: Test cycle time negotiated is: 60 seconds
12:51:00 INFO: 64 threads created
12:51:00 INFO: 64 connections created in 30204 microseconds
12:51:00 INFO: Network activity progressing...
12:51:02 INFO: Test warmup completed.
12:51:12 INFO: Test run completed.
12:51:12 INFO: Test cooldown is in progress...
12:52:00 INFO: Test cycle finished.
12:52:00 INFO: receiver exited from current test
12:52:00 INFO: 64 connections tested
12:52:00 INFO: #####  Totals:  #####
12:52:00 INFO: test duration    :10.25 seconds
12:52:00 INFO: total bytes      :10620239872
12:52:00 INFO:   throughput     :8.29Gbps
12:52:00 INFO:   retrans segs   :1455
12:52:00 INFO: cpu cores        :8
12:52:00 INFO:   cpu speed      :2593.907MHz
12:52:00 INFO:   user           :1.02%
12:52:00 INFO:   system         :5.04%
12:52:00 INFO:   idle           :89.95%
12:52:00 INFO:   iowait         :0.00%
12:52:00 INFO:   softirq        :4.00%
12:52:00 INFO:   cycles/byte    :2.01
12:52:00 INFO: cpu busy (all)   :39.89%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     305 MB/sec
    msg_rate    =    4.66 K/sec
    send_bytes  =    3.06 GB
    send_msgs   =  46,655 
    recv_bytes  =    3.05 GB
    recv_msgs   =  46,603 
tcp_lat:
    latency         =     478 us
    msg_rate        =    2.09 K/sec
    loc_send_bytes  =    10.5 KB
    loc_recv_bytes  =    10.5 KB
    loc_send_msgs   =  10,461 
    loc_recv_msgs   =  10,460 
    rem_send_bytes  =    10.5 KB
    rem_recv_bytes  =    10.5 KB
    rem_send_msgs   =  10,460 
    rem_recv_msgs   =  10,460 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.20       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=11515; ReceivedMessages=11514
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.551 sec; SentMessages=11015; ReceivedMessages=11015
sockperf: ====> avg-latency=433.464 (std-dev=276.818, mean-ad=151.764, median-ad=32.942, siqr=48.839, cv=0.639, std-error=2.638, 99.0% ci=[426.670, 440.258])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 433.464 usec
sockperf: Total 11015 observations; each percentile contains 110.15 observations
sockperf: ---> <MAX> observation = 5178.866
sockperf: ---> percentile 99.999 = 5178.866
sockperf: ---> percentile 99.990 = 4189.053
sockperf: ---> percentile 99.900 = 2993.003
sockperf: ---> percentile 99.000 = 1654.469
sockperf: ---> percentile 90.000 =  681.208
sockperf: ---> percentile 75.000 =  415.122
sockperf: ---> percentile 50.000 =  333.863
sockperf: ---> percentile 25.000 =  317.444
sockperf: ---> <MIN> observation =  293.978
# 
```
