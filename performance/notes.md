# Notes

Perf testing is always tricky. Here are some
numbers with *very* **very** limited testing.
Your mileage *will* vary.

## Summary

*Summary from perf tests below:*

| Scenario                                                 | iperf3 (Gbps) | ntttcp (Gbps) | qperf (us) | sockperf (us) |
| -------------------------------------------------------- | ------------- | ------------- | ---------- | ------------- |
| Local laptop                                             | 48.8          | 101.14        | 33.9       | 56.765        |
| Docker Desktop                                           | 52.8          | 114.48        | 61         | 51.138        |
| Standard_D8ds_v4: VM to VM (single node)                 |               |               |            |               |
| Standard_D8ds_v4: VM to VM (two nodes inside same AZ)    |               |               |            |               |
| Standard_D8ds_v4: Kubenet (single node)                  | 25.2          | 94.87         | 17.7       | 17.568        |
| Standard_D8ds_v4: Kubenet (two nodes inside same AZ)     | 11.7          | 11.83         | 40.3       | 43.861        |
| Standard_D8ds_v4: Kubenet (two nodes different AZs)      | 11.5          | 11.82         | 60.3       | 55.581        |
| Standard_D8ds_v4: Kubenet (two nodes using PPG)          |               |               |            |               |
| Standard_D8ds_v4: Azure CNI (single node)                | 25.5          | 99.98         | 17.3       | 16.846        |
| Standard_D8ds_v4: Azure CNI (two nodes inside same AZ)   | 11.8          | 11.82         | 61.3       | 60.394        |
| Standard_D8ds_v4: Azure CNI (two nodes in different AZs) | 11.7          | 11.84         | 67.1       | 66.953        |
| Standard_D8ds_v4: Azure CNI (two nodes using PPG)        | 11.8          | 11.84         | 43.4       | 46.025        |

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
Connecting to host 10.1.0.57, port 5201
[  5] local 10.1.0.61 port 54230 connected to 10.1.0.57 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  6.17 GBytes  53.0 Gbits/sec    2   1.42 MBytes       (omitted)
[  5]   1.00-2.00   sec  6.40 GBytes  55.0 Gbits/sec    0   1.42 MBytes       (omitted)
[  5]   0.00-1.00   sec  6.11 GBytes  52.5 Gbits/sec    0   1.42 MBytes       
[  5]   1.00-2.00   sec  6.08 GBytes  52.2 Gbits/sec    0   1.42 MBytes       
[  5]   2.00-3.00   sec  5.78 GBytes  49.6 Gbits/sec    0   1.42 MBytes       
[  5]   3.00-4.00   sec  6.22 GBytes  53.4 Gbits/sec    1   1.43 MBytes       
[  5]   4.00-5.00   sec  6.02 GBytes  51.7 Gbits/sec    0   1.43 MBytes       
[  5]   5.00-6.00   sec  5.80 GBytes  49.8 Gbits/sec    1   1.44 MBytes       
[  5]   6.00-7.00   sec  6.05 GBytes  52.0 Gbits/sec   48   1.44 MBytes       
[  5]   7.00-8.00   sec  6.54 GBytes  56.2 Gbits/sec    0   1.44 MBytes       
[  5]   8.00-9.00   sec  6.41 GBytes  55.0 Gbits/sec    1   1.45 MBytes       
[  5]   9.00-10.00  sec  6.47 GBytes  55.6 Gbits/sec   47   1.45 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  61.5 GBytes  52.8 Gbits/sec   98             sender
[  5]   0.00-10.00  sec  61.5 GBytes  52.8 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
07:58:50 INFO: Test cycle time negotiated is: 60 seconds
07:58:50 INFO: 64 threads created
07:58:50 INFO: 64 connections created in 42977 microseconds
07:58:50 INFO: Network activity progressing...
07:58:52 INFO: Test warmup completed.
07:59:03 INFO: Test run completed.
07:59:03 INFO: Test cooldown is in progress...
07:59:50 INFO: Test cycle finished.
07:59:50 INFO: receiver exited from current test
07:59:50 INFO: 64 connections tested
07:59:50 INFO: #####  Totals:  #####
07:59:50 INFO: test duration    :10.75 seconds
07:59:50 INFO: total bytes      :153871843328
07:59:50 INFO:   throughput     :114.48Gbps
07:59:50 INFO:   retrans segs   :41608
07:59:50 INFO: cpu cores        :8
07:59:50 INFO:   cpu speed      :1497.603MHz
07:59:50 INFO:   user           :3.96%
07:59:50 INFO:   system         :73.48%
07:59:50 INFO:   idle           :1.37%
07:59:50 INFO:   iowait         :0.00%
07:59:50 INFO:   softirq        :21.19%
07:59:50 INFO:   cycles/byte    :0.83
07:59:50 INFO: cpu busy (all)   :327.19%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     5.45 GB/sec
    msg_rate    =     83.1 K/sec
    send_bytes  =     54.5 GB
    send_msgs   =  831,041 
    recv_bytes  =     54.5 GB
    recv_msgs   =  831,041 
