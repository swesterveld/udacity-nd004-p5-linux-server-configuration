# Project "Conference Organization App"

This is the result I achieved for ***[Udacity Full Stack Web Developer Nanodegree](https://www.udacity.com/course/nd004) - Project 5: Linux Server Configuration***.
For this project I've taken a baseline installation of a Linux distribution on
a virtual machine and prepared it to host the [Catalog App project](https://github.com/swesterveld/udacity-nd004-p3-item-catalog/)
from earlier in the Nanodegree program.

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

### DNS settings

For convenience, I've added a CNAME-record to the DNS settings of my domain, so
the Virtual Machine can be reached at address `catalog.silwesterveld.com`:

```
$ host catalog.silwesterveld.com
catalog.silwesterveld.com has address 52.38.60.164
catalog.silwesterveld.com is an alias for ec2-52-38-60-164.us-west-2.compute.amazonaws.com.
```

### Limit access to VM

I've made an Ansible playbook that will prepare the VM with a sudo-user `deploy`
as the only user that will be granted access. It will configure the SSH server
to disable root login, disable password authentication, and listen on port 2200.
UFW will be configured to only accept incoming traffic on port 2200.

```
$ ansible-playbook --inventory-file=inventory_prepare.ini prepare.yml

PLAY [Prepare host for deployments by deploy user only] ************************

TASK [setup] *******************************************************************
The authenticity of host '52.38.60.164 (52.38.60.164)' can't be established.
ECDSA key fingerprint is MD5:a3:32:e6:e7:08:42:2f:88:02:ef:d1:d6:ea:16:2f:14.
Are you sure you want to continue connecting (yes/no)? yes
ok: [catalog.silwesterveld.com]

TASK [the deploy user is existing] *********************************************
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

TASK [UFW is enabled with policy to deny by default] ***************************
changed: [catalog.silwesterveld.com]

TASK [incoming traffic allowed on port 2200 (for SSH)] *************************
changed: [catalog.silwesterveld.com]

RUNNING HANDLER [SSH restart] **************************************************
changed: [catalog.silwesterveld.com]

PLAY RECAP *********************************************************************
catalog.silwesterveld.com  : ok=10   changed=8    unreachable=0    failed=0 
```

## Deployment

```
$ ansible-playbook --inventory-file=inventory_deploy.ini deploy.yml --user=deploy --private-key=~/.ssh/id_rsa_ansible --sudo

PLAY [Perform Basic Configuration] *********************************************

TASK [setup] *******************************************************************
ok: [catalog.silwesterveld.com]

TASK [hostname set to catalog.silwesterveld.com] *******************************
changed: [catalog.silwesterveld.com]

TASK [hosts file configured with catalog.silwesterveld.com] ********************
changed: [catalog.silwesterveld.com]

TASK [user grader exists] ******************************************************
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

PLAY RECAP *********************************************************************
catalog.silwesterveld.com  : ok=14   changed=28   unreachable=0    failed=0
```

## Software Installed

## Configuration Changes

## Third-Party Resources
