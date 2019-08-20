# Zookeeper运维
网上很多介绍zookeeper的文章都是从ZAB原理、数据结构、API使用等层面入手的，这篇文章本着换个角度，从运维的视角来看看zookeeper。

## 部署

### 三种启动模式
- 单机模式：在一台机器上启动一个zookeeper进程
- 伪集群模式：在一台机器上启动>=3个zookeeper进程，组成1个集群
- 集群模式：在>=3台机器上各启动1个zookeeper进程，组成1个集群

### 配置文件zoo.cfg
- <b>tickTime</b> Zookeeper服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每隔 tickTime时间就会发送一个心跳包，tickTime以毫秒为单位。
- <b>initLimit</b> 集群中的follower服务器(F)与leader服务器(L)之间初始连接时能容忍的最多心跳数（tickTime的数量）
- <b>syncLimit</b> 集群中的follower服务器与leader服务器之间请求和应答之间能容忍的最多心跳数（tickTime的数量）
- <b>dataDir</b> 数据落盘的目录，建议使用一个单独的分区
- <b>clientPort</b> 客户端连接Zookeeper服务器的端口，Zookeeper会监听这个端口，接受客户端的访问请求。
- <b>autopurge.snapRetainCount</b> snapshot保存个数
- <b>autopurge.purgeInterval</b> snapshot清理周期(小时)
- <b>snapCount</b> 多少次操作生成一个snapshot
- <b>maxClientCnxns</b> 单个客户端和单个zookeeper服务器最多可以建立的连接数
- <b>minSessionTimeout</b> 客户端与zookeeper服务器建立的session的最小超时时间。如果客户端设置的超时时间小于minSessionTimeout，则超时时间设为minSessionTimeout。
- <b>maxSessionTimeout</b> 客户端与zookeeper服务器建立的session的最大超时时间。如果客户端设置的超时时间大于maxSessionTimeout，则超时时间设为maxSessionTimeout。


## 监控

### 端口监控
- 实现：

```shell
nc -z 127.1 2181
```
- 监控指标：
	* port.2181.alive
- 报警策略：
	* 【P1】2181端口不可用

### 进程监控
- 实现：

```shell
cat /proc/$PID/status|egrep '(FDSize|^Vm|^Rss|Threads|ctxt_switches)'
```
- 监控指标：
	* PLUGIN.zk_proc.FDSize
	* PLUGIN.zk_proc.Threads
	* PLUGIN.zk_proc.VmData
	* PLUGIN.zk_proc.VmExe
	* PLUGIN.zk_proc.VmHWM
	* PLUGIN.zk_proc.VmLck
	* PLUGIN.zk_proc.VmLib
	* PLUGIN.zk_proc.VmPeak
	* PLUGIN.zk_proc.VmPTE
	* PLUGIN.zk_proc.VmRSS
	* PLUGIN.zk_proc.VmSize
	* PLUGIN.zk_proc.VmStk
	* PLUGIN.zk_proc.VmSwap
	* PLUGIN.zk_proc.VmSwap
	* PLUGIN.zk_proc.VoluntaryCtx
	* PLUGIN.zk_proc.NonvoluntaryCtx
- 报警策略：
	* 【P2】threads大于300

### JVM监控
- 实现：

```shell
jstat -gcutil $PID
```
- 监控指标：
	* PLUGIN.jvm-monitor.FGC.count
	* PLUGIN.jvm-monitor.FGC.count.total
	* PLUGIN.jvm-monitor.FGC.time
	* PLUGIN.jvm-monitor.FGC.time.total
	* PLUGIN.jvm-monitor.mem.size.kb
	* PLUGIN.jvm-monitor.YGC.average.time
	* PLUGIN.jvm-monitor.YGC.count
	* PLUGIN.jvm-monitor.YGC.count.total
	* PLUGIN.jvm-monitor.YGC.time
	* PLUGIN.jvm-monitor.YGC.time.total
- 报警策略：
	* 无

### 四字监控
- 实现：