tcp_lat:
    latency         =      61 us
    msg_rate        =    16.4 K/sec
    loc_send_bytes  =    81.9 KB
    loc_recv_bytes  =    81.9 KB
    loc_send_msgs   =  81,927 
    loc_recv_msgs   =  81,926 
    rem_send_bytes  =    81.9 KB
    rem_recv_bytes  =    81.9 KB
    rem_send_msgs   =  81,926 
    rem_recv_msgs   =  81,927 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.1.0.57       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.001 sec; Warm up time=400 msec; SentMessages=97379; ReceivedMessages=97378
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=93141; ReceivedMessages=93141
sockperf: ====> avg-latency=51.138 (std-dev=26.705, mean-ad=12.692, median-ad=14.448, siqr=10.024, cv=0.522, std-error=0.088, 99.0% ci=[50.913, 51.363])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 51.138 usec
sockperf: Total 93141 observations; each percentile contains 931.41 observations
sockperf: ---> <MAX> observation = 2926.053
sockperf: ---> percentile 99.999 = 2146.110
sockperf: ---> percentile 99.990 =  916.232
sockperf: ---> percentile 99.900 =  246.896
sockperf: ---> percentile 99.000 =  108.117
sockperf: ---> percentile 90.000 =   71.351
sockperf: ---> percentile 75.000 =   57.730
sockperf: ---> percentile 50.000 =   47.124
sockperf: ---> percentile 25.000 =   37.680
sockperf: ---> <MIN> observation =    6.774
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
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.244.0.5, port 5201
[  5] local 10.244.0.6 port 54732 connected to 10.244.0.5 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  2.60 GBytes  22.3 Gbits/sec    0    455 KBytes       (omitted)
[  5]   1.00-2.00   sec  2.94 GBytes  25.2 Gbits/sec    0    505 KBytes       (omitted)
[  5]   0.00-1.00   sec  2.96 GBytes  25.4 Gbits/sec    0   1.02 MBytes       
[  5]   1.00-2.00   sec  2.93 GBytes  25.2 Gbits/sec    0   1.02 MBytes       
[  5]   2.00-3.00   sec  2.94 GBytes  25.2 Gbits/sec    0   1.12 MBytes       
[  5]   3.00-4.00   sec  2.91 GBytes  25.0 Gbits/sec    0   1.12 MBytes       
[  5]   4.00-5.00   sec  2.91 GBytes  25.0 Gbits/sec    0   1.12 MBytes       
[  5]   5.00-6.00   sec  2.90 GBytes  24.9 Gbits/sec    0   1.12 MBytes       
[  5]   6.00-7.00   sec  2.95 GBytes  25.4 Gbits/sec    0   1.12 MBytes       
[  5]   7.00-8.00   sec  2.93 GBytes  25.2 Gbits/sec    0   1.12 MBytes       
[  5]   8.00-9.00   sec  2.93 GBytes  25.2 Gbits/sec    0   1.62 MBytes       
[  5]   9.00-10.00  sec  2.92 GBytes  25.1 Gbits/sec    0   1.62 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  29.3 GBytes  25.2 Gbits/sec    0             sender
[  5]   0.00-10.00  sec  29.3 GBytes  25.2 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
08:58:01 INFO: Test cycle time negotiated is: 60 seconds
08:58:01 INFO: 64 threads created
08:58:01 INFO: 64 connections created in 27705 microseconds
08:58:01 INFO: Network activity progressing...
08:58:03 INFO: Test warmup completed.
08:58:14 INFO: Test run completed.
08:58:14 INFO: Test cooldown is in progress...
08:59:01 INFO: Test cycle finished.
08:59:01 INFO: receiver exited from current test
08:59:01 INFO: 64 connections tested
08:59:01 INFO: #####  Totals:  #####
08:59:01 INFO: test duration    :10.33 seconds
08:59:01 INFO: total bytes      :122552582144
08:59:01 INFO:   throughput     :94.87Gbps
08:59:01 INFO:   retrans segs   :12225
08:59:01 INFO: cpu cores        :8
08:59:01 INFO:   cpu speed      :2593.905MHz
08:59:01 INFO:   user           :2.38%
08:59:01 INFO:   system         :72.90%
08:59:01 INFO:   idle           :0.13%
08:59:01 INFO:   iowait         :0.00%
08:59:01 INFO:   softirq        :24.58%
08:59:01 INFO:   cycles/byte    :1.75
08:59:01 INFO: cpu busy (all)   :434.80%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     2.39 GB/sec
    msg_rate    =     36.5 K/sec
    send_bytes  =     23.9 GB
    send_msgs   =  364,722 
    recv_bytes  =     23.9 GB
    recv_msgs   =  364,722 
tcp_lat:
    latency         =     17.7 us
    msg_rate        =     56.5 K/sec
    loc_send_bytes  =      282 KB
    loc_recv_bytes  =      282 KB
    loc_send_msgs   =  282,253 
    loc_recv_msgs   =  282,252 
    rem_send_bytes  =      282 KB
    rem_recv_bytes  =      282 KB
    rem_send_msgs   =  282,253 
    rem_recv_msgs   =  282,253 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.244.0.5      PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=283749; ReceivedMessages=283748
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=271030; ReceivedMessages=271030
sockperf: ====> avg-latency=17.568 (std-dev=1.884, mean-ad=0.921, median-ad=0.735, siqr=0.550, cv=0.107, std-error=0.004, 99.0% ci=[17.559, 17.577])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 17.568 usec
sockperf: Total 271030 observations; each percentile contains 2710.30 observations
sockperf: ---> <MAX> observation =  161.351
sockperf: ---> percentile 99.999 =  140.205
sockperf: ---> percentile 99.990 =   70.634
sockperf: ---> percentile 99.900 =   35.048
sockperf: ---> percentile 99.000 =   24.412
sockperf: ---> percentile 90.000 =   18.835
sockperf: ---> percentile 75.000 =   17.901
sockperf: ---> percentile 50.000 =   17.235
sockperf: ---> percentile 25.000 =   16.800
sockperf: ---> <MIN> observation =   11.623
```

Two nodes (inside same Availability zone):

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.244.1.7, port 5201
[  5] local 10.244.2.4 port 51422 connected to 10.244.1.7 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.37 GBytes  11.7 Gbits/sec  2680    832 KBytes       (omitted)
[  5]   1.00-2.00   sec  1.35 GBytes  11.6 Gbits/sec  1184   1.12 MBytes       (omitted)
[  5]   0.00-1.00   sec  1.32 GBytes  11.3 Gbits/sec  972    802 KBytes       
[  5]   1.00-2.00   sec  1.36 GBytes  11.7 Gbits/sec  399   1001 KBytes       
[  5]   2.00-3.00   sec  1.36 GBytes  11.7 Gbits/sec  798   1.06 MBytes       
[  5]   3.00-4.00   sec  1.34 GBytes  11.5 Gbits/sec  478    774 KBytes       
[  5]   4.00-5.00   sec  1.36 GBytes  11.7 Gbits/sec  407    747 KBytes       
[  5]   5.00-6.00   sec  1.37 GBytes  11.8 Gbits/sec  555   1.04 MBytes       
[  5]   6.00-7.00   sec  1.37 GBytes  11.8 Gbits/sec  1369   1.12 MBytes       
[  5]   7.00-8.00   sec  1.36 GBytes  11.7 Gbits/sec  557    519 KBytes       
[  5]   8.00-9.00   sec  1.34 GBytes  11.5 Gbits/sec  583    747 KBytes       
[  5]   9.00-10.00  sec  1.38 GBytes  11.9 Gbits/sec  199   1.13 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.6 GBytes  11.7 Gbits/sec  6317             sender
[  5]   0.00-10.00  sec  13.6 GBytes  11.7 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
08:23:55 INFO: Test cycle time negotiated is: 60 seconds
08:23:55 INFO: 64 threads created
08:23:55 INFO: 64 connections created in 28873 microseconds
08:23:55 INFO: Network activity progressing...
08:23:57 INFO: Test warmup completed.
08:24:08 INFO: Test run completed.
08:24:08 INFO: Test cooldown is in progress...
08:24:55 INFO: Test cycle finished.
08:24:55 INFO: receiver exited from current test
08:24:55 INFO: 64 connections tested
08:24:55 INFO: #####  Totals:  #####
08:24:55 INFO: test duration    :10.33 seconds
08:24:55 INFO: total bytes      :15276310528
08:24:55 INFO:   throughput     :11.83Gbps
08:24:55 INFO:   retrans segs   :87755
08:24:55 INFO: cpu cores        :8
08:24:55 INFO:   cpu speed      :2593.905MHz
08:24:55 INFO:   user           :0.83%
08:24:55 INFO:   system         :8.19%
08:24:55 INFO:   idle           :85.42%
08:24:55 INFO:   iowait         :0.01%
08:24:55 INFO:   softirq        :5.54%
08:24:55 INFO:   cycles/byte    :2.05
08:24:55 INFO: cpu busy (all)   :63.37%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.47 GB/sec
    msg_rate    =     22.4 K/sec
    send_bytes  =     14.7 GB
    send_msgs   =  224,380 
    recv_bytes  =     14.7 GB
    recv_msgs   =  224,348 
tcp_lat:
    latency         =     40.3 us
    msg_rate        =     24.8 K/sec
    loc_send_bytes  =      124 KB
    loc_recv_bytes  =      124 KB
    loc_send_msgs   =  124,101 
    loc_recv_msgs   =  124,100 
    rem_send_bytes  =      124 KB
    rem_recv_bytes  =      124 KB
    rem_send_msgs   =  124,100 
    rem_recv_msgs   =  124,100 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.244.1.7      PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=114226; ReceivedMessages=114225
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=108735; ReceivedMessages=108735
sockperf: ====> avg-latency=43.861 (std-dev=11.746, mean-ad=7.382, median-ad=1.847, siqr=1.652, cv=0.268, std-error=0.036, 99.0% ci=[43.769, 43.953])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 43.861 usec
sockperf: Total 108735 observations; each percentile contains 1087.35 observations
sockperf: ---> <MAX> observation =  888.137
sockperf: ---> percentile 99.999 =  417.544
sockperf: ---> percentile 99.990 =  220.849
sockperf: ---> percentile 99.900 =  114.332
sockperf: ---> percentile 99.000 =   87.660
sockperf: ---> percentile 90.000 =   63.044
sockperf: ---> percentile 75.000 =   41.757
sockperf: ---> percentile 50.000 =   39.455
sockperf: ---> percentile 25.000 =   38.451
sockperf: ---> <MIN> observation =   32.278
```

