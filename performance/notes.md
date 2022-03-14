# Notes

Perf testing is always tricky. Here are some
numbers with *very* **very** limited testing.
Your mileage *will* vary.

## Summary

*Summary from perf tests below:*

| Scenario                                                 | iperf3 (Gbps) | ntttcp (Gbps) | qperf (us) | sockperf (us) |
| -------------------------------------------------------- | ------------- | ------------- | ---------- | ------------- |
| Local laptop                                             | 96.4          | 101.14        | 33.9       | 56.765        |
| Docker Desktop                                           | 81.8          | 76.39         |            | 117.922       |
| Standard_D8ds_v4: VM to VM (single node)                 |               |               |            |               |
| Standard_D8ds_v4: VM to VM (two nodes inside same AZ)    |               |               |            |               |
| Standard_D8ds_v4: Kubenet (single node)                  |               |               |            |               |
| Standard_D8ds_v4: Kubenet (two nodes inside same AZ)     |               |               |            |               |
| Standard_D8ds_v4: Kubenet (two nodes different AZs)      |               |               |            |               |
| Standard_D8ds_v4: Kubenet (two nodes using PPG)          |               |               |            |               |
| Standard_D8ds_v4: Azure CNI (single node)                | 51            | 99.98         | 17.3       | 16.846        |
| Standard_D8ds_v4: Azure CNI (two nodes inside same AZ)   | 23.6          | 11.82         | 61.3       | 60.394        |
| Standard_D8ds_v4: Azure CNI (two nodes in different AZs) | 22.4          | 11.84         | 67.1       | 66.953        |
| Standard_D8ds_v4: Azure CNI (two nodes using PPG)        |               |               |            |               |