```shell
echo mntr|nc 127.1 2181
echo srvr|nc 127.1 2181
```
- 监控指标：
	* PLUGIN.flw-monitor.zk\_approximate\_data\_size
	* PLUGIN.flw-monitor.zk\_data\_rate
	* PLUGIN.flw-monitor.zk\_ephemerals\_count
	* PLUGIN.flw-monitor.zk\_followers
	* PLUGIN.flw-monitor.zk\_synced\_followers
	* PLUGIN.flw-monitor.zk\_max_file\_descriptor\_count
	* PLUGIN.flw-monitor.zk\_open\_file\_descriptor\_count
	* PLUGIN.flw-monitor.zk\_avg\_latency
	* PLUGIN.flw-monitor.zk\_max\_latency
	* PLUGIN.flw-monitor.zk\_min\_latency
	* PLUGIN.flw-monitor.zk\_num\_alive\_connections
	* PLUGIN.flw-monitor.zk\_conns\_rate
	* PLUGIN.flw-monitor.zk\_outstanding\_requests
	* PLUGIN.flw-monitor.zk\_packets\_received
	* PLUGIN.flw-monitor.zk\_received\_rate
	* PLUGIN.flw-monitor.zk\_packets\_sent
	* PLUGIN.flw-monitor.zk\_sent\_rate
	* PLUGIN.flw-monitor.zk\_pending\_syncs
	* PLUGIN.flw-monitor.zk\_server\_type
	* PLUGIN.flw-monitor.zk\_version
	* PLUGIN.flw-monitor.zk\_watch\_count
	* PLUGIN.flw-monitor.zk\_watch\_rate
	* PLUGIN.flw-monitor.zk\_znode\_count
	* PLUGIN.flw-monitor.zk\_znode\_rate
- 报警策略：
	- 【p2】zookeeper服务数据大于500M
	- 【p2】zookeeper服务节点数大于100w
	- 【p2】zookeeper服务leader变更
	- 【p2】zookeeper服务outstandingRequests大于100
	- 【p2】zookeeper服务连接数大于1w
	- 【p2】zookeeper服务watch数大于10w
- 四字命令介绍：
    - <b>conf</b> 获取当前zookeeper服务器的配置
    - <b>envi</b> 获取当前zookeeper服务器的环境变量
    - <b>cons</b> 获取当前zookeeper服务器的活跃连接
    - <b>crst</b> 重置当前zookeeper服务器所有连接的统计信息
    - <b>srst</b> 重置当前服务器的统计信息
    - <b>srvr</b> 输出服务器的详细信息。zk版本、接收/发送包数量、连接数、模式（leader/follower）、节点总数
    - <b>stat</b> 输出服务器的详细信息。zk版本、接收/发送包数量、连接数、模式（leader/follower）、节点总数、客户端列表
    - <b>mntr</b> 列出集群的健康状态。包括“接受/发送”的包数量、操作延迟、连接数、缓冲队列数、当前服务模式（leader/follower）、节点总数、watch总数、临时节点总数
    - <b>ruok</b> 返回“imok”表示正常，否则表示服务异常。
    - <b>wchs</b> 列出服务器watches的简洁信息：连接总数、watching节点总数和watches总数
    - <b>wchc</b> 通过session分组，列出watch的所有节点，它的输出是一个与 watch 相关的会话的节点列表。如果watches数量很大的话，将会产生很大的开销，会影响性能，小心使用。
    - <b>wchp</b> 通过路径分组，列出所有的 watch 的session id信息。它输出一个与 session 相关的路径。如果watches数量很大的话，将会产生很大的开销，会影响性能，小心使用。
    - <b>dump</b> 列出未经处理的会话和临时节点（只在leader上有效）

### 日志监控
- 实现：

```shell
grep xxx zookeeper.log
```
- 监控指标：
	* PLUGIN.log-monitor.connection\_broken_pipe
	* PLUGIN.log-monitor.connection\_reset\_by\_peer
	* PLUGIN.log-monitor.leader\_error
	* PLUGIN.log-monitor.len\_error
	* PLUGIN.log-monitor.stream\_exception
	* PLUGIN.log-monitor.too_many\_connections
	* PLUGIN.log-monitor.unexpected\_exception
- 报警策略：
	* 【p2】zookeeper单个请求大于1M
	* 【p2】zookeeper单台客户端连接数大于60

### Zxid监控
- 实现：

