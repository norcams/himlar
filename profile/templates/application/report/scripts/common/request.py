url = '<%= @report_api_url %>'
headers = {'Content-Type': 'application/json',
           'Accept': 'application/json'}

r = requests.post(url, headers=headers, data=json.dumps(payload))
print(r.status_code)
