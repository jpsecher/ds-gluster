# Suite for staging

Plan:

* [x] Default VPC with default subnets in two availability zones.
* [x] One Gluster server with one brick in each AZ, as a replicated storage.
* [ ] One Swarm node in each AZ with Gluster volume mounted.
* [ ] Swarm cluster running "getstarted" app, Redis & Visualizer.
* [ ] Make it possible to extend/shrink the storage cluster.
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

and to `host_vars/storage-worker-x.yml`:

    host_name: ip-yy-yy-yy-yy.eu-west-1.compute.internal

and to `group_vars/all.yml`:

    brick_device: /dev/xvdb

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

and the storage hostname (from the storage tier-0) to `group_vars/all.yml`:

    gluster_name: ip-xx-xx-xx-xx.eu-west-1.compute.internal

Then provision the swarm master:

    $ ansible-playbook -i inventory.ini swarm-master.yml

Copy the output token and IP into `group_vars/workers.yml`:

    worker_token: SWMTKN-1-22dxtbt...
    master_ip: 172.31.6.169

Then provision all the workers:

    $ ansible-playbook -i inventory.ini swarm-worker-1.yml
    $ ansible-playbook -i inventory.ini swarm-worker-2.yml
    $ ...

Check that the swarm is running (see [setup.md](../../setup.md):

    $ export DOCKER_HOST=tcp://localhost:2375
    $ docker node ls

Start the test swarm:

    $ cd ../..
    $ docker stack deploy -c docker-compose.yml mytest

## TODO

- Convert AWS subnet to eg. `173.31.*`
