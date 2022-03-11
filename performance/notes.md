# Notes

Perf testing is always tricky. Here are some
numbers with *very* **very** limited testing.
Your mileage *will* vary.

## Summary

*Summary from perf tests below:*

| Scenario                                               | iperf3 (Gbps) | ntttcp (Gbps) | qperf (us) | sockperf (us) |
| ------------------------------------------------------ | ------------- | ------------- | ---------- | ------------- |
| Local laptop                                           | 96.4          | 101.14        | 33.9       | 56.765        |
| Docker Desktop                                         | 81.8          | 76.39         | 106        | 117.922       |
| Standard_D8ds_v4: VM to VM (single node)               |               |               |            |               |
| Standard_D8ds_v4: VM to VM (two nodes inside same AZ)  |               |               |            |               |
| Standard_D8ds_v4: Kubenet (single node)                |               |               |            |               |
| Standard_D8ds_v4: Kubenet (two nodes inside same AZ)   |               |               |            |               |
| Standard_D8ds_v4: Kubenet (two nodes using PPG)        |               |               |            |               |
| Standard_D8ds_v4: Kubenet (different AZs)              |               |               |            |               |
| Standard_D8ds_v4: Azure CNI (single node)              |               |               |            |               |
| Standard_D8ds_v4: Azure CNI (two nodes inside same AZ) |               |               |            |               |
| Standard_D8ds_v4: Azure CNI (two nodes using PPG)      |               |               |            |               |
| Standard_D8ds_v4: Azure CNI (different AZs)            |               |               |            |               |

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

Two nodes (inside same Availability zone):

```
/app # iperf3 -c $ip
Connecting to host 10.2.0.82, port 5201
[  5] local 10.2.0.35 port 43414 connected to 10.2.0.82 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.39 GBytes  11.9 Gbits/sec  4814    864 KBytes       
[  5]   1.00-2.00   sec  1.37 GBytes  11.8 Gbits/sec  1820   1008 KBytes       
[  5]   2.00-3.00   sec  1.32 GBytes  11.3 Gbits/sec  1464    784 KBytes       
[  5]   3.00-4.00   sec  1.38 GBytes  11.9 Gbits/sec  3006    770 KBytes       
[  5]   4.00-5.00   sec  1.37 GBytes  11.8 Gbits/sec  2468    557 KBytes       
[  5]   5.00-6.00   sec  1.33 GBytes  11.5 Gbits/sec  1160    386 KBytes       
[  5]   6.00-7.00   sec  1.38 GBytes  11.9 Gbits/sec  1637   1.05 MBytes       
[  5]   7.00-8.00   sec  1.38 GBytes  11.9 Gbits/sec  2103    489 KBytes       
[  5]   8.00-9.00   sec  1.38 GBytes  11.9 Gbits/sec  1874    858 KBytes       
[  5]   9.00-10.00  sec  1.37 GBytes  11.7 Gbits/sec  1818   1.04 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.7 GBytes  11.7 Gbits/sec  22164             sender
[  5]   0.00-10.00  sec  13.7 GBytes  11.7 Gbits/sec                  receiver

iperf Done.
```

```
/app # qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.44 GB/sec
    msg_rate    =       22 K/sec
    send_bytes  =     14.4 GB
    send_msgs   =  220,164 
    recv_bytes  =     14.4 GB
    recv_msgs   =  220,075 
tcp_lat:
    latency         =     37.5 us
    msg_rate        =     26.7 K/sec
    loc_send_bytes  =      133 KB
    loc_recv_bytes  =      133 KB
    loc_send_msgs   =  133,484 
    loc_recv_msgs   =  133,483 
    rem_send_bytes  =      133 KB
    rem_recv_bytes  =      133 KB
    rem_send_msgs   =  133,483 
    rem_recv_msgs   =  133,483 
```