```python
#!/usr/bin/env python
import json
import socket
import time
import re
import os
import sys


def get_zxid(port):
        s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        try:
                s.connect(('127.0.0.1', port))
        except Exception:
                return -2
        s.send('srvr')
        data = s.recv(10240)
        s.close()
        for line in data.split('\n'):
                if line.startswith('Zxid'):
                        return eval(line.split(':')[1].strip() + " & 0xffffffff")
        return -1

if __name__ == '__main__':
        port=2181
        res_maps = []
        data1 = get_zxid(port)
        time.sleep(1)
        data2 = get_zxid(port)
        if data1 < 0 or data2 < 0:
                sys.exit(1)
        map1 = {}
        map1['name'] = 'cur_zxid'
        map1['value'] = data2
        map1['timestamp'] = int("%d" % time.time())
        map1["tags"] = {"ZKPort": str(port)}
        res_maps.append(map1)
        map2 = {}
        zxid_rate = (data2 - data1)
        map2['name'] = 'zxid_rate'
        map2['value'] = (data2 - data1)
        map2['timestamp'] = int("%d" % time.time())
        map2["tags"] = {"ZKPort": str(port)}
        res_maps.append(map2)
        map3 = {}
        map3['name'] = 'zxid_left_hour'
        ### (0xffffffff - cur_zxid)/zxid_rate/60/60
        if zxid_rate == 0:
                map3['value'] = 4294967295-data2
        else:
                map3['value'] = (4294967295-data2)/zxid_rate/60/60
        map3['timestamp'] = int("%d" % time.time())
        map3["tags"] = {"ZKPort": str(port)}
        res_maps.append(map3)
        print json.dumps(res_maps)
```
- 监控指标：
	* PLUGIN.zxid_monitor.cur\_zxid 当前的zxid
	* PLUGIN.zxid_monitor.zxid\_rate zxid的增长速率
	* PLUGIN.zxid_monitor.zxid\_left\_hour zxid溢出剩余的小时数
- 报警策略：
	* 【p2】zxid在12小时后即将用完


## 日常运维
### 抓包分析