Two nodes (different AZs):

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.244.1.7, port 5201
[  5] local 10.244.0.5 port 35672 connected to 10.244.1.7 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.37 GBytes  11.8 Gbits/sec  2893   1.08 MBytes       (omitted)
[  5]   1.00-2.00   sec  1.36 GBytes  11.7 Gbits/sec  307   1.22 MBytes       (omitted)
[  5]   0.00-1.00   sec  1.37 GBytes  11.7 Gbits/sec  150    744 KBytes       
[  5]   1.00-2.00   sec  1.35 GBytes  11.6 Gbits/sec  110   1.17 MBytes       
[  5]   2.00-3.00   sec  1.35 GBytes  11.6 Gbits/sec   68   1.17 MBytes       
[  5]   3.00-4.00   sec  1.33 GBytes  11.4 Gbits/sec  305   1.13 MBytes       
[  5]   4.00-5.00   sec  1.35 GBytes  11.6 Gbits/sec  375   1.23 MBytes       
[  5]   5.00-6.00   sec  1.32 GBytes  11.3 Gbits/sec  554   1.10 MBytes       
[  5]   6.00-7.00   sec  1.35 GBytes  11.6 Gbits/sec  663   1.19 MBytes       
[  5]   7.00-8.00   sec  1.32 GBytes  11.3 Gbits/sec  420   1.08 MBytes       
[  5]   8.00-9.00   sec  1.35 GBytes  11.6 Gbits/sec  202   1.09 MBytes       
[  5]   9.00-10.00  sec  1.34 GBytes  11.5 Gbits/sec  194   1.17 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.4 GBytes  11.5 Gbits/sec  3041             sender
[  5]   0.00-10.00  sec  13.4 GBytes  11.5 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
08:43:40 INFO: Test cycle time negotiated is: 60 seconds
08:43:40 INFO: 64 threads created
08:43:40 INFO: 64 connections created in 36481 microseconds
08:43:40 INFO: Network activity progressing...
08:43:42 INFO: Test warmup completed.
08:43:53 INFO: Test run completed.
08:43:53 INFO: Test cooldown is in progress...
08:44:40 INFO: Test cycle finished.
08:44:40 INFO: receiver exited from current test
08:44:41 INFO: 64 connections tested
08:44:41 INFO: #####  Totals:  #####
08:44:41 INFO: test duration    :10.38 seconds
08:44:41 INFO: total bytes      :15332278272
08:44:41 INFO:   throughput     :11.82Gbps
08:44:41 INFO:   retrans segs   :87626
08:44:41 INFO: cpu cores        :8
08:44:41 INFO:   cpu speed      :2593.905MHz
08:44:41 INFO:   user           :0.83%
08:44:41 INFO:   system         :7.82%
08:44:41 INFO:   idle           :83.33%
08:44:41 INFO:   iowait         :0.00%
08:44:41 INFO:   softirq        :8.01%
08:44:41 INFO:   cycles/byte    :2.34
08:44:41 INFO: cpu busy (all)   :62.76%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.46 GB/sec
    msg_rate    =     22.3 K/sec
    send_bytes  =     14.6 GB
    send_msgs   =  223,180 
    recv_bytes  =     14.6 GB
    recv_msgs   =  223,126 
