# Suite for testing

Plan:

* [x] Default VPC with default subnet in one availability zone.
* [x] One Gluster server with one brick as one volume.
* [x] One Swarm node with Gluster volume mounted.
* [ ] Run [GDash](http://aravindavk.in/blog/introducing-gdash/) in a container on the swarm. https://hub.docker.com/r/kawaz/gdash ?
* [x] Swarm cluster running "getstarted" app, Redis & Visualizer.

## Initial setup

See [setup.md](../setup.md).

## Tier-0: Storage

    $ cd storage
    $ terraform apply

Copy output values to `inventory.ini`:

    [storage]
    storage-node  ansible_host=ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com

and to `host_vars/storage-node.yml`:

    host_name: ip-xx-xx-xx-xx.eu-west-1.compute.internal
    brick_device: /dev/xvdb

Then provision the machine:

    $ ansible-playbook -i inventory.ini storage-node.yml

Check that the Gluster volume is up:

    $ ssh -i ~/.ssh/ec2-lundogbendsen-jp.pem ubuntu@ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com
    $ sudo gluster volume info
    $ sudo gluster volume status
    $ exit

## Tier-1: Docker cluster

    $ cd docker-cluster
    $ terraform apply

Copy output values to `inventory.ini`:

    [swarm]
    swarm-node  ansible_host=ec2-yy-yy-yy-yy.eu-west-1.compute.amazonaws.com

and to `host_vars/swarm-node.yml`:

    host_name: ip-yy-yy-yy-yy.eu-west-1.compute.internal

and to `group_vars/swarm.yml`:

    gluster_name: ip-xx-xx-xx-xx.eu-west-1.compute.internal

Then provision the machine:

    $ ansible-playbook -i inventory.ini swarm-node.yml

Check that the swarm is running (see [setup.md](../../setup.md):

    $ export DOCKER_HOST=tcp://localhost:2375
    $ docker node ls

## TODO

- Convert AWS subnet to eg. `173.31.*`
