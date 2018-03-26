# Initial setup on your local computer

## AWS

Tell terraform to use a specific AWS account (which of course must already be setup with AWS API key etc.):

    $ export AWS_PROFILE=lundogbendsen

## Ansible

To avoid specifying the key all the time, put the location of the private key in `ansible.cfg` like

    [defaults]
    private_key_file = /Users/jps/.ssh/ec2-lundogbendsen-jp.pem

And stop Ansible asking for confirmation about hosts all the time:

    $ export ANSIBLE_HOST_KEY_CHECKING=False

## Docker

To interact with Docker (Swarm), make a SSH tunnel (in a separate terminal) to one of the swarm nodes:

    $ ssh -i ~/.ssh/ec2-lundogbendsen-jp.pem -N -L 2375:/var/run/docker.sock \
          ubuntu@ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com

And tell Docker to use that tunnel:

    $ export DOCKER_HOST=tcp://localhost:2375
