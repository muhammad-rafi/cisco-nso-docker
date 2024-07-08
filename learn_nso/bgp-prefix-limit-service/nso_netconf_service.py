from ncclient import manager

# NSO credentials and connection details
nso_host = "10.250.78.80"
nso_port = 830
nso_username = "admin"
nso_password = "admin"

# NETCONF configuration payload
config_payload = """
                <config>
                <bgp-prefix-limit-service xmlns="http://tail-f.com/ns/example">
                    <bgp-prefix-limit-service>
                    <name>my-bgp-service</name>
                    <device>cml-core-rtr01</device>
                    <neighbors>
                        <neighbor>
                        <neighbor-address>192.168.1.1</neighbor-address>
                        <remote-as>65530</remote-as>
                        <prefix-limit>200</prefix-limit>
                        <prefix-threshold>80</prefix-threshold>
                        <description>Test Neighbor</description>
                        <ipv4-unicast/>
                        </neighbor>
                        <neighbor>
                        <neighbor-address>2001:db8::1</neighbor-address>
                        <remote-as>65531</remote-as>
                        <prefix-limit>300</prefix-limit>
                        <prefix-threshold>90</prefix-threshold>
                        <ipv6-unicast/>
                        </neighbor>
                    </neighbors>
                    </bgp-prefix-limit-service>
                </bgp-prefix-limit-service>
                </config>
                """

# Configure NSO using NETCONF
with manager.connect(
    host=nso_host,
    port=nso_port,
    username=nso_username,
    password=nso_password,
    hostkey_verify=False
) as m:
    # Sending the NETCONF payload to NSO
    response = m.edit_config(target='running', config=config_payload)
    print(response)


# from ncclient import manager
# import xml.dom.minidom

# # NSO device details
# nso_device = {
#     'host': '10.250.78.80',
#     'port': 830,
#     'username': 'admin',
#     'password': 'admin',
#     'hostkey_verify': False
# }

# # NETCONF XML payload to configure BGP Prefix Limit Service
# config_template = """
# <config>
#   <bgp-prefix-limit-service xmlns="http://tail-f.com/ns/example">
#     <name>my-bgp-service</name>
#     <device>cml-core-rtr01</device>
#     <neighbors>
#       <neighbor>
#         <neighbor-address>192.168.1.1</neighbor-address>
#         <remote-as>65530</remote-as>
#         <prefix-limit>200</prefix-limit>
#         <prefix-threshold>80</prefix-threshold>
#         <description>Test Neighbor</description>
#         <ipv4-unicast/>
#       </neighbor>
#       <neighbor>
#         <neighbor-address>2001:db8::1</neighbor-address>
#         <remote-as>65531</remote-as>
#         <prefix-limit>300</prefix-limit>
#         <prefix-threshold>90</prefix-threshold>
#         <ipv6-unicast/>
#       </neighbor>
#     </neighbors>
#   </bgp-prefix-limit-service>
# </config>
# """

# def pretty_print_xml(xml_str):
#     return xml.dom.minidom.parseString(xml_str).toprettyxml()

# def configure_nso_with_netconf():
#     try:
#         with manager.connect(**nso_device) as m:
#             # Sending the configuration to the NSO device
#             response = m.edit_config(target='running', config=config_template)

#             # Printing the response
#             print('Configuration response:')
#             print(pretty_print_xml(response.xml))
#     except Exception as e:
#         print(f"An error occurred: {e}")

# if __name__ == '__main__':
#     configure_nso_with_netconf()
