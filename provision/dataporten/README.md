# Test of FEIDE connect

To test this use HIMLAR_NODESET=connect

Make sure you have two FEIDE connect appliactions her:
https://dashboard.feideconnect.no

### Dataporten Application

Client ID and secrets go into:
* provision/dataporten/app/oauth_client_id
* provision/dataporten/app/oauth_client_secret

### Openstack Keystone

Client ID and secrets + passphrase go into:
hieradata/secrets/vagrant-master-box.secrets.yaml

See hieradata/common/modules/keystone.yaml for options

## Step 1:

* Make sure master and db is running.
* On master go to /opt/himlar/provision/dataporten and run:
```
./setup.sh personal
```

## Step 2:

First make sure dpapp is running and then go to /opt/himlar/provision/dataporten/app and run:
```
./bootstrap.sh
./config.sh
```
To start the application go to /var/www/dataporten and run
```
bin/pserve production.init
```
