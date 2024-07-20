## Install pyang on Cisco NSO 

pyang is a Python-based YANG data modeling language validator and converter. It is normally used to work with YANG models, which are used to define the structure of data for network configuration management and operations.

- Validation: Pyang checks YANG models for syntax and semantic errors.
- Conversion: It can convert YANG models to different formats like YIN, tree diagrams, and other readable formats.
- Code Generation: Pyang can generate code from YANG models for different programming languages and APIs.
- Extensibility: Pyang supports plugins that can extend its functionality.

You can install 'pyang' by simply running the `pip install pyang`, however it is recommended to use via Github clone to get the up to date version of pyang. 

To install 'pyang' via Github, follow the steps below.

Before you start, you may also notice that 'pyang' is already installed in Cisco NSO and using the binary from the NSO. However, once we install the 'pyang' via Github, the path will change. 

```sh
root@cisco-nso-dev:~# which pyang 
/root/nso-6.3/bin/pyang
root@cisco-nso-dev:~# 
```

1. git clone https://github.com/mbj4668/pyang.git

```sh
root@cisco-nso-dev:~# git clone https://github.com/mbj4668/pyang.git
Cloning into 'pyang'...
remote: Enumerating objects: 13149, done.
remote: Counting objects: 100% (1039/1039), done.
remote: Compressing objects: 100% (496/496), done.
remote: Total 13149 (delta 618), reused 844 (delta 503), pack-reused 12110
Receiving objects: 100% (13149/13149), 9.04 MiB | 13.11 MiB/s, done.
Resolving deltas: 100% (8907/8907), done.
root@cisco-nso-dev:~# 
```

2. Set the Python path environment variable 
export PYTHONPATH=/usr/local/lib/_{python version}_/site-packages`

for example in my case, I am using python3.10
`export PYTHONPATH=/usr/local/lib/python3.10/site-packages`

You may notice, current `PYTHONPATH` is set to the NSO installation folder 

```sh
root@cisco-nso-dev:~/pyang# echo $PYTHONPATH
/root/pyang:/root/nso-6.3/src/ncs/pyapi
root@cisco-nso-dev:~/pyang# 
```

```sh
root@cisco-nso-dev:~# export PYTHONPATH=/usr/local/lib/python3.10/site-packages
root@cisco-nso-dev:~# echo $PYTHONPATH
/usr/local/lib/python3.10/site-packages
root@cisco-nso-dev:~# 
```

You may also add variable this into your `.bashrc` file to avoid setting every time when you start new session to NSO.

3. Go to the 'pyang' directory where you clone the pyang via Github and set the following environment variable or source it from the `env.sh` file already exist in the 'pyang' directory.

export PATH=$PWD/bin:$PATH
export MANPATH=$PWD/man:$MANPATH
export PYTHONPATH=$PWD:$PYTHONPATH
export YANG_MODPATH=$PWD/modules:$YANG_MODPATH
export PYANG_XSLT_DIR=$PWD/xslt
export PYANG_RNG_LIBDIR=$PWD/schema

I am going to be sourcing it from the `env.sh` file here.

```sh
root@cisco-nso-dev:~# cd pyang 
root@cisco-nso-dev:~/pyang# ls -l | grep env
-rw-r--r--.  1 root root   416 Jul 10 10:58 env.sh
root@cisco-nso-dev:~/pyang# cat env.sh 
#!/bin/sh

# source this file to get environment setup for the
# pyang below here

export PATH="$PWD/bin:$PATH"
export MANPATH="$PWD/man:$MANPATH"
export PYTHONPATH="$PWD:$PYTHONPATH"
export YANG_MODPATH="$PWD/modules:$YANG_MODPATH"
export PYANG_XSLT_DIR="$PWD/xslt"
export PYANG_RNG_LIBDIR="$PWD/schema"
export PYANG="$PWD/bin/pyang"
export W="$PWD"
root@cisco-nso-dev:~/pyang# 
root@cisco-nso-dev:~/pyang# source env.sh
```

Verify the variables are set correctly.

```sh 
root@cisco-nso-dev:~/pyang# echo $PATH
/root/pyang/bin:/root/nso-6.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
root@cisco-nso-dev:~/pyang# echo $MANPATH
/root/pyang/man:/root/nso-6.3/man:/usr/share/man
root@cisco-nso-dev:~/pyang# echo $PYTHONPATH
/root/pyang:/usr/local/lib/python3.10/site-packages
root@cisco-nso-dev:~/pyang# echo $YANG_MODPATH
/root/pyang/modules:
root@cisco-nso-dev:~/pyang# echo $PYANG_XSLT_DIR
/root/pyang/xslt
root@cisco-nso-dev:~/pyang# echo $PYANG_RNG_LIBDIR
/root/pyang/schema
root@cisco-nso-dev:~/pyang# 
```

Make sure, now 'pyang' is being used via correct binary, as you can see 'pyang' is pointed to different path than initially when we run the `which python` and `which pyang` command.

```sh
root@cisco-nso-dev:~/pyang# which python
/usr/local/bin/python
root@cisco-nso-dev:~/pyang# which pyang
/root/pyang/bin/pyang
root@cisco-nso-dev:~/pyang#
```

NOTE: You may also add the `source /root/pyang/env.sh` on your `.bashrc` file and source it from it. After replacing the `$PWD` variable with the actual path you clone the 'pyang' module.

cat <<EOF > env.sh
export PATH="/root/pyang/bin:$PATH"
export MANPATH="/root/pyang/man:$MANPATH"
export PYTHONPATH="/root/pyang:$PYTHONPATH"
export YANG_MODPATH="/root/pyang/modules:$YANG_MODPATH"
export PYANG_XSLT_DIR="/root/pyang/xslt"
export PYANG_RNG_LIBDIR="/root/pyang/schema"
export PYANG="/root/pyang/bin/pyang"
EOF

echo "source /root/pyang/env.sh" >> ~/.bashrc
source ~/.bashrc

```sh
root@cisco-nso-dev:~/pyang# echo "source /root/pyang/env.sh" >> ~/.bashrc
root@cisco-nso-dev:~/pyang# source ~/.bashrc
root@cisco-nso-dev:~/pyang# 
```

Here the environmental variable you may find in your NSO `.bashrc` file.

```sh
source /root/nso-6.3/ncsrc
export NCS_RUN_DIR=/root/ncs-instance
export NCS_RUN_DIR=${HOME}/ncs-instance
export PYTHONPATH=/usr/local/lib/python3.10/site-packages
source /root/pyang/env.sh
```


#### Reference:
https://github.com/mbj4668/pyang.git

