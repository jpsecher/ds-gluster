# Swarm 1

Objective: Deploy a Docker Swarm from scratch on AWS where

* there is secrets management via Vault.
* there is persistent storage via GlusterFS.

## Plan

* [x] Get connection to newly created AWS account, output availability zones, etc.
* [x] Provision two Ubuntu EC2s in default VPC with Terraform.
* [x] Provision a cluster of two Ubuntu machines with Ansible so that they run a Swarm cluster.
* [x] Be able to deploy a hello-world service and Swarm Visualizer on the swarm.
* [ ] Provision Vault with Ansible.
* [ ] Let the hello-world service use Vault to get access to the database.
* [ ] Provision the cluster with GlusterFS as underlying data store.
* [ ] Make sure that the system is resilient to taking arbitrary nodes down.
* [ ] Provision a docker container that can simulate backup of files from a whitelist.

See

* https://hackernoon.com/setup-docker-swarm-on-aws-using-ansible-terraform-daa1eabbc27d
* https://docs.docker.com/get-started/

## Creating a cluster

    $ cd terraform
    $ export AWS_PROFILE=lundogbendsen
    $ terraform apply

Copy the `cluster-nodes` from the Terraform output to `../ansible/inventory.ini`, the first host as master, the rest as workers:

    $ cd ../ansible
    $ edit inventory.ini

Then start the cluster:

    $ ansible-playbook -i inventory.ini --private-key=~/.ssh/ec2-lundogbendsen-jp.pem staging-create-swarm-master.yml

Copy the token and IP from the output into `group_vars/staging-workers`. Then start all workers:

    $ ansible-playbook -i inventory.ini --private-key=~/.ssh/ec2-lundogbendsen-jp.pem staging-create-swarm-workers.yml

Or, to avoid specifying the key all the time, put the location of the private key in `ansible/ansible.cfg` like

    [defaults]
    private_key_file = /Users/jps/.ssh/ec2-lundogbendsen-jp.pem

To see that it is working, make a SSH tunnel (in a new terminal):

    $ ssh -i ~/.ssh/ec2-lundogbendsen-jp.pem -N -L 2375:/var/run/docker.sock ubuntu@ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com

And check that the cluster is running:

    $ cd ..
    $ export DOCKER_HOST=tcp://localhost:2375
    $ docker node ls

## Creating a stack

    $ export DOCKER_HOST=tcp://localhost:2375
    $ docker stack deploy -c docker-compose.yml getstartedlab

## Taking down the stack

    $ export DOCKER_HOST=tcp://localhost:2375
    $ docker stack rm getstartedlab

## Todo

* Only open
    * 7946 TCP/UDP for container network discovery.
    * 4789 UDP for the container ingress network.
* How to bypass host fingerprint warning from Ansible? ANSIBLE_HOST_KEY_CHECKING=False
* Check out ansible `--with-registry-auth`.
* Ansible role for common Apt stuff: HTTPS, update.

## Trouble shooting

To see the state of services:

    $ docker service ls

To see full error messages

    $ docker service ps --no-trunc getstartedlab_visualizer
