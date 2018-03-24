# Suite for testing

Plan:

* [x] Default VPC with default subnet in one availability zone.
* [x] One Gluster server with one brick as one volume.
* [ ] One Swarm node with Gluster volume mounted.
* [ ] Run [GDash](http://aravindavk.in/blog/introducing-gdash/) in a container on the swarm.
* [ ] Swarm cluster running "getstarted" app, Redis & Visualizer.

## Tier-0: Storage

    $ export AWS_PROFILE=lundogbendsen
    $ cd storage
    $ terraform apply

Copy output values to `ansible/testing/inventory.ini`:

    [storage]
    storage-node  ansible_host=ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com

and to `ansible/testing/host_vars/storage-node.yml`:

    host_name: ip-xx-xx-xx-xx.eu-west-1.compute.internal
    brick_device: /dev/xvdb

Then provision the machine:

    $ cd ../../../ansible/testing/
    $ ansible-playbook -i inventory.ini testing-storage-node.yml

Check that the Gluster volume is up:

    $ ssh -i ~/.ssh/ec2-lundogbendsen-jp.pem ubuntu@ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com
    $ sudo gluster volume info
    $ sudo gluster volume status
    $ exit

## Tier-1: Docker cluster

    $ cd docker-cluster
    $ terraform apply

Copy output values to `ansible/testing/inventory.ini`:

    [swarm]
    swarm-node  ansible_host=ec2-yy-yy-yy-yy.eu-west-1.compute.amazonaws.com

and to `ansible/testing/host_vars/swarm-node.yml`:

    host_name: ip-yy-yy-yy-yy.eu-west-1.compute.internal

and to `ansible/testing/group_vars/swarm.yml`:

    gluster_name: ip-xx-xx-xx-xx.eu-west-1.compute.internal

Then provision the machine:

    $ cd ../../../ansible/testing/
    $ ansible-playbook -i inventory.ini swarm-node.yml



## TODO

- Share plugins: https://github.com/hashicorp/terraform/issues/15949
- Convert AWS subnet to eg. `173.31.*`
