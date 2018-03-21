# Swarm 1

Objective: Deploy a Docker Swarm from scratch on AWS where

* there is persistent storage via GlusterFS.
* there is secrets management via Vault.

## Plan

* [x] Get connection to newly created AWS account, output availability zones, etc.
* [x] Provision two Ubuntu EC2s in default VPC with Terraform.
* [x] Provision a cluster of two Ubuntu machines with Ansible so that they run a Swarm cluster.
* [x] Be able to deploy a hello-world service and Swarm Visualizer on the swarm.
* [ ] Provision the cluster with GlusterFS as underlying data store.
* [ ] Make sure that the system is resilient to taking arbitrary nodes down.
* [ ] Provision a docker container that can simulate backup of files from a whitelist.
* [ ] Provision Vault with Ansible.
* [ ] Let the hello-world service use Vault to get access to the database.

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

To avoid specifying the key all the time, put the location of the private key in `ansible/ansible.cfg` like

    [defaults]
    private_key_file = /Users/jps/.ssh/ec2-lundogbendsen-jp.pem

Prepare shared data storage:

    $ export ANSIBLE_HOST_KEY_CHECKING=False
    $ ansible-playbook -i inventory.ini staging-01-prepare-shared-data-storage.yml

Connect the nodes into a Trusted Storage Pool and start the cluster:

    $ ansible-playbook -i inventory.ini staging-11-create-swarm-master.yml

Copy the token and IP from the output into `group_vars/staging-workers`. Then start all workers:

    $ ansible-playbook -i inventory.ini staging-12-create-swarm-workers.yml

To see that it is working, make a SSH tunnel (in a new terminal) to one of the nodes:

    $ ssh -i ~/.ssh/ec2-lundogbendsen-jp.pem -N -L 2375:/var/run/docker.sock ubuntu@ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com

And check that the cluster is running:

    $ cd ..
    $ export DOCKER_HOST=tcp://localhost:2375
    $ docker node ls

## Creating a stack

    $ docker stack deploy -c docker-compose.yml mytest

## Taking down the stack

    $ docker stack rm mytest

## Scaling up

Increase the number of nodes in `terraform/variables.tf` and run `terraform plan` to verify that everything looks ok.  Then `terraform apply` to actually create the new instance.

Add the IPs of the newly created instance to `ansible/inventory.ini` group `staging-new-workers`: (It should be empty initially)

    $ cd ../ansible
    $ edit inventory.ini

Then provision only the new instance:

    $ ansible-playbook -i inventory.ini -l staging-new-workers staging-01-prepare-shared-data-storage.yml
    $ ansible-playbook -i inventory.ini staging-11-add-worker-to-existing-swarm.yml

Now that the new host is ready to be a worker, *copy* it in `ansible/inventory.ini` from group `staging-new-workers` to group `staging-workers`, and add it (only) to the swarm:

    $ ansible-playbook -i inventory.ini -l staging-new-workers staging-12-create-swarm-workers.yml

Finally remove the new hosts from `ansible/inventory.ini` group `staging-new-workers`.

## Scaling down

Start by changing the Terraform spec and do a `terraform plan` to find out which host would be taken down if applied.  Them use that host in the following.

First drain the swarm node:

    $ docker node ls
    $ docker node update --availability drain 0hl18vnlus36szv9cvafpiwze

Then SSH into that particular node, and make it leave the swarm:
    $ ssh ...
    $ docker swarm leave
    $ exit

Remove the stopped node from the swarm:

    $ docker node rm 0hl18vnlus36szv9cvafpiwze

Then, remove the brick from the Gluster volume:

    $ ssh ...
    $ sudo gluster volume remove-brick swarm replica 2 ec2-34-244-9-221.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0 force

Finally take the server down.

## Todo

* On each host: sudo touch /var/lib/cloud/instance/locale-check.skip
* Only open
    * 7946 TCP/UDP for container network discovery.
    * 4789 UDP for the container ingress network.
    * 49152 TCP for GlusterFS. See https://www.jamescoyle.net/how-to/457-glusterfs-firewall-rules
* How to bypass host fingerprint warning from Ansible? ANSIBLE_HOST_KEY_CHECKING=False
* Check out ansible `--with-registry-auth`.
* Ansible role for common Apt stuff: HTTPS, update.

## Trouble shooting

To see the state of services:

    $ docker service ls

To see full error messages

    $ docker service ps --no-trunc mytest_visualizer

### Gluster

    $ sudo gluster peer status
    $ sudo gluster volume info myvol
    $ sudo gluster volume status myvol
    $ sudo gluster volume heal myvol info
    $ sudo gluster volume start swarm force

"Already part of a volume": https://www.jamescoyle.net/how-to/2234-glusterfs-error-volume-add-brick-failed-pre-validation-failed-on-brick-is-already-part-of-a-volume