tcp_lat:
    latency         =    60.3 us
    msg_rate        =    16.6 K/sec
    loc_send_bytes  =      83 KB
    loc_recv_bytes  =      83 KB
    loc_send_msgs   =  82,967 
    loc_recv_msgs   =  82,967 
    rem_send_bytes  =      83 KB
    rem_recv_bytes  =      83 KB
    rem_send_msgs   =  82,967 
    rem_recv_msgs   =  82,968 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.244.1.7      PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=89731; ReceivedMessages=89730
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.550 sec; SentMessages=85823; ReceivedMessages=85823
sockperf: ====> avg-latency=55.581 (std-dev=11.032, mean-ad=6.442, median-ad=1.919, siqr=1.513, cv=0.198, std-error=0.038, 99.0% ci=[55.484, 55.678])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 55.581 usec
sockperf: Total 85823 observations; each percentile contains 858.23 observations
sockperf: ---> <MAX> observation = 1116.444
sockperf: ---> percentile 99.999 =  384.194
sockperf: ---> percentile 99.990 =  247.477
sockperf: ---> percentile 99.900 =  121.005
sockperf: ---> percentile 99.000 =   89.436
sockperf: ---> percentile 90.000 =   73.749
sockperf: ---> percentile 75.000 =   54.009
sockperf: ---> percentile 50.000 =   52.072
sockperf: ---> percentile 25.000 =   50.983
sockperf: ---> <MIN> observation =   42.703
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

Two nodes using PPG:

```
# iperf3 -c $ip -b 0 -O 2
Connecting to host 10.2.0.86, port 5201
[  5] local 10.2.0.18 port 51308 connected to 10.2.0.86 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  1.38 GBytes  11.8 Gbits/sec  4758   1.08 MBytes       (omitted)
[  5]   1.00-2.00   sec  1.37 GBytes  11.8 Gbits/sec  1675    872 KBytes       (omitted)
[  5]   0.00-1.00   sec  1.35 GBytes  11.6 Gbits/sec  897    401 KBytes       
[  5]   1.00-2.00   sec  1.38 GBytes  11.9 Gbits/sec  906   1.13 MBytes       
[  5]   2.00-3.00   sec  1.38 GBytes  11.9 Gbits/sec  980    865 KBytes       
[  5]   3.00-4.00   sec  1.37 GBytes  11.7 Gbits/sec  2916    946 KBytes       
[  5]   4.00-5.00   sec  1.38 GBytes  11.9 Gbits/sec  1268    824 KBytes       
[  5]   5.00-6.00   sec  1.38 GBytes  11.9 Gbits/sec  2421    903 KBytes       
[  5]   6.00-7.00   sec  1.38 GBytes  11.9 Gbits/sec  2025    596 KBytes       
[  5]   7.00-8.00   sec  1.37 GBytes  11.8 Gbits/sec  1564    398 KBytes       
[  5]   8.00-9.00   sec  1.37 GBytes  11.7 Gbits/sec  1526   1.04 MBytes       
[  5]   9.00-10.00  sec  1.36 GBytes  11.7 Gbits/sec  4562    568 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  13.7 GBytes  11.8 Gbits/sec  19065             sender
[  5]   0.00-10.00  sec  13.7 GBytes  11.8 Gbits/sec                  receiver

iperf Done.
```

