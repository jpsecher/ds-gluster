# Suite for testing

Plan:

* [x] Default VPC with default subnet in one availability zone.
* [x] One Gluster server with one brick as one volume.
* [ ] One Swarm node with Gluster volume mounted.
* [ ] Run [GDash](http://aravindavk.in/blog/introducing-gdash/) in a container on the swarm.
* [ ] Swarm cluster running "getstarted" app, Redis & Visualizer.

## Tier-0: Storage

    $ cd storage
    $ terraform apply

Copy output values to `ansible/inventory`:

    [testing-storage]
    testing-storage-node  ansible_host=ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com

and to `ansible/host_vars/testing-storage-node.yml`:

    host_name: ip-xx-xx-xx-xx.eu-west-1.compute.internal
    brick_device: /dev/xvdb
    suite: testing

Then provision the machine:

    $ cd ../../../ansible
    $ ansible-playbook -i inventory.ini testing-storage-node.yml

Check that the Gluster volume is up:

    $ ssh -i ~/.ssh/ec2-lundogbendsen-jp.pem ubuntu@ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com
    $ sudo gluster volume info
    $ sudo gluster volume status
    $ exit

## Tier-1: Docker cluster

    $ cd docker-cluster
    $ terraform apply

