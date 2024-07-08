import requests
import json

# NSO credentials and URL
nso_url = 'http://10.250.78.80:8081/restconf/data'
headers = {
    'Content-Type': 'application/yang-data+json',
    'Accept': 'application/yang-data+json'
}
auth = ('admin', 'admin')  # Replace with your NSO username and password

# Service payload
service_payload = {
    "bgp-prefix-limit-service:bgp-prefix-limit-service": [
        {
            "name": "my-bgp-service",
            "device": "cml-core-rtr01",
            "neighbors": [
                {
                    "neighbor-address": "192.168.1.1",
                    "remote-as": "65530",
                    "prefix-limit": 200,
                    "prefix-threshold": 80,
                    "description": "Test Neighbor",
                    "ipv4-unicast": {}
                },
                {
                    "neighbor-address": "2001:db8::1",
                    "remote-as": "65531",
                    "prefix-limit": 300,
                    "prefix-threshold": 90,
                    "ipv6-unicast": {}
                }
            ]
        }
    ]
}


# POST the service payload to NSO
response = requests.patch(f'{nso_url}/bgp-prefix-limit-service:bgp-prefix-limit-service', 
                         headers=headers, auth=auth, data=json.dumps(service_payload))

# Check the response
if response.status_code == 204:
    print("Service created successfully")
else:
    print(f"Failed to create service: {response.status_code}")
    print(response.text)
