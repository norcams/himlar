# Test of gitolite mirroring

Read more her first: http://gitolite.com/gitolite/mirroring.html

* Change gitolite::ssh_key and gitolite::admin_user in hieradata/common/modules/gitolite.yaml
* Run bootstrap.sh on vagrant-login-01 and vagrant-login-02 to get ssh keys
* As user git on both host run
```
ssh login01 info
ssh login02 info
```
* Updated gitolite-admin repo with mirroring and push to BOTH git servers. Example gitolite.conf:

```
repo @all
  RW+     =   server-login01
  RW+     =   server-login02

repo gitolite-admin
  RW+     =   raymond
  option mirror.master      = login01
  option mirror.slaves      = login02

repo himlar
  RW+     =   @all
  option mirror.master      = login01
  option mirror.slaves      = login02
  option mirror.redirectOK  = all

repo testing
  RW+     =   @all
```

* Add repo (eg. himlar) and test mirroring. Log files under ~/.gitolite/logs
