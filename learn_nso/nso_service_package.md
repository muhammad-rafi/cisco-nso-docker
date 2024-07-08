# Create NSO `python-and-template` service package

### What is NSO Service Package 

NSO Packages contain data models and code for a specific function. It might be a NED for a specific device, a service application like MPLS VPN, a WebUI customization package etc. Packages can be added, removed and upgraded in run-time.

In this example, I am going to create `python-and-template` based service package for BGP Max Prefix Limit, named as `bgp-prefix-limit-service`, however there are some other options available to create a service package. You can check out the other service package options with below command using `-h` or `--help` flag.

```sh
[root@devnetbox ~]# ncs-make-package --help
```

Let's create Loopback Interface Service `nso-loopback-service` using `python-and-template`.

__Step1: Login to NSO or connect to the NSO docker container.__

```sh
[root@devnetbox ~]# docker exec -it cisco-nso-dev bash
root@cisco-nso-dev:~# 
```

__Step2: Run ncs-make-package with --service-skeleton which generates boilerplate service package code.__

`ncs-make-package --no-java --service-skeleton python-and-template <package-name> --dest DIR`
 or 
`ncs-make-package --service-skeleton python-and-template <package-name>`

ncs-make-package --no-java --service-skeleton python-and-template bgp-prefix-limit-service --dest ${NCS_RUN_DIR}/packages/bgp-prefix-limit-service

make sure you have already created this environment variable ${NCS_RUN_DIR} which could be '~/nso-instance', but in my case I have it as '~/ncs-instance'

```sh
root@cisco-nso-dev:~# ncs-make-package --no-java --service-skeleton python-and-template bgp-prefix-limit-service --dest ${NCS_RUN_DIR}/packages/bgp-prefix-limit-service
root@cisco-nso-dev:~# 
root@cisco-nso-dev:~# ls -l ncs-instance/packages/
total 0
drwxr-xr-x. 6 root root 103 Jul  4 10:21 bgp-prefix-limit-service
lrwxrwxrwx. 1 root root  46 Jun 17 11:54 cisco-asa-cli-6.18 -> /root/nso-6.3/packages/neds/cisco-asa-cli-6.18
lrwxrwxrwx. 1 root root  47 Jun 17 11:54 cisco-ios-cli-6.106 -> /root/nso-6.3/packages/neds/cisco-ios-cli-6.106
lrwxrwxrwx. 1 root root  48 Jun 17 11:54 cisco-iosxr-cli-7.55 -> /root/nso-6.3/packages/neds/cisco-iosxr-cli-7.55
lrwxrwxrwx. 1 root root  45 Jun 17 11:54 cisco-nx-cli-5.25 -> /root/nso-6.3/packages/neds/cisco-nx-cli-5.25
drwxr-xr-x. 6 root root  91 Jun 18 16:31 loopback-service
root@cisco-nso-dev:~# 
```

As you can see new package 'bgp-prefix-limit-service' has been created, let's see the file structure for the package using 'tree'

```sh
root@cisco-nso-dev:~# tree ${NCS_RUN_DIR}/packages/bgp-prefix-limit-service
/root/ncs-instance/packages/bgp-prefix-limit-service
|-- README
|-- package-meta-data.xml
|-- python
|   `-- bgp_prefix_limit_service
|       |-- __init__.py
|       `-- main.py
|-- src
|   |-- Makefile
|   `-- yang
|       `-- bgp-prefix-limit-service.yang
|-- templates
|   `-- bgp-prefix-limit-service-template.xml
`-- test
    |-- Makefile
    `-- internal
        |-- Makefile
        `-- lux
            |-- Makefile
            `-- service
                |-- Makefile
                |-- dummy-device.xml
                |-- dummy-service.xml
                |-- pyvm.xml
                `-- run.lux

9 directories, 15 files
root@cisco-nso-dev:~# 
```




not finished yet, will be working on it soon ...

## Reference: 

_[Python Scripts and NSO Service Development](https://developer.cisco.com/learning/labs/service-dev-201/introduction/)_

_[Create Cisco NSO service ](https://yang-prog-lab.ciscolive.com/pod/0/nso/create_service)_

_[LABSPG-2442-LG]https://www.ciscolive.com/c/dam/r/ciscolive/emea/docs/2018/pdf/LABSPG-2442-LG.pdf_