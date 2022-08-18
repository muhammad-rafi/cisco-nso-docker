
Login to NSO CLI mode from the NSO bash `ncs_cli -C -u admin`
```
root@nso:~# ncs_cli -C -u admin

User admin last logged in 2022-07-13T15:19:15.750392+00:00, to nso, from 127.0.0.1 using cli-console
admin connected from 127.0.0.1 using console on nso
admin@ncs# 
```
for more commands with ncs_cli, try with --help flag; 
```
root@nso:~# ncs_cli --help 
```

session variables in the CLI
admin@ncs# show cli

You can run these command and display in json, xml some other available formats appending with " | display xml", " | display json". 
e.g 

```bash
admin@ncs# show packages package package-version | display xml
admin@ncs# show packages package package-version | display json
admin@ncs# show packages package package-version | display xpath 
admin@ncs# show packages package package-version | display restconf
```

Check the details of installed network element drivers (NEDs) and other service packages
admin@ncs# show packages

Check the installed network element drivers (NEDs) and other packages versions 
admin@ncs# show packages package package-version 

Check packages operational status
admin@ncs# show packages package * oper-status 

Check the package templates  
admin@ncs# show packages package templates

Check the python service packages
admin@ncs# show packages package python-package

Show list of device along with NED and admin state
admin@ncs# show devices list

Show list of device along with version, serial number, model and licence etc. 
admin@ncs# show devices device live-status version

Show devices operational data and configuration data
admin@ncs# show devices device

Show device operational data and configuration data for the specific device e.g. cml-cat8000v
admin@ncs# show devices device cml-cat8000v

Show states for the device
admin@ncs# show devices device state 

Show states for the specific device e.g. cml-cat8000v
admin@ncs# show devices device cml-cat8000v state 

Show list of the YANG modules implemented by the specific device e.g. cml-cat8000v
admin@ncs# show devices device cml-cat8000v module 

