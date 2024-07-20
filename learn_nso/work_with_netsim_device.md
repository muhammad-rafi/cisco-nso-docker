# Explore netsim device

### Go to your NSO instance folder

```bash
root@nso:~# cd ncs-instance/
root@nso:~/ncs-instance# 
```

### Create two `netsim` ios devices `R0 and R1`
**note**: You may use your own netsim devices if you have created before.

```bash
root@nso:~/ncs-instance# ncs-netsim create-network packages/cisco-ios-cli-6.69 2 R
DEVICE R0 CREATED
DEVICE R1 CREATED
root@nso:~/ncs-instance# 
```

Next, we need to start these `netsim` devices by using `ncs-netsim start` command.

### Start `netsim` devices `R0 and R1`

```bash
root@nso:~/ncs-instance# ncs-netsim start
DEVICE R0 OK STARTED
DEVICE R1 OK STARTED
root@nso:~/ncs-instance# 
```

You can see the devices are started in above output.

### Login to `netsim` devices

Let's login to one of the device `R0` and run 'show version and show run'

```bash
root@nso:~/ncs-instance# ncs-netsim cli-i R0

admin connected from 127.0.0.1 using console on nso
R0> en
R0# show run
tailfned police cirmode
no service password-encryption
aaa accounting delay-start
no cable admission-control preempt priority-voice
no cable qos permission create
no cable qos permission update
no cable qos permission modems
ip source-route
no ip gratuitous-arps
no ip cef
ip finger
no ip http server
no ip http secure-server
no ip forward-protocol nd
no ipv6 cef
no dot11 syslog
interface Loopback0
 no shutdown
 ip address 127.0.0.1 255.0.0.0
exit
interface Ethernet0/0/0
 no shutdown
 no switchport
 no ip address
exit
interface FastEthernet0
 no shutdown
 no switchport
 no ip address
exit
interface FastEthernet0/0
 no shutdown
 no switchport
 no ip address
exit
interface FastEthernet1/0
 no shutdown
 no switchport
 no ip address
exit
interface FastEthernet1/1
 no shutdown
 no switchport
 no ip address
exit
interface GigabitEthernet0
 no shutdown
 no switchport
 no ip address
exit
interface GigabitEthernet0/0
 no shutdown
 no switchport
 no ip address
exit
interface GigabitEthernet0/1
 no shutdown
 no switchport
 no ip address
exit
R0# show version
Cisco IOS Software, NETSIM
R0# 

```

You can see it has very basic configuration, but you can work with these devices for testing purpose, so Lets add a `loopback 100` interface on this device.

### Create a `Loopback 100` interface 

```bash
R0# conf t
Enter configuration commands, one per line. End with CNTL/Z.
R0(config)# 
R0(config)# interface Loopback 100
R0(config-if)# ip address 10.100.10.1 255.255.255.0
R0(config-if)# description netsim device loopback
R0(config-if)# end
R0# 

```

Now, let's see if the `loopback 100` interface exists, but before that, let's check what commands available under 'show ' command, since netsim devices are virtual, so you may not able to run all the show commands. e.g. 'show ip interface brief' not available, so we will need to do something like this 'show running-config | begin loopback'

```bash
R0# show running-config | begin loopback
 description netsim device loopback
 no shutdown
 ip address 10.100.10.1 255.255.255.0
exit
interface Ethernet0/0/0
 no shutdown
 no switchport
 no ip address
exit
interface FastEthernet0
 no shutdown
 no switchport
 no ip address
exit
interface FastEthernet0/0
 no shutdown
 no switchport
 no ip address

... output eliminated 

```

You can see `loopback 100` is configured sucessfully. This is a starting point and you can explore more by yourself. The other good thing about these devices, you can even test your service packages as well. I will cover that in my other post. 

Before you go, let's remove the loopback interfaces we created earlier

### Delete `Loopback 100` interface 

```bash
R0# conf t
Enter configuration commands, one per line. End with CNTL/Z.
R0(config)# no interface Loopback 
  0      
  100    netsim device loopback
  <cr>   
R0(config)# no interface Loopback 100
R0(config)# end
R0# write memory 
R0# 

```
