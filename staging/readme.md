# Suite for staging

Plan:

* [x] Default VPC with default subnets in two availability zones.
* [x] One Gluster server with one brick in each AZ, as a replicated storage.
* [x] One Swarm node in each AZ with Gluster volume mounted.
* [x] Swarm cluster running "getstarted" app, Redis & Visualizer.
* [ ] Make it possible to extend/shrink the storage, cluster server-wise.
* [ ] Make it possible to extend/shrink the storage, storage-wise.
* [ ] Limit security group ingres to be as tight as possible.
* [ ] Use dedicated VPC (instead of default).

## Initial setup

See [setup.md](../setup.md).

## Tier-0: Storage

    $ cd storage
    $ terraform apply

Copy output values to `inventory.ini`:

    [master]
    storage-master  ansible_host=ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.co

    [workers]
    storage-worker-1  ansible_host=ec2-yy-yy-yy-yy.eu-west-1.compute.amazonaws.com
    storage-worker-2  ansible_host=ec2-zz-zz-zz-zz.eu-west-1.compute.amazonaws.com

and to `host_vars/storage-master.yml`:

    host_name: ip-xx-xx-xx-xx.eu-west-1.compute.internal

and to all `host_vars/storage-worker-x.yml`:

    host_name: ip-yy-yy-yy-yy.eu-west-1.compute.internal

and to `group_vars/all.yml`:

    brick_devices: /dev/xvdb,/dev/xvdc

and to `group_vars/workers.yml`:

    master_host_name: ip-xx-xx-xx-xx.eu-west-1.compute.internal

### Workers

For each of the workers:

    $ ansible-playbook -i inventory.ini storage-worker-nn.yml

### Master

Then provision the master:

    $ ansible-playbook -i inventory.ini storage-master.yml

Check that the Gluster volume is up:

    $ ssh -i ~/.ssh/ec2-lundogbendsen-jp.pem ubuntu@ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com
    $ sudo gluster volume info
    $ sudo gluster volume status
    $ exit

## Tier-1: Docker cluster

    $ cd docker-cluster
    $ terraform apply

Copy output values to `inventory.ini`:

    [master]
    swarm-master  ansible_host=ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com

    [workers]
    swarm-worker-1  ansible_host=ec2-yy-yy-yy-yy.eu-west-1.compute.amazonaws.com
    swarm-worker-2  ansible_host=ec2-zz-zz-zz-zz.eu-west-1.compute.amazonaws.com

and the storage hostname (from the storage master in tier-0) to `group_vars/all.yml`:

    gluster_name: ip-xx-xx-xx-xx.eu-west-1.compute.internal

(TODO: Find out whether it makes a difference when each swarm node connects directly to the Gluster server in the same AZ.)

Then provision the swarm master:

    $ ansible-playbook -i inventory.ini swarm-master.yml

Copy the output token and IP into `group_vars/workers.yml`:

    worker_token: SWMTKN-1-22dxtbt...
    master_ip: 172.31.6.169

Then provision all the workers:

    $ ansible-playbook -i inventory.ini swarm-worker-1.yml
    $ ansible-playbook -i inventory.ini swarm-worker-2.yml
    $ ...

Check that the swarm is running (see [setup.md](../../setup.md)):

    $ export DOCKER_HOST=tcp://localhost:2375
    $ docker node ls

Start the test swarm:

    $ cd ../..
    $ docker stack deploy -c docker-compose.yml mytest

## Change the swarm  

### Shrink the swarm 

To drain a node in the swarm is running (see [setup.md](../../setup.md):

    $ export DOCKER_HOST=tcp://localhost:2375
    $ docker node ls
    $ docker node update --avilability drain xyz
    $ docker node update --avilability pause xyz

(It does not seem to be needed, but you can SSH into the drained node and `docker swarm leave` to make it go into status Down.)

Remove the drained node from the swarm by decreasing the Terraform variable `swarm-cluster-zones` in `docker-cluster/variables.tf`, and then rerun terraform.

    $ cd  staging/docker-cluster
    $ terraform plan
    $ terraform apply

Then remove the node

    $ docker node rm xyz

Finally, remove the Ansible files and Terraform lines in `docker-cluster/variables.yml` to reflect the new number of hosts.  Check with terraform plan.

### Expand the swarm 

To add a node to the swarm, edit the `docker-cluster/variables.yml` to reflect the settings of the new node: Increase the "number of zones" (TODO: should be called "zone spread"), and add a new line to the instance and type maps.  Then do a terraform plan to check the setting of the new node, and the an apply.  Finally follow the above instructions and add a new Ansible file for the new worker.

## Change the storage

First add a new gluster server with the appropriate size disk, by changing (or adding) lines in `storage/variables.yml`.

To take one of the storage bricks down, comment out the node in `storage/inventory.ini` and run

    $ ansible-playbook -i inventory.ini storage-master.yml

Log into the Gluster master and remove the brick from the first server to be updated:

    $ sudo gluster volume remove-brick swarm replica 2 ip-zz-zz-zz-zz.eu-west-1.compute.internal:/data/gluster/swarm/brick0 force



## TODO

- Convert AWS subnet to eg. `173.31.*` for Gluster allow.
