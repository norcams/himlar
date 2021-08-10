url = 'https://report.nrec.no/api/v1/instance'
headers = {'Content-Type': 'application/json',
           'Accept': 'application/json'}

r = requests.post(url, headers=headers, data=json.dumps(payload))
print(r.status_code)
