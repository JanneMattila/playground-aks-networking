# Notes

Perf testing is always tricky. Here are some
numbers with *very* **very** limited testing.
Your mileage *will* vary.

## Summary

*Summary from `qperf` tests below:*

| Scenario                                               | Bandwidth   | Latency |
| ------------------------------------------------------ | ----------- | ------- |
| Local laptop                                           | 8.03 GB/sec | 33.9 us |
| Docker Desktop                                         | 6.37 GB/sec | 38 us   |
| Standard_D8ds_v4: VM to VM (single node)               | 3.52 GB/sec | 14.4 us |
| Standard_D8ds_v4: VM to VM (two nodes inside same AZ)  | 1.49 GB/sec | 28.3 us |
| Standard_D8ds_v4: Kubenet (single node)                | 1.44 GB/sec | 47.4 us |
| Standard_D8ds_v4: Kubenet (two nodes inside same AZ)   | 1.46 GB/sec | 49.7 us |
| Standard_D8ds_v4: Kubenet (different AZs)              | TBA         | TBA     |
| Standard_D8ds_v4: Azure CNI (single node)              | 2.64 GB/sec | 17.3 us |
| Standard_D8ds_v4: Azure CNI (two nodes inside same AZ) | 1.44 GB/sec | 37.5 us |
| Standard_D8ds_v4: Azure CNI (different AZs)            | TBA         | TBA     |

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