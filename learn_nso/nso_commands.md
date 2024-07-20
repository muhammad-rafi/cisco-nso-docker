# Some Useful Commands for the NSO

Start NSO Instance 

Go the instance and start/reload NSC instance 
# cd ncs-instance or cd nso-instance
# ncs
# ncs --foreground 
# ncs --foreground --verbose
# ncs --reload

Check NSO/NCS Logs
`tail -f ncs-instance/logs/ncs.log`

Source the ncsrc file in the NSO installation directory to set up a local environment
```shell
$ source ~/nso-6.0/ncsrc
```

Check NSO status
`ncs --status`

```shell
root@cisco-nso-dev:/# ncs --status | grep status
status: started
        db=running id=33 priority=1 path=/ncs:devices/device/live-status-protocol/device-type
root@cisco-nso-dev:/# 
```

```shell
root@cisco-nso-dev:/# ncs_cli -C -u admin

admin connected from 127.0.0.1 using console on cisco-nso-dev
admin@ncs# 
admin@ncs# 
admin@ncs# show ncs-state
```

Login to NSO CLI mode from the NSO bash `ncs_cli -C -u admin`

```shell
root@nso:~# ncs_cli -C -u admin

User admin last logged in 2022-07-13T15:19:15.750392+00:00, to nso, from 127.0.0.1 using cli-console
admin connected from 127.0.0.1 using console on nso
admin@ncs# 
```

For more commands with ncs_cli, try with --help flag; 
```shell
root@nso:~# ncs_cli --help 
```

admin@ncs# show cli

You can run these command and display in json, xml some other available formats appending with " | display xml", " | display json". 
e.g 

```s
admin@ncs# show packages package package-version | display xml
admin@ncs# show packages package package-version | display json
admin@ncs# show packages package package-version | display xpath 
admin@ncs# show packages package package-version | display restconf
```

Check the details of installed network element drivers (NEDs) and other service packages
```s
admin@ncs# show packages
```

Check the installed network element drivers (NEDs) and other packages versions 
```s
admin@ncs# show packages package package-version 
```

Check packages operational status
```s
admin@ncs# show packages package * oper-status 
```

Check the package templates  
```s
admin@ncs# show packages package templates
```

Check the python service packages
```s
admin@ncs# show packages package python-package
```

Show list of device along with NED and admin state
```s
admin@ncs# show devices list
```

Show list of device along with version, serial number, model and licence etc. 
```s
admin@ncs# show devices device live-status version
```

Show devices operational data and configuration data
```s
admin@ncs# show devices device
```

Show device operational data and configuration data for the specific device e.g. cml-cat8000v
```s
admin@ncs# show devices device cml-cat8000v
```

Show states for the device
```s
admin@ncs# show devices device state 
```

Show states for the specific device e.g. cml-cat8000v
```s
admin@ncs# show devices device cml-cat8000v state 
```

Show list of the YANG modules implemented by the specific device e.g. cml-cat8000v
```s
admin@ncs# show devices device cml-cat8000v module 
```

To check the xpath for the configuration, you may need for `when` and `must` statemnts when building a yang model for the service package.

```s
admin@ncs(config)# show full-configuration devices device cml-iosv config ios:interface GigabitEthernet | display xpath
```

```s
admin@ncs(config)# show full-configuration devices device cml-iosv config ios:interface GigabitEthernet | display xpath | display prefixes
```

Find the xpath in enable mode 
```s
admin@ncs# show running-config devices device cml-iosv config interface | display xpath 
admin@ncs# show running-config devices device cml-iosv config interface | display xpath | display prefixes 
admin@ncs# show running-config devices device | display xpath
```

## Reference: 

[The NSO CLI](https://developer.cisco.com/docs/nso/guides/#!the-nso-cli/the-nso-cli)

[NSO System Management](https://developer.cisco.com/docs/nso/guides/nso-system-management/#nso-system-management)

[Running NSO Examples](https://developer.cisco.com/docs/nso/guides/running-nso-examples/#running-nso-examples)