Tested with [Standard_D8ds_v4](https://docs.microsoft.com/en-us/azure/virtual-machines/ddv4-ddsv4-series#ddsv4-series)
which has expected network bandwidth `4000 Mbps` => `4 Gbps`.

PPG: Proximity Placement Group

## Local laptop

Testing under Surface Book 3 and using WSL.

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 127.0.0.1, port 5201
[  5] local 127.0.0.1 port 50578 connected to 127.0.0.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  5.42 GBytes  46.5 Gbits/sec    0   1.75 MBytes       (omitted)
[  5]   1.00-2.00   sec  5.70 GBytes  48.9 Gbits/sec    0   2.12 MBytes       (omitted)
[  5]   0.00-1.00   sec  5.27 GBytes  45.2 Gbits/sec    1   2.37 MBytes
[  5]   1.00-2.00   sec  5.80 GBytes  49.7 Gbits/sec    4   2.37 MBytes
[  5]   2.00-3.00   sec  5.97 GBytes  51.4 Gbits/sec    0   2.37 MBytes
[  5]   3.00-4.00   sec  5.76 GBytes  49.5 Gbits/sec    1   2.37 MBytes
[  5]   4.00-5.00   sec  5.85 GBytes  50.3 Gbits/sec    0   2.50 MBytes
[  5]   5.00-6.00   sec  5.84 GBytes  50.2 Gbits/sec    0   2.50 MBytes
[  5]   6.00-7.00   sec  5.21 GBytes  44.7 Gbits/sec    0   2.62 MBytes
[  5]   7.00-8.00   sec  5.80 GBytes  49.8 Gbits/sec    0   2.62 MBytes
[  5]   8.00-9.00   sec  5.45 GBytes  46.8 Gbits/sec    0   2.81 MBytes
[  5]   9.00-10.00  sec  5.85 GBytes  50.2 Gbits/sec    0   2.81 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  56.8 GBytes  48.8 Gbits/sec    6             sender
[  5]   0.00-10.00  sec  56.8 GBytes  48.8 Gbits/sec                  receiver

iperf Done.
```

```
# ./ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
21:03:55 INFO: Test cycle time negotiated is: 60 seconds
21:03:55 INFO: 64 threads created
21:03:55 INFO: 64 connections created in 10045 microseconds
21:03:55 INFO: Network activity progressing...
21:03:57 INFO: Test warmup completed.
21:04:07 INFO: Test run completed.
21:04:07 INFO: Test cooldown is in progress...
21:04:55 INFO: Test cycle finished.
21:04:55 INFO: receiver exited from current test
21:04:55 INFO: 64 connections tested
21:04:55 INFO: #####  Totals:  #####
21:04:55 INFO: test duration    :10.10 seconds
21:04:55 INFO: total bytes      :127651414016
21:04:55 INFO:   throughput     :101.14Gbps
21:04:55 INFO:   retrans segs   :24
21:04:55 INFO: cpu cores        :8
21:04:55 INFO:   cpu speed      :1497.603MHz
21:04:55 INFO:   user           :4.36%
21:04:55 INFO:   system         :81.79%
21:04:55 INFO:   idle           :0.00%
21:04:55 INFO:   iowait         :0.00%
21:04:55 INFO:   softirq        :13.85%
21:04:55 INFO:   cycles/byte    :0.95
21:04:55 INFO: cpu busy (all)   :284.05%
```

```
# qperf 127.0.0.1 -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =  8.03 GB/sec
    msg_rate    =   123 K/sec
    send_bytes  =  80.3 GB
    send_msgs   =  1.23 million
    recv_bytes  =  80.3 GB
    recv_msgs   =  1.23 million
tcp_lat:
    latency         =     33.9 us
    msg_rate        =     29.5 K/sec
    loc_send_bytes  =      148 KB
    loc_recv_bytes  =      148 KB
    loc_send_msgs   =  147,698
    loc_recv_msgs   =  147,697
    rem_send_bytes  =      148 KB
    rem_recv_bytes  =      148 KB
    rem_send_msgs   =  147,698
    rem_recv_msgs   =  147,698
```

```
# ./sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a ==
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 127.0.0.1       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.001 sec; Warm up time=400 msec; SentMessages=86807; ReceivedMessages=86806
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=83946; ReceivedMessages=83946
sockperf: ====> avg-latency=56.765 (std-dev=46.806, mean-ad=31.750, median-ad=6.224, siqr=19.027, cv=0.825, std-error=0.162, 99.0% ci=[56.349, 57.181])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 56.765 usec
sockperf: Total 83946 observations; each percentile contains 839.46 observations
sockperf: ---> <MAX> observation = 1917.502
sockperf: ---> percentile 99.999 = 1913.571
sockperf: ---> percentile 99.990 = 1779.618
sockperf: ---> percentile 99.900 =  256.018
sockperf: ---> percentile 99.000 =  172.878
sockperf: ---> percentile 90.000 =  122.436
sockperf: ---> percentile 75.000 =   69.639
sockperf: ---> percentile 50.000 =   34.698
sockperf: ---> percentile 25.000 =   31.583
sockperf: ---> <MIN> observation =    4.409
```

## Docker Desktop

Testing under Surface Book 3 with Docker Desktop.

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.1.0.54, port 5201
[  5] local 10.1.0.53 port 56852 connected to 10.1.0.54 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  4.37 GBytes  37.5 Gbits/sec    0   1.66 MBytes       (omitted)
[  5]   1.00-2.00   sec  4.92 GBytes  42.3 Gbits/sec   92   1.93 MBytes       (omitted)
[  5]   0.00-1.00   sec  4.60 GBytes  39.5 Gbits/sec    0   1.93 MBytes       
[  5]   1.00-2.00   sec  4.54 GBytes  39.0 Gbits/sec    0   1.93 MBytes       
[  5]   2.00-3.00   sec  4.78 GBytes  41.1 Gbits/sec    0   1.93 MBytes       
[  5]   3.00-4.00   sec  4.98 GBytes  42.8 Gbits/sec    2   1.93 MBytes       
[  5]   4.00-5.00   sec  5.05 GBytes  43.4 Gbits/sec    0   1.93 MBytes       
[  5]   5.00-6.00   sec  4.79 GBytes  41.2 Gbits/sec    0   1.93 MBytes       
[  5]   6.00-7.00   sec  4.60 GBytes  39.6 Gbits/sec   50   1.95 MBytes       
[  5]   7.00-8.00   sec  4.43 GBytes  38.0 Gbits/sec    0   1.96 MBytes       
[  5]   8.00-9.00   sec  4.85 GBytes  41.6 Gbits/sec   92   1.96 MBytes       
[  5]   9.00-10.00  sec  4.98 GBytes  42.8 Gbits/sec    0   1.96 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  47.6 GBytes  40.9 Gbits/sec  144             sender
[  5]   0.00-10.00  sec  47.6 GBytes  40.9 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
19:15:42 INFO: Test cycle time negotiated is: 60 seconds
19:15:42 INFO: 64 threads created
19:15:43 INFO: 64 connections created in 88621 microseconds
19:15:43 INFO: Network activity progressing...
19:15:45 INFO: Test warmup completed.
19:15:55 INFO: Test run completed.
19:15:55 INFO: Test cooldown is in progress...
19:16:43 INFO: Test cycle finished.
19:16:43 INFO: receiver exited from current test
19:16:43 INFO: 64 connections tested
19:16:43 INFO: #####  Totals:  #####
19:16:43 INFO: test duration    :10.66 seconds
19:16:43 INFO: total bytes      :101828132864
19:16:43 INFO:   throughput     :76.39Gbps
19:16:43 INFO:   retrans segs   :32579
19:16:43 INFO: cpu cores        :8
19:16:43 INFO:   cpu speed      :1497.603MHz
19:16:43 INFO:   user           :4.13%
19:16:43 INFO:   system         :65.41%
19:16:43 INFO:   idle           :8.15%
19:16:43 INFO:   iowait         :0.01%
19:16:43 INFO:   softirq        :22.30%
19:16:43 INFO:   cycles/byte    :1.15
19:16:43 INFO: cpu busy (all)   :300.74%
```

```
/app # qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     6.37 GB/sec
    msg_rate    =     97.2 K/sec
    send_bytes  =     63.7 GB
    send_msgs   =  972,131 
    recv_bytes  =     63.7 GB
    recv_msgs   =  972,130 
tcp_lat:
    latency         =       38 us
    msg_rate        =     26.3 K/sec
    loc_send_bytes  =      132 KB
    loc_recv_bytes  =      132 KB
    loc_send_msgs   =  131,723 
    loc_recv_msgs   =  131,722 
    rem_send_bytes  =      132 KB
    rem_recv_bytes  =      132 KB
    rem_send_msgs   =  131,722 
    rem_recv_msgs   =  131,722 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.1.0.54       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.001 sec; Warm up time=400 msec; SentMessages=42290; ReceivedMessages=42289
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=40410; ReceivedMessages=40410
sockperf: ====> avg-latency=117.922 (std-dev=71.789, mean-ad=29.053, median-ad=32.473, siqr=21.904, cv=0.609, std-error=0.357, 99.0% ci=[117.002, 118.842])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 117.922 usec
sockperf: Total 40410 observations; each percentile contains 404.10 observations
sockperf: ---> <MAX> observation = 7636.946
sockperf: ---> percentile 99.999 = 7636.946
sockperf: ---> percentile 99.990 = 2214.014
sockperf: ---> percentile 99.900 =  657.692
sockperf: ---> percentile 99.000 =  212.341
sockperf: ---> percentile 90.000 =  159.654
sockperf: ---> percentile 75.000 =  138.172
sockperf: ---> percentile 50.000 =  115.979
sockperf: ---> percentile 25.000 =   94.361
sockperf: ---> <MIN> observation =    8.120
```

## Virtual Machine

Inside single virtual machine:

```
# iperf3 -c localhost
Connecting to host localhost, port 5201
[  5] local 127.0.0.1 port 35080 connected to 127.0.0.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  3.53 GBytes  30.3 Gbits/sec    0   1023 KBytes
[  5]   1.00-2.00   sec  3.51 GBytes  30.1 Gbits/sec    0   1023 KBytes
[  5]   2.00-3.00   sec  3.49 GBytes  30.0 Gbits/sec    0   1023 KBytes
[  5]   3.00-4.00   sec  3.50 GBytes  30.1 Gbits/sec    0   1023 KBytes
[  5]   4.00-5.00   sec  3.52 GBytes  30.3 Gbits/sec    0   1023 KBytes
[  5]   5.00-6.00   sec  3.51 GBytes  30.1 Gbits/sec    0   1023 KBytes
[  5]   6.00-7.00   sec  3.50 GBytes  30.1 Gbits/sec    0   1023 KBytes
[  5]   7.00-8.00   sec  3.48 GBytes  29.9 Gbits/sec    0   1023 KBytes
[  5]   8.00-9.00   sec  3.42 GBytes  29.3 Gbits/sec    0   1023 KBytes
[  5]   9.00-10.00  sec  3.54 GBytes  30.4 Gbits/sec    0   1023 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  35.0 GBytes  30.1 Gbits/sec    0             sender
[  5]   0.00-10.00  sec  35.0 GBytes  30.1 Gbits/sec                  receiver

iperf Done.
```

```
# qperf localhost -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     3.52 GB/sec
    msg_rate    =     53.6 K/sec
    send_bytes  =     35.2 GB
    send_msgs   =  536,407
    recv_bytes  =     35.2 GB
    recv_msgs   =  536,407
tcp_lat:
    latency         =     14.4 us
    msg_rate        =     69.5 K/sec
    loc_send_bytes  =      347 KB
    loc_recv_bytes  =      347 KB
    loc_send_msgs   =  347,431
    loc_recv_msgs   =  347,430
    rem_send_bytes  =      347 KB
    rem_recv_bytes  =      347 KB
    rem_send_msgs   =  347,431
    rem_recv_msgs   =  347,431
```

Two virtual machines (inside same Availability zone):

```
# iperf3 -c 172.20.0.4
Connecting to host 172.20.0.4, port 5201
[  5] local 172.20.0.5 port 43914 connected to 172.20.0.4 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.40 GBytes  12.0 Gbits/sec    0   2.65 MBytes
[  5]   1.00-2.00   sec  1.38 GBytes  11.9 Gbits/sec    0   2.65 MBytes
[  5]   2.00-3.00   sec  1.39 GBytes  11.9 Gbits/sec    0   2.81 MBytes
[  5]   3.00-4.00   sec  1.38 GBytes  11.9 Gbits/sec    0   2.81 MBytes
[  5]   4.00-5.00   sec  1.38 GBytes  11.9 Gbits/sec    0   2.81 MBytes
[  5]   5.00-6.00   sec  1.39 GBytes  11.9 Gbits/sec    0   3.10 MBytes
[  5]   6.00-7.00   sec  1.38 GBytes  11.9 Gbits/sec    0   3.10 MBytes
[  5]   7.00-8.00   sec  1.39 GBytes  11.9 Gbits/sec    0   3.10 MBytes
[  5]   8.00-9.00   sec  1.38 GBytes  11.9 Gbits/sec    0   3.10 MBytes
[  5]   9.00-10.00  sec  1.38 GBytes  11.9 Gbits/sec    0   3.10 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.9 GBytes  11.9 Gbits/sec    0             sender
[  5]   0.00-10.00  sec  13.9 GBytes  11.9 Gbits/sec                  receiver

iperf Done.
```

```
# qperf 172.20.0.4 -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.49 GB/sec
    msg_rate    =     22.7 K/sec
    send_bytes  =     14.9 GB
    send_msgs   =  227,052
    recv_bytes  =     14.9 GB
    recv_msgs   =  226,996
tcp_lat:
    latency         =     28.3 us
    msg_rate        =     35.3 K/sec
    loc_send_bytes  =      177 KB
    loc_recv_bytes  =      177 KB
    loc_send_msgs   =  176,566
    loc_recv_msgs   =  176,565
    rem_send_bytes  =      177 KB
    rem_recv_bytes  =      177 KB
    rem_send_msgs   =  176,566
    rem_recv_msgs   =  176,566
```

## Kubenet

Inside single node:

```
/app # iperf3 -c $ip
Connecting to host 10.244.0.7, port 5201
[  5] local 10.244.1.7 port 33494 connected to 10.244.0.7 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.37 GBytes  11.8 Gbits/sec  2925   1.13 MBytes       
[  5]   1.00-2.00   sec  1.37 GBytes  11.8 Gbits/sec  1061   1.15 MBytes       
[  5]   2.00-3.00   sec  1.36 GBytes  11.7 Gbits/sec  493    807 KBytes       
[  5]   3.00-4.00   sec  1.34 GBytes  11.5 Gbits/sec  309    707 KBytes       
[  5]   4.00-5.00   sec  1.35 GBytes  11.6 Gbits/sec  912    984 KBytes       
[  5]   5.00-6.00   sec  1.36 GBytes  11.7 Gbits/sec  1594   1.02 MBytes       
[  5]   6.00-7.00   sec  1.35 GBytes  11.6 Gbits/sec  1020    618 KBytes       
[  5]   7.00-8.00   sec  1.36 GBytes  11.7 Gbits/sec  510    891 KBytes       
[  5]   8.00-9.00   sec  1.35 GBytes  11.6 Gbits/sec  310   1.14 MBytes       
[  5]   9.00-10.00  sec  1.38 GBytes  11.9 Gbits/sec  719    755 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.6 GBytes  11.7 Gbits/sec  9853             sender
[  5]   0.00-10.00  sec  13.6 GBytes  11.7 Gbits/sec                  receiver

iperf Done.
```

```
/app # qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.44 GB/sec
    msg_rate    =       22 K/sec
    send_bytes  =     14.4 GB
    send_msgs   =  220,240 
    recv_bytes  =     14.4 GB
    recv_msgs   =  220,192 
tcp_lat:
    latency         =     47.4 us
    msg_rate        =     21.1 K/sec
    loc_send_bytes  =      106 KB
    loc_recv_bytes  =      106 KB
    loc_send_msgs   =  105,565 
    loc_recv_msgs   =  105,564 
    rem_send_bytes  =      106 KB
    rem_recv_bytes  =      106 KB
    rem_send_msgs   =  105,564 
    rem_recv_msgs   =  105,565 
```

Two nodes (inside same Availability zone):

```
/app # iperf3 -c $ip
Connecting to host 10.244.0.7, port 5201
[  5] local 10.244.1.7 port 59032 connected to 10.244.0.7 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.38 GBytes  11.8 Gbits/sec  4816    868 KBytes       
[  5]   1.00-2.00   sec  1.37 GBytes  11.8 Gbits/sec  366   1.02 MBytes       
[  5]   2.00-3.00   sec  1.36 GBytes  11.7 Gbits/sec  618   1.04 MBytes       
[  5]   3.00-4.00   sec  1.36 GBytes  11.7 Gbits/sec  387   1.12 MBytes       
[  5]   4.00-5.00   sec  1.37 GBytes  11.8 Gbits/sec  1009    522 KBytes       
[  5]   5.00-6.00   sec  1.35 GBytes  11.6 Gbits/sec  862   1.06 MBytes       
[  5]   6.00-7.00   sec  1.36 GBytes  11.7 Gbits/sec  827    824 KBytes       
[  5]   7.00-8.00   sec  1.38 GBytes  11.9 Gbits/sec  506   1.10 MBytes       
[  5]   8.00-9.00   sec  1.34 GBytes  11.5 Gbits/sec  449   1.12 MBytes       
[  5]   9.00-10.00  sec  1.38 GBytes  11.8 Gbits/sec  1043   1.02 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.6 GBytes  11.7 Gbits/sec  10883             sender
[  5]   0.00-10.00  sec  13.6 GBytes  11.7 Gbits/sec                  receiver

iperf Done.
```

```
/app # qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.46 GB/sec
    msg_rate    =     22.2 K/sec
    send_bytes  =     14.6 GB
    send_msgs   =  222,576 
    recv_bytes  =     14.6 GB
    recv_msgs   =  222,485 
tcp_lat:
    latency         =     49.7 us
    msg_rate        =     20.1 K/sec
    loc_send_bytes  =      101 KB
    loc_recv_bytes  =      101 KB
    loc_send_msgs   =  100,555 
    loc_recv_msgs   =  100,554 
    rem_send_bytes  =      101 KB
    rem_recv_bytes  =      101 KB
    rem_send_msgs   =  100,554 
    rem_recv_msgs   =  100,554 
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

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
07:00:51 INFO: Test cycle time negotiated is: 60 seconds
07:00:51 INFO: 64 threads created
07:00:51 INFO: 64 connections created in 19058 microseconds
07:00:51 INFO: Network activity progressing...
07:00:53 INFO: Test warmup completed.
07:01:04 INFO: Test run completed.
07:01:04 INFO: Test cooldown is in progress...
07:01:51 INFO: Test cycle finished.
07:01:51 INFO: receiver exited from current test
07:01:51 INFO: 64 connections tested
07:01:51 INFO: #####  Totals:  #####
07:01:51 INFO: test duration    :10.88 seconds
07:01:51 INFO: total bytes      :135960330240
07:01:51 INFO:   throughput     :99.98Gbps
07:01:51 INFO:   retrans segs   :10696
07:01:51 INFO: cpu cores        :8
07:01:51 INFO:   cpu speed      :2593.905MHz
07:01:51 INFO:   user           :3.15%
07:01:51 INFO:   system         :75.70%
07:01:51 INFO:   idle           :0.10%
07:01:51 INFO:   iowait         :0.00%
07:01:51 INFO:   softirq        :21.05%
07:01:51 INFO:   cycles/byte    :1.66
07:01:51 INFO: cpu busy (all)   :444.24%
```

```
/app # qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     2.64 GB/sec
    msg_rate    =     40.2 K/sec
    send_bytes  =     26.4 GB
    send_msgs   =  402,243 
    recv_bytes  =     26.4 GB
    recv_msgs   =  402,243 
tcp_lat:
    latency         =     17.3 us
    msg_rate        =     57.7 K/sec
    loc_send_bytes  =      289 KB
    loc_recv_bytes  =      289 KB
    loc_send_msgs   =  288,603 
    loc_recv_msgs   =  288,602 
    rem_send_bytes  =      289 KB
    rem_recv_bytes  =      289 KB
    rem_send_msgs   =  288,603 
    rem_recv_msgs   =  288,603 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.100      PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=295852; ReceivedMessages=295851
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=282580; ReceivedMessages=282580
sockperf: ====> avg-latency=16.846 (std-dev=15.522, mean-ad=1.050, median-ad=0.542, siqr=0.374, cv=0.921, std-error=0.029, 99.0% ci=[16.771, 16.921])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 16.846 usec
sockperf: Total 282580 observations; each percentile contains 2825.80 observations
sockperf: ---> <MAX> observation = 5082.637
sockperf: ---> percentile 99.999 = 1722.514
sockperf: ---> percentile 99.990 =  345.569
sockperf: ---> percentile 99.900 =   53.245
sockperf: ---> percentile 99.000 =   22.778
sockperf: ---> percentile 90.000 =   17.861
sockperf: ---> percentile 75.000 =   16.785
sockperf: ---> percentile 50.000 =   16.364
sockperf: ---> percentile 25.000 =   16.036
sockperf: ---> <MIN> observation =   10.922
```

Two nodes (inside same Availability zone):

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.132, port 5201
[  5] local 10.2.0.91 port 34920 connected to 10.2.0.132 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.37 GBytes  11.7 Gbits/sec  1757   1.06 MBytes       (omitted)
[  5]   1.00-1.00   sec  1.37 GBytes  5.89 Gbits/sec  1001   1.12 MBytes       
[  5]   1.00-2.00   sec  1.35 GBytes  11.6 Gbits/sec  807   1.28 MBytes       
[  5]   2.00-3.00   sec  1.39 GBytes  11.9 Gbits/sec  2277    846 KBytes       
[  5]   3.00-4.00   sec  1.38 GBytes  11.8 Gbits/sec  1129   1.03 MBytes       
[  5]   4.00-5.00   sec  1.37 GBytes  11.8 Gbits/sec  1946   1.04 MBytes       
[  5]   5.00-6.00   sec  1.37 GBytes  11.8 Gbits/sec  1567   1.13 MBytes       
[  5]   6.00-7.00   sec  1.38 GBytes  11.9 Gbits/sec  1116   1.21 MBytes       
[  5]   7.00-8.00   sec  1.37 GBytes  11.8 Gbits/sec  1065   1.10 MBytes       
[  5]   8.00-9.00   sec  1.37 GBytes  11.8 Gbits/sec  532   1.07 MBytes       
[  5]   9.00-10.00  sec  1.36 GBytes  11.7 Gbits/sec  1590   1012 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.7 GBytes  11.8 Gbits/sec  13030             sender
[  5]   0.00-10.00  sec  13.7 GBytes  11.8 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
07:34:53 INFO: Test cycle time negotiated is: 60 seconds
07:34:53 INFO: 64 threads created
07:34:53 INFO: 64 connections created in 23222 microseconds
07:34:53 INFO: Network activity progressing...
07:34:55 INFO: Test warmup completed.
07:35:05 INFO: Test run completed.
07:35:05 INFO: Test cooldown is in progress...
07:35:53 INFO: Test cycle finished.
07:35:53 INFO: receiver exited from current test
07:35:53 INFO: 64 connections tested
07:35:53 INFO: #####  Totals:  #####
07:35:53 INFO: test duration    :10.43 seconds
07:35:53 INFO: total bytes      :15409479680
07:35:53 INFO:   throughput     :11.82Gbps
07:35:53 INFO:   retrans segs   :94539
07:35:53 INFO: cpu cores        :8
07:35:53 INFO:   cpu speed      :2593.905MHz
07:35:53 INFO:   user           :1.23%
07:35:53 INFO:   system         :8.07%
07:35:53 INFO:   idle           :80.07%
07:35:53 INFO:   iowait         :0.00%
07:35:53 INFO:   softirq        :10.64%
07:35:53 INFO:   cycles/byte    :2.80
07:35:53 INFO: cpu busy (all)   :63.59%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.46 GB/sec
    msg_rate    =     22.3 K/sec
    send_bytes  =     14.6 GB
    send_msgs   =  222,748 
    recv_bytes  =     14.6 GB
    recv_msgs   =  222,690 
tcp_lat:
    latency         =    61.3 us
    msg_rate        =    16.3 K/sec
    loc_send_bytes  =    81.6 KB
    loc_recv_bytes  =    81.6 KB
    loc_send_msgs   =  81,609 
    loc_recv_msgs   =  81,608 
    rem_send_bytes  =    81.6 KB
    rem_recv_bytes  =    81.6 KB
    rem_send_msgs   =  81,608 
    rem_recv_msgs   =  81,608 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.33       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=82718; ReceivedMessages=82717
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=78986; ReceivedMessages=78986
sockperf: ====> avg-latency=60.394 (std-dev=47.961, mean-ad=14.272, median-ad=3.967, siqr=10.819, cv=0.794, std-error=0.171, 99.0% ci=[59.954, 60.834])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 60.394 usec
sockperf: Total 78986 observations; each percentile contains 789.86 observations
sockperf: ---> <MAX> observation = 3187.249
sockperf: ---> percentile 99.999 = 3089.125
sockperf: ---> percentile 99.990 = 2279.792
sockperf: ---> percentile 99.900 =  660.399
sockperf: ---> percentile 99.000 =  110.984
sockperf: ---> percentile 90.000 =   77.814
sockperf: ---> percentile 75.000 =   70.402
sockperf: ---> percentile 50.000 =   50.611
sockperf: ---> percentile 25.000 =   48.762
sockperf: ---> <MIN> observation =   39.834
```

Two nodes (different AZs):

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.33, port 5201
[  5] local 10.2.0.91 port 46570 connected to 10.2.0.33 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   761 MBytes  6.38 Gbits/sec  2126    783 KBytes       (omitted)
[  5]   1.00-2.00   sec  1.38 GBytes  11.9 Gbits/sec  996    479 KBytes       (omitted)
[  5]   0.00-1.00   sec  1.37 GBytes  11.8 Gbits/sec  1257   1.20 MBytes       
[  5]   1.00-2.00   sec  1.36 GBytes  11.7 Gbits/sec  1746    725 KBytes       
[  5]   2.00-3.00   sec  1.36 GBytes  11.6 Gbits/sec  602   1.10 MBytes       
[  5]   3.00-4.00   sec  1.36 GBytes  11.7 Gbits/sec  1130   1.03 MBytes       
[  5]   4.00-5.00   sec  1.38 GBytes  11.9 Gbits/sec  1236   1.20 MBytes       
[  5]   5.00-6.00   sec  1.35 GBytes  11.6 Gbits/sec  382    737 KBytes       
[  5]   6.00-7.00   sec  1.34 GBytes  11.5 Gbits/sec  900   1.15 MBytes       
[  5]   7.00-8.00   sec  1.33 GBytes  11.5 Gbits/sec  654    816 KBytes       
[  5]   8.00-9.00   sec  1.36 GBytes  11.7 Gbits/sec  429   1.09 MBytes       
[  5]   9.00-10.00  sec  1.36 GBytes  11.7 Gbits/sec  691    809 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.6 GBytes  11.7 Gbits/sec  9027             sender
[  5]   0.00-10.00  sec  13.6 GBytes  11.7 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
07:13:46 INFO: Test cycle time negotiated is: 60 seconds
07:13:46 INFO: 64 threads created
07:13:46 INFO: 64 connections created in 27252 microseconds
07:13:46 INFO: Network activity progressing...
07:13:48 INFO: Test warmup completed.
07:13:59 INFO: Test run completed.
07:13:59 INFO: Test cooldown is in progress...
07:14:46 INFO: Test cycle finished.
07:14:46 INFO: receiver exited from current test
07:14:46 INFO: 64 connections tested
07:14:46 INFO: #####  Totals:  #####
07:14:46 INFO: test duration    :10.43 seconds
07:14:46 INFO: total bytes      :15436611584
07:14:46 INFO:   throughput     :11.84Gbps
07:14:46 INFO:   retrans segs   :78290
07:14:46 INFO: cpu cores        :8
07:14:46 INFO:   cpu speed      :2593.905MHz
07:14:46 INFO:   user           :0.87%
07:14:46 INFO:   system         :7.53%
07:14:46 INFO:   idle           :83.75%
07:14:46 INFO:   iowait         :0.00%
07:14:46 INFO:   softirq        :7.85%
07:14:46 INFO:   cycles/byte    :2.28
07:14:46 INFO: cpu busy (all)   :62.13%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.44 GB/sec
    msg_rate    =       22 K/sec
    send_bytes  =     14.4 GB
    send_msgs   =  219,724 
    recv_bytes  =     14.4 GB
    recv_msgs   =  219,674 
tcp_lat:
    latency         =    67.1 us
    msg_rate        =    14.9 K/sec
    loc_send_bytes  =    74.5 KB
    loc_recv_bytes  =    74.5 KB
    loc_send_msgs   =  74,472 
    loc_recv_msgs   =  74,471 
    rem_send_bytes  =    74.5 KB
    rem_recv_bytes  =    74.5 KB
    rem_send_msgs   =  74,471 
    rem_recv_msgs   =  74,471 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.132      PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=74447; ReceivedMessages=74446
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=71245; ReceivedMessages=71245
sockperf: ====> avg-latency=66.953 (std-dev=62.056, mean-ad=15.034, median-ad=4.029, siqr=9.803, cv=0.927, std-error=0.232, 99.0% ci=[66.354, 67.552])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 66.953 usec
sockperf: Total 71245 observations; each percentile contains 712.45 observations
sockperf: ---> <MAX> observation = 5628.182
sockperf: ---> percentile 99.999 = 3940.885
sockperf: ---> percentile 99.990 = 2639.830
sockperf: ---> percentile 99.900 =  813.911
sockperf: ---> percentile 99.000 =  124.606
sockperf: ---> percentile 90.000 =   85.041
sockperf: ---> percentile 75.000 =   74.808
sockperf: ---> percentile 50.000 =   57.044
sockperf: ---> percentile 25.000 =   55.201
sockperf: ---> <MIN> observation =   46.638
```


