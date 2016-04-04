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
| 52.37.171.67 | 2200 |

## Preparations

Because I already have experience with CFEngine and Puppet for configuration
management, for this project I wanted to use a tool that's new for me. As I've
heard a lot of good things about Ansible, I decided to learn Ansible this time.

### Install Ansible

With `brew` in OS X, installing Ansible is done like this:

```
$ brew install ansible
```

### DNS settings

For convenience, I've added a CNAME-record to the DNS settings of my domain, so
the Virtual Machine can be reached at address `catalog.silwesterveld.com`:

```
$ host catalog.silwesterveld.com
catalog.silwesterveld.com has address 52.37.171.67
catalog.silwesterveld.com is an alias for ec2-52-37-171-67.us-west-2.compute.amazonaws.com.
```

### Limit access to VM

I've made an Ansible playbook that will prepare the VM with a sudo-user `deploy`
as the only user that will be granted access. It will configure the SSH server
to disable root login, disable password authentication, and listen on port 2200.
UFW will be configured to only accept incoming traffic on port 2200.

```
$ ansible-playbook --inventory-file=inventory.ini prepare.yml  

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

TASK [port 2200 (for SSH) is open in UFW] **************************************
changed: [catalog.silwesterveld.com]

RUNNING HANDLER [SSH restart] **************************************************
changed: [catalog.silwesterveld.com]

PLAY RECAP *********************************************************************
catalog.silwesterveld.com  : ok=10   changed=8    unreachable=0    failed=0 
```

## Software Installed

## Configuration Changes

## Third-Party Resources
