# Project "Conference Organization App"

This is the result I achieved for ***[Udacity Full Stack Web Developer Nanodegree](https://www.udacity.com/course/nd004) - Project 5: Linux Server Configuration***.
For this project I've taken a baseline installation of a Linux distribution on
a virtual machine and prepared it to host the [Catalog App project](https://github.com/swesterveld/udacity-nd004-p3-item-catalog/)
from earlier in the Nanodegree program.

The project has been *reviewed by me*. According to me, based on the rubric used
by the Udacity reviewer, this code at least:
- [x] Meets Specifications: (User Management) Remote login of the root user has
      been disabled, a remote user that can sudo to root has been defined, user
      passwords are set securely.
- [x] Exceeds Specifications: (Security) The firewall has been configured to
      monitor for repeat unsuccessful login attempts and appropriately bans
      attackers; cron scripts have been included to automatically manage
      package updates.
- [x] Exceeds Specifications: (Application Functionality) The VM included
      monitoring applications that provide automateed feedback on application
      availability status and/or system security alerts.
- [x] Meets Specifications: (Configuration File Comments) Comments are present
      and effectively explain longer code procedures.
- [x] Meets Specifications: (Documentation) A README file is included detailing
      all steps required to successfully run the application.

## Development Environment

For reviewing -- upon graduation form the Nanodegree program -- this project is
running in a development environment. This environment is on an Amazon AWS EC2
instance accessible by the reviewer.

| IP address   | port |
| :---         | :--- |
| 52.38.220.68 | 2200 |

The grader can login to this machine by issuing the following command:

```
$ ssh grader@catalog.silwesterveld.com -p 2200 -i <rsa_key>
```

Instead of `<rsa_key>`, the grader should substitute it with the full path of
the RSA key I provided when handing in the project (for example
`~/.ssh/id_rsa_grader`).

## Preparations

Because I already have experience with CFEngine and Puppet for configuration
management, for this project I wanted to use a tool that's new for me. As I've
heard a lot of good things about Ansible, I decided to learn Ansible this time.

My idea was to have a separate user `deploy` on the VM that will be used by
Ansible for the provisioning of the VM and deployment of the Catalog app.

### Install Ansible

I'm using OS X with `brew` as my package manager. Installing Ansible with
`brew` has been done like this:

```
$ brew install ansible
```

### Make key pairs for users

Ansible should connect to the VM as user `deploy`, with key based
authentication. Therefore I've created a key pair on my local machine:

```
$ ssh-keygen -t rsa -b 4096 -C "Ansible User"
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/me/.ssh/id_rsa): id_rsa_ansible
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in id_rsa_ansible.
Your public key has been saved in id_rsa_ansible.pub.
The key fingerprint is:
SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Ansible User
The key's randomart image is:
+---[RSA 4096]----+
|          xxxxx x|
|         xxxxxxxx|
|         xxxxxxxx|
|       xxxx xxxx |
|        xx xxxx  |
|            xxx  |
|            x x  |
|           x x   |
|            x    |
+----[SHA256]-----+
```

I did the same to create a key pair for the `grader` user.

### DNS and SSH settings

For convenience, I've added a CNAME-record to the DNS settings of my domain, so
the Virtual Machine can be reached at address `catalog.silwesterveld.com`:

```
$ host catalog.silwesterveld.com
catalog.silwesterveld.com has address 52.38.220.68
catalog.silwesterveld.com is an alias for ec2-52-38-220-68.us-west-2.compute.amazonaws.com.
```

To make it possible for non-interactive scripts to connect with the host, I've
once connected with it manualy, so the host will be added to the
`~/.ssh/known_hosts` file:

```
$ ssh -i ~/.ssh/udacity_key.rsa root@52.38.220.68
The authenticity of host '52.38.220.68 (52.38.220.68)' can't be established.
ECDSA key fingerprint is MD5:bb:f0:46:17:66:a8:e2:1f:48:db:ec:22:d2:5e:8b:88.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '52.38.220.68' (ECDSA) to the list of known hosts.
```

### Limit access to VM

I've made an Ansible playbook that will prepare the VM with a sudo-user `deploy`
as the only user that will be granted access. It will configure the SSH server
to disable root login, disable password authentication, and listen on port 2200.
UFW will be configured to only accept incoming traffic on port 2200.

The playbook is called [prepare.yml](https://github.com/swesterveld/udacity-nd004-p5-linux-server-configuration/blob/master/ansible/prepare.yml),
and it's runned with the inventory file [inventory_prepare.ini](https://github.com/swesterveld/udacity-nd004-p5-linux-server-configuration/blob/master/ansible/inventory_prepare.ini)
to make it run on the VM. When the playbook is run for the first time, it'll give
you the following output:

```
$ ansible-playbook --inventory-file=inventory_prepare.ini prepare.yml

PLAY [Prepare host for deployments by deploy user only] ************************

TASK [setup] *******************************************************************
ok: [catalog.silwesterveld.com]

TASK [the deploy user exists] **************************************************
changed: [catalog.silwesterveld.com]

TASK [the deploy user has authorized keys] *************************************
changed: [catalog.silwesterveld.com]

TASK [the deploy user can sudo] ************************************************
changed: [catalog.silwesterveld.com]

TASK [root login is disabled] **************************************************
changed: [catalog.silwesterveld.com]

TASK [password authentication is disabled] *************************************
ok: [catalog.silwesterveld.com]

TASK [SSH is listening on port 2200] *******************************************
changed: [catalog.silwesterveld.com]

TASK [UFW is installed] ********************************************************
ok: [catalog.silwesterveld.com]

TASK [UFW is enabled with policy to deny by default] ***************************
changed: [catalog.silwesterveld.com]

TASK [port 2200 (for SSH) is open in UFW] **************************************
changed: [catalog.silwesterveld.com]

RUNNING HANDLER [SSH restart] **************************************************
changed: [catalog.silwesterveld.com]

PLAY RECAP *********************************************************************
catalog.silwesterveld.com  : ok=11   changed=8    unreachable=0    failed=0
```

It takes about half a minute until this playbook is finished. After these
preparations, all the required deployments are done by a different playbook.

## Deployment

The playbook to complete the deployment takes a couple of minutes to complete. It
is stored in [deploy.yml](https://github.com/swesterveld/udacity-nd004-p5-linux-server-configuration/blob/master/ansible/deploy.yml)
and is run with the inventory [inventory_deploy.ini](https://github.com/swesterveld/udacity-nd004-p5-linux-server-configuration/blob/master/ansible/inventory_deploy.ini)
to make sure it's targeted at port 2200 of the VM. The following output will give
you an idea of all the steps it takes to get the machine provisioned according to
the requirements specified in the project:

```
$ time ansible-playbook --inventory-file=inventory_deploy.ini deploy.yml --user=deploy --private-key=~/.ssh/id_rsa_ansible --sudo; say deployed

PLAY [Perform Basic Configuration] *********************************************

TASK [setup] *******************************************************************
ok: [catalog.silwesterveld.com]

TASK [hostname set to catalog.silwesterveld.com] *******************************
changed: [catalog.silwesterveld.com]

TASK [hosts file configured with catalog.silwesterveld.com] ********************
changed: [catalog.silwesterveld.com]

TASK [user grader exists] ******************************************************
changed: [catalog.silwesterveld.com]

TASK [user grader has authorized keys] *****************************************
changed: [catalog.silwesterveld.com]

TASK [user grader can sudo] ****************************************************
changed: [catalog.silwesterveld.com]

TASK [APT package cache up-to-date] ********************************************
ok: [catalog.silwesterveld.com]

TASK [packages upgraded] *******************************************************
changed: [catalog.silwesterveld.com]

TASK [timezone set to Etc/UTC] *************************************************
ok: [catalog.silwesterveld.com]

TASK [timezone data reconfigured] **********************************************
skipping: [catalog.silwesterveld.com]

PLAY [Secure Server] ***********************************************************

TASK [setup] *******************************************************************
ok: [catalog.silwesterveld.com]

TASK [SSH is listening on port 2200] *******************************************
ok: [catalog.silwesterveld.com]

TASK [root login is disabled] **************************************************
ok: [catalog.silwesterveld.com]

TASK [password authentication is disabled] *************************************
ok: [catalog.silwesterveld.com]

TASK [key-based authentication is enforced] ************************************
ok: [catalog.silwesterveld.com]

TASK [UFW is installed] ********************************************************
ok: [catalog.silwesterveld.com]

TASK [UFW is enabled with policy to deny by default] ***************************
ok: [catalog.silwesterveld.com]

TASK [incoming traffic allowed on port 2200 (for SSH)] *************************
ok: [catalog.silwesterveld.com]

TASK [incoming traffic allowed on port 80 (HTTP)] ******************************
changed: [catalog.silwesterveld.com]

TASK [incoming traffic allowed on port 123 (NTP)] ******************************
changed: [catalog.silwesterveld.com]

TASK [packages for extra security measures installed] **************************
changed: [catalog.silwesterveld.com]

TASK [unattended upgrades configured] ******************************************
changed: [catalog.silwesterveld.com]

TASK [Postfix configured to relay email for Logwatch] **************************
changed: [catalog.silwesterveld.com] => (item={u'vtype': u'string', u'question': u'postfix/mailname', u'value': u'catalog.silwesterveld.com'})
changed: [catalog.silwesterveld.com] => (item={u'vtype': u'string', u'question': u'postfix/mail_mailer_type', u'value': u'Internet Site'})

TASK [Logwatch configured for daily log summary] *******************************
changed: [catalog.silwesterveld.com]

PLAY [Install Application] *****************************************************

TASK [setup] *******************************************************************
ok: [catalog.silwesterveld.com]

TASK [Apache with mod_wsgi installed] ******************************************
changed: [catalog.silwesterveld.com]

TASK [mod_wsgi enabled] ********************************************************
ok: [catalog.silwesterveld.com]

TASK [packages needed for Catalog App installed] *******************************
changed: [catalog.silwesterveld.com]

TASK [PyPI package oauth2client installed] *************************************
changed: [catalog.silwesterveld.com]

TASK [PyPI package requests installed] *****************************************
ok: [catalog.silwesterveld.com]

TASK [Git installed] ***********************************************************
changed: [catalog.silwesterveld.com]

TASK [Catalog App project cloned] **********************************************
changed: [catalog.silwesterveld.com]

TASK [Catalog App synchronized to docroot] *************************************
changed: [catalog.silwesterveld.com -> catalog.silwesterveld.com]

TASK [path to client_secrets.json patched] *************************************
changed: [catalog.silwesterveld.com]

TASK [client_secrets.json patched] *********************************************
changed: [catalog.silwesterveld.com]

TASK [WSGI set up for Beer Catalog website] ************************************
changed: [catalog.silwesterveld.com]

TASK [host configuration created for Beer Catalog website] *********************
changed: [catalog.silwesterveld.com]

TASK [default site configuration disabled] *************************************
changed: [catalog.silwesterveld.com]

TASK [site configuration for Beer Catalog website enabled] *********************
changed: [catalog.silwesterveld.com]

TASK [PostgreSQL installed] ****************************************************
changed: [catalog.silwesterveld.com]

TASK [user for database beercatalog set up] ************************************
changed: [catalog.silwesterveld.com]

TASK [database beercatalog set up] *********************************************
changed: [catalog.silwesterveld.com]

RUNNING HANDLER [Restart Apache2] **********************************************
changed: [catalog.silwesterveld.com]

RUNNING HANDLER [Initialize Catalog Database] **********************************
changed: [catalog.silwesterveld.com]

PLAY RECAP *********************************************************************
catalog.silwesterveld.com  : ok=43   changed=29   unreachable=0    failed=0
```

## Enable app in Google Developer dashboard

To let users correctly log in, I've added the address of the Virtual Machine
(`http://catalog.silwesterveld.com`) as an authorized URI.

## References

The references I've used for this project are mainly Ansible's pages about their
modules. The whole list can be found in the [references.txt](https://github.com/swesterveld/udacity-nd004-p5-linux-server-configuration/blob/master/references.txt) file.
