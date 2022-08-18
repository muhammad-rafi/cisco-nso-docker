# Create NSO `python-and-template` service package

### What is NSO Service Package 

NSO Packages contain data models and code for a specific function. It might be a NED for a specific device, a service application like MPLS VPN, a WebUI customization package etc. Packages can be added, removed and upgraded in run-time.

In this example, I am going to create `python-and-template` based service pacakge for Loopack Interface service, named `nso-loopback-service`, however there are some other options available to create a service package. You can check out the other service package options with below command using `-h` or `--help` flag.

```bash
root@nso:~/ncs-instance/packages# ncs-make-package --help
```

Let's create Loopback Interface Service `nso-loopback-service` using `python-and-template`.

__Step1: Login to NSO or connect to the NSO docker container.

```bash
(.venv) expert@expert-cws:~$ docker exec -it a9472af3bcaf bash
root@nso:~# 
```

__Step2: Go to your NSO instance and then packages folder.

```bash
root@nso:~# cd ncs-instance/packages/
root@nso:~/ncs-instance/packages# 
```

__Step1: Run ncs-make-package with --service-skeleton which generates boilerplate service
package code.__

```bash
root@nso:~/ncs-instance/packages# ncs-make-package --service-skeleton python-and-template nso-loopback-service
root@nso:~/ncs-instance/packages# ls -l
total 8
lrwxrwxrwx 1 root root   46 May 31 12:13 cisco-ios-cli-6.69 -> /root/nso-5.5/packages/neds/cisco-ios-cli-6.69
lrwxrwxrwx 1 root root   45 May 31 12:13 cisco-nx-cli-5.21 -> /root/nso-5.5/packages/neds/cisco-nx-cli-5.21
drwxr-xr-x 6 root root 4096 Jun  4 11:46 loopback-service
drwxr-xr-x 6 root root 4096 Jun  6 17:35 nso-loopback-service