```
#get from https://github.com/pyinx/zk-sniffer
zk-sniffer -device=eth0 -port=2181
```
![](http://wx4.sinaimg.cn/mw690/6f6a4381ly1fcjaly09eej213e0hkgxg.jpg)

### 分析log文件

```
#!/bin/sh

function help(){
        echo "-----------------"
        echo "HELP: $0 LogFile"
        echo "-----------------"
        exit 1
}

if [ $# -ne 1 ]
then
        help
fi

LogFile=$1
if [ ! -f $LogFile ]
then
        echo "ERROR: $LogFile not found"
        exit 1
fi
zkDir=/usr/local/zookeeper
JAVA_OPTS="$JAVA_OPTS -Djava.ext.dirs=$zkDir:$zkDir/lib"
java $JAVA_OPTS org.apache.zookeeper.server.LogFormatter "$LogFile"
```
### 分析snapshot文件

```
#!/bin/sh

function help(){
        echo "-----------------"
        echo "HELP: $0 SnapshotFile"
        echo "-----------------"
        exit 1
}

if [ $# -ne 1 ]
then
        help
fi

file=$1
if [ ! -f $file ]
then
        echo "ERROR: $file not found"
        exit 1
fi
zkDir=/usr/local/zookeeper
JAVA_OPTS="$JAVA_OPTS -Djava.ext.dirs=$zkDir:$zkDir/lib"
java $JAVA_OPTS org.apache.zookeeper.server.SnapshotFormatter "$file"
```
### zkcli.sh批量执行

```
zkCli.sh -server localhost:2181 <<EOF  
ls /
get /
quit
EOF
```
### 大量watch场景排查

```
#!/bin/bash
rm -f con_ip.txt path_count.txt session_count.txt session_ip.txt watch_path.txt watch_sess.txt

#记录session和watch的path
echo wchc|nc 127.1 2181 > watch_sess.txt

#记录所有的ip连接
echo cons|nc 127.1 2181 > con_ip.txt

#记录session和watch的count数
> session_count.txt
last=1
sesion=$(sed -n '1p' watch_sess.txt)
for i in `grep -n  '^0x' watch_sess.txt |awk -F: '{print $1}'`
do
        if [ $i -eq $last ]
        then
                continue
        fi
        x=$(let last++)
        y=$(let i--)
        let x=last+1
        let y=i-1
        count=$(sed -n ''$x','$y'p' watch_sess.txt|wc -l)
        echo "$sesion $count" >> session_count.txt
        last=$i
        sesion=$(sed -n ''$i'p' watch_sess.txt)
done

#把ip和session关联起来
> session_ip.txt
while read sess count
do
        n=$(grep $sess con_ip.txt -c)
        if [ $n -eq 1 ]
        then
                ip=$(grep $sess con_ip.txt|awk -F: '{print $1}'|sed -n 's# /##p')
        else
                ip="NULL"
        fi
        echo "$count $ip $sess" >> session_ip.txt
done <  session_count.txt

#记录每个path watch的session
echo wchp |nc 127.1 2181 > watch_path.txt

#记录每个path的watch数量
> path_count.txt
last=""
next=""
while read line
do
        if [ $(echo $line|grep '^/' -c) -eq 1 ]
        then
                last=$next
                next=$line
                if [ ${last}x != "x" ]
                then
                        echo "$count $last" >> path_count.txt
                fi
                count=0
        else
                let count++
        fi
done < watch_path.txt
echo "$count $last" >> path_count.txt

#打印watch数最高的Top10 IP列表
awk '{a[$2]+=$1}END{for (i in a)print a[i],i}' session_ip.txt |sort -nr -k1|head

#打印watch数最高的Top10 Path列表
awk '{a[$2]+=$1}END{for (i in a)print a[i],i}' path_count.txt |sort -nr -k1|head 
```
### 将某个IP加入黑名单

```
iptables -I INPUT -s x.x.x.x -p tcp --dport 2181 -j DROP
```


## 一些经验

### 使用建议
- 数据大小不超过500M：
	- 风险：数据过大会导致集群恢复时间过长、GC加重、客户端超时增多
- 单机连接数不超过2w：
	- 风险：连接数过高会导致集群恢复时间过长（zookeeper在选举之前会主动关闭所有的连接，如果这时候不断有新的连接进来会导致zookeeper一直在关闭连接，无法进行选举）
- watch数不超过100w：
	- 风险：watch数过高会影响集群的写入性能
- 不要维护一个超大集群：
	- 风险：稳定性风险高、故障影响面大、运维不可控

### 推荐工具
- 性能压测 [https://github.com/phunt/zk-smoketest](https://github.com/phunt/zk-smoketest)
- watch性能压测 [https://github.com/kevinlynx/zk-benchmark](https://github.com/kevinlynx/zk-benchmark)
- 性能监控 [https://github.com/phunt/zktop](https://github.com/phunt/zktop)
- cli工具 [https://github.com/let-us-go/zkcli](https://github.com/let-us-go/zkcli)
- 抓包工具 [https://github.com/pyinx/zk-sniffer](https://github.com/pyinx/zk-sniffer)
- 数据同步 [https://github.com/ksprojects/zkcopy](https://github.com/ksprojects/zkcopy)
- proxy [https://github.com/pyinx/zk-proxy](https://github.com/pyinx/zk-proxy)

### 推荐文章
- [ZooKeeper Troubleshooting](https://wiki.apache.org/hadoop/ZooKeeper/Troubleshooting)
- [Zookeeper FAQ](http://jm.taobao.org/2013/10/07/zookeeper-faq/)
- [zookeeper节点数与watch的性能测试](http://codemacro.com/2014/09/21/zk-watch-benchmark/)
- [Zookeeper系列文章](https://blog.51cto.com/nileader/1068033)
- [Zookeeper原理与优化](https://yuzhouwan.com/posts/31915/)

## 一点思考

Zookeeper是不是足够稳定了呢，一经部署就不再需要关注了呢？答案当然是否定的，目前运维过程中还存在如下几个痛点问题：

- Zxid溢出
- 不记录事物日志
- ACL不支持节点继承
- 不具备限流能力

面临这些问题，我们该怎么解决呢？

- 针对Zxid溢出的问题，目前官方还没有给出修复方案，详见[JIRA](https://issues.apache.org/jira/browse/ZOOKEEPER-2789)。
- 针对后面三个问题，我开发了一个[proxy](https://github.com/pyinx/zk-proxy)来弥补这块的空缺。目前proxy功能已经开发完成，在我们生产环境稳定运行了2个多月，并集成到了初始化的镜像中。但是proxy还有许多需要完善的地方，ACL的功能还不够完善，希望大家一起提PR。
![](https://github.com/pyinx/zk-proxy/blob/master/images/logging.png?raw=true)