```
# ntttcp -s $ip -W 2 -t 10 -l 1
NTTTCP for Linux 1.4.0
---------------------------------------------------------
13:04:03 INFO: Test cycle time negotiated is: 60 seconds
13:04:03 INFO: 64 threads created
13:04:03 INFO: 64 connections created in 36278 microseconds
13:04:03 INFO: Network activity progressing...
13:04:05 INFO: Test warmup completed.
13:04:15 INFO: Test run completed.
13:04:15 INFO: Test cooldown is in progress...
13:05:03 INFO: Test cycle finished.
13:05:03 INFO: receiver exited from current test
13:05:03 INFO: 64 connections tested
13:05:03 INFO: #####  Totals:  #####
13:05:03 INFO: test duration    :10.34 seconds
13:05:03 INFO: total bytes      :15307898880
13:05:03 INFO:   throughput     :11.84Gbps
13:05:03 INFO:   retrans segs   :86222
13:05:03 INFO: cpu cores        :8
13:05:03 INFO:   cpu speed      :2593.905MHz
13:05:03 INFO:   user           :1.10%
13:05:03 INFO:   system         :8.22%
13:05:03 INFO:   idle           :83.03%
13:05:03 INFO:   iowait         :0.00%
13:05:03 INFO:   softirq        :7.64%
13:05:03 INFO:   cycles/byte    :2.38
13:05:03 INFO: cpu busy (all)   :64.49%
```

```
# qperf $ip -vvs -t 10 tcp_bw tcp_lat
tcp_bw:
    bw          =     1.47 GB/sec
    msg_rate    =     22.4 K/sec
    send_bytes  =     14.7 GB
    send_msgs   =  224,378 
    recv_bytes  =     14.7 GB
    recv_msgs   =  224,277 
tcp_lat:
    latency         =     43.4 us
    msg_rate        =     23.1 K/sec
    loc_send_bytes  =      115 KB
    loc_recv_bytes  =      115 KB
    loc_send_msgs   =  115,258 
    loc_recv_msgs   =  115,257 
    rem_send_bytes  =      115 KB
    rem_recv_bytes  =      115 KB
    rem_send_msgs   =  115,257 
    rem_recv_msgs   =  115,257 
```

```
# sockperf ping-pong -i $ip --tcp -t 10 -p 5201
sockperf: == version #3.8-0.git31ee322aa82a == 
sockperf[CLIENT] send on:sockperf: using recvfrom() to block on socket(s)

[ 0] IP = 10.2.0.86       PORT =  5201 # TCP
sockperf: Warmup stage (sending a few dummy messages)...
sockperf: Starting test...
sockperf: Test end (interrupted by timer)
sockperf: Test ended
sockperf: [Total Run] RunTime=10.000 sec; Warm up time=400 msec; SentMessages=107221; ReceivedMessages=107220
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=9.548 sec; SentMessages=103596; ReceivedMessages=103596
sockperf: ====> avg-latency=46.025 (std-dev=57.690, mean-ad=8.267, median-ad=1.985, siqr=1.512, cv=1.253, std-error=0.179, 99.0% ci=[45.563, 46.487])
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 46.025 usec
sockperf: Total 103596 observations; each percentile contains 1035.96 observations
sockperf: ---> <MAX> observation = 4479.887
sockperf: ---> percentile 99.999 = 4455.451
sockperf: ---> percentile 99.990 = 2466.181
sockperf: ---> percentile 99.900 =  686.002
sockperf: ---> percentile 99.000 =  110.743
sockperf: ---> percentile 90.000 =   47.321
sockperf: ---> percentile 75.000 =   43.293
sockperf: ---> percentile 50.000 =   41.367
sockperf: ---> percentile 25.000 =   40.268
sockperf: ---> <MIN> observation =   33.557
```
