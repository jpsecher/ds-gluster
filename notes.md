New style:

    $ terraform apply

Add `staging-node-01-a` (eg) as a group to `../ansible/inventory.ini` as

    [staging-node-01-a]
    ec2-34-244-240-113.eu-west-1.compute.amazonaws.com

And add to `../ansible/host_vars/ec2-34-244-240-113.eu-west-1.compute.amazonaws.com.yml`

    host_name: ip-172-31-8-117
    private_ip: 172.31.8.117
    brick_device: /dev/xvdb

Start the master:

    $ cd ../ansible
    $ ansible-playbook -i inventory.yml staging-node-01-a.yml







-------------------------------------------------------------------------------

After staging-11-create-swarm-master.yml
==============

ubuntu@ip-172-31-9-15:~$ sudo gluster peer status
Number of Peers: 1

Hostname: ec2-34-244-9-221.eu-west-1.compute.amazonaws.com
Uuid: 80d54d02-8978-480f-aadf-54a1139b20ca
State: Peer in Cluster (Connected)


ubuntu@ip-172-31-9-15:~$ sudo gluster volume info
 
Volume Name: swarm
Type: Replicate
Volume ID: 6798da44-9bbe-4c10-8139-6db3189a8780
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: ec2-34-241-30-9.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0
Brick2: ec2-34-244-9-221.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0
Options Reconfigured:
auth.allow: 127.0.0.1
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off



ubuntu@ip-172-31-9-15:~$ sudo gluster volume status
Status of volume: swarm
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick ec2-34-241-30-9.eu-west-1.compute.ama
zonaws.com:/data/gluster/swarm/brick0       49152     0          Y       4831 
Brick ec2-34-244-9-221.eu-west-1.compute.am
azonaws.com:/data/gluster/swarm/brick0      49152     0          Y       4545 
Self-heal Daemon on localhost               N/A       N/A        Y       4852 
Self-heal Daemon on ec2-34-244-9-221.eu-wes
t-1.compute.amazonaws.com                   N/A       N/A        Y       4566 
 
Task Status of Volume swarm
------------------------------------------------------------------------------
There are no active volume tasks



After -l staging-new-workers staging-01-prepare-shared-data-storage.yml
=============

ubuntu@ip-172-31-9-15:~$ sudo gluster peer status
Number of Peers: 1

Hostname: ec2-34-244-9-221.eu-west-1.compute.amazonaws.com
Uuid: 80d54d02-8978-480f-aadf-54a1139b20ca
State: Peer in Cluster (Connected)


ubuntu@ip-172-31-9-15:~$ sudo gluster volume info
 
Volume Name: swarm
Type: Replicate
Volume ID: 6798da44-9bbe-4c10-8139-6db3189a8780
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: ec2-34-241-30-9.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0
Brick2: ec2-34-244-9-221.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0
Options Reconfigured:
auth.allow: 127.0.0.1
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off



ubuntu@ip-172-31-9-15:~$ sudo gluster volume status
Status of volume: swarm
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick ec2-34-241-30-9.eu-west-1.compute.ama
zonaws.com:/data/gluster/swarm/brick0       49152     0          Y       4831 
Brick ec2-34-244-9-221.eu-west-1.compute.am
azonaws.com:/data/gluster/swarm/brick0      49152     0          Y       4545 
Self-heal Daemon on localhost               N/A       N/A        Y       4852 
Self-heal Daemon on ec2-34-244-9-221.eu-wes
t-1.compute.amazonaws.com                   N/A       N/A        Y       4566 
 
Task Status of Volume swarm
------------------------------------------------------------------------------
There are no active volume tasks


After staging-11-add-worker-to-existing-swarm.yml
===============

TASK [gluster-add-bricks-to-volume : Create Gluster volume] ******
fatal: [ec2-34-241-30-9.eu-west-1.compute.amazonaws.com]: FAILED! => {"changed": true, "cmd": ["gluster", "volume", "add-brick", "swarm", "replica", "3", "ec2-34-244-11-85.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0", "force"], "delta": "0:00:02.141568", "end": "2018-03-20 12:12:44.292037", "msg": "non-zero return code", "rc": 1, "start": "2018-03-20 12:12:42.150469", "stderr": "volume add-brick: failed: Commit failed on ec2-34-244-11-85.eu-west-1.compute.amazonaws.com. Please check log file for details.", "stderr_lines": ["volume add-brick: failed: Commit failed on ec2-34-244-11-85.eu-west-1.compute.amazonaws.com. Please check log file for details."], "stdout": "", "stdout_lines": []}

On "master":

ubuntu@ip-172-31-9-15:~$ sudo gluster peer status
Number of Peers: 2

Hostname: ec2-34-244-9-221.eu-west-1.compute.amazonaws.com
Uuid: 80d54d02-8978-480f-aadf-54a1139b20ca
State: Peer in Cluster (Connected)

Hostname: ec2-34-244-11-85.eu-west-1.compute.amazonaws.com
Uuid: d2b16b49-1fb1-48db-946e-2347ccf2f8c0
State: Peer in Cluster (Connected)


ubuntu@ip-172-31-9-15:~$ sudo gluster volume info
 
Volume Name: swarm
Type: Replicate
Volume ID: 6798da44-9bbe-4c10-8139-6db3189a8780
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 3 = 3
Transport-type: tcp
Bricks:
Brick1: ec2-34-241-30-9.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0
Brick2: ec2-34-244-9-221.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0
Brick3: ec2-34-244-11-85.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0
Options Reconfigured:
auth.allow: 127.0.0.1
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off



ubuntu@ip-172-31-9-15:~$ sudo gluster volume status
Status of volume: swarm
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick ec2-34-241-30-9.eu-west-1.compute.ama
zonaws.com:/data/gluster/swarm/brick0       49152     0          Y       4831 
Brick ec2-34-244-9-221.eu-west-1.compute.am
azonaws.com:/data/gluster/swarm/brick0      49152     0          Y       4545 
Brick ec2-34-244-11-85.eu-west-1.compute.am
azonaws.com:/data/gluster/swarm/brick0      N/A       N/A        N       N/A  
Self-heal Daemon on localhost               N/A       N/A        Y       8609 
Self-heal Daemon on ec2-34-244-9-221.eu-wes
t-1.compute.amazonaws.com                   N/A       N/A        Y       7781 
Self-heal Daemon on ec2-34-244-11-85.eu-wes
t-1.compute.amazonaws.com                   N/A       N/A        Y       4512 
 
Task Status of Volume swarm
------------------------------------------------------------------------------
There are no active volume tasks


On new "worker":

ubuntu@ip-172-31-37-165:~$ sudo gluster peer status
Number of Peers: 2

Hostname: ip-172-31-9-15.eu-west-1.compute.internal
Uuid: 0f31b60f-13e8-4007-88a0-5bbcb6d6609b
State: Peer in Cluster (Connected)

Hostname: ec2-34-244-9-221.eu-west-1.compute.amazonaws.com
Uuid: 80d54d02-8978-480f-aadf-54a1139b20ca
State: Peer in Cluster (Connected)



ubuntu@ip-172-31-37-165:~$ sudo gluster volume info
 
Volume Name: swarm
Type: Replicate
Volume ID: 6798da44-9bbe-4c10-8139-6db3189a8780
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 3 = 3
Transport-type: tcp
Bricks:
Brick1: ec2-34-241-30-9.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0
Brick2: ec2-34-244-9-221.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0
Brick3: ec2-34-244-11-85.eu-west-1.compute.amazonaws.com:/data/gluster/swarm/brick0
Options Reconfigured:
performance.client-io-threads: off
nfs.disable: on
transport.address-family: inet
auth.allow: 127.0.0.1


ubuntu@ip-172-31-37-165:~$ sudo gluster volume status
Status of volume: swarm
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick ec2-34-241-30-9.eu-west-1.compute.ama
zonaws.com:/data/gluster/swarm/brick0       49152     0          Y       4831 
Brick ec2-34-244-9-221.eu-west-1.compute.am
azonaws.com:/data/gluster/swarm/brick0      49152     0          Y       4545 
Brick ec2-34-244-11-85.eu-west-1.compute.am
azonaws.com:/data/gluster/swarm/brick0      N/A       N/A        N       N/A  
Self-heal Daemon on localhost               N/A       N/A        Y       4512 
Self-heal Daemon on ec2-34-244-9-221.eu-wes
t-1.compute.amazonaws.com                   N/A       N/A        Y       7781 
Self-heal Daemon on ip-172-31-9-15.eu-west-
1.compute.internal                          N/A       N/A        Y       8609 
 
Task Status of Volume swarm
------------------------------------------------------------------------------
There are no active volume tasks


Running `sudo gluster volume start myvol force` will bring the new brick online.


ubuntu@ip-172-31-37-165:~$ sudo gluster volume status
Status of volume: swarm
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick ec2-34-241-30-9.eu-west-1.compute.ama
zonaws.com:/data/gluster/swarm/brick0       49152     0          Y       4831 
Brick ec2-34-244-9-221.eu-west-1.compute.am
azonaws.com:/data/gluster/swarm/brick0      49152     0          Y       4545 
Brick ec2-34-244-11-85.eu-west-1.compute.am
azonaws.com:/data/gluster/swarm/brick0      49152     0          Y       4818 
Self-heal Daemon on localhost               N/A       N/A        Y       4839 
Self-heal Daemon on ec2-34-244-9-221.eu-wes
t-1.compute.amazonaws.com                   N/A       N/A        Y       9468 
Self-heal Daemon on ip-172-31-9-15.eu-west-
1.compute.internal                          N/A       N/A        Y       10383
 
Task Status of Volume swarm
------------------------------------------------------------------------------
There are no active volume tasks



















------

On master:

[2018-03-20 09:56:34.699821] I [MSGID: 106482] [glusterd-brick-ops.c:448:__glusterd_handle_add_brick] 0-management: Received add brick req
[2018-03-20 09:56:34.699850] I [MSGID: 106578] [glusterd-brick-ops.c:500:__glusterd_handle_add_brick] 0-management: replica-count is 3
[2018-03-20 09:56:34.699860] I [MSGID: 106481] [glusterd-brick-ops.c:313:gd_addbr_validate_replica_count] 0-management: Changing the replica count of volume swarm from 2 to 3
[2018-03-20 09:56:34.741344] I [run.c:241:runner_log] (-->/usr/lib/x86_64-linux-gnu/glusterfs/4.0.0/xlator/mgmt/glusterd.so(+0x37c85) [0x7f3b06fb6c85] -->/usr/lib/x86_64-linux-gnu/glusterfs/4.0.0/xlator/mgmt/glusterd.so(+0xd72f6) [0x7f3b070562f6] -->/usr/lib/x86_64-linux-gnu/libglusterfs.so.0(runner_log+0x105) [0x7f3b0bd218e5] ) 0-management: Ran script: /var/lib/glusterd/hooks/1/add-brick/pre/S28Quota-enable-root-xattr-heal.sh --volname=swarm --version=1 --volume-op=add-brick --gd-workdir=/var/lib/glusterd
[2018-03-20 09:56:34.741395] I [MSGID: 106578] [glusterd-brick-ops.c:1354:glusterd_op_perform_add_bricks] 0-management: replica-count is set 3
[2018-03-20 09:56:34.741408] I [MSGID: 106578] [glusterd-brick-ops.c:1364:glusterd_op_perform_add_bricks] 0-management: type is set 0, need to change it
[2018-03-20 09:56:34.763146] I [MSGID: 106131] [glusterd-proc-mgmt.c:83:glusterd_proc_stop] 0-management: nfs already stopped
[2018-03-20 09:56:34.763170] I [MSGID: 106568] [glusterd-svc-mgmt.c:229:glusterd_svc_stop] 0-management: nfs service is stopped
[2018-03-20 09:56:34.763786] I [MSGID: 106568] [glusterd-proc-mgmt.c:87:glusterd_proc_stop] 0-management: Stopping glustershd daemon running in pid: 4800
[2018-03-20 09:56:34.765096] W [socket.c:592:__socket_rwv] 0-glustershd: readv on /var/run/gluster/175e7e61b4aa5dc8.socket failed (No data available)
[2018-03-20 09:56:35.765481] I [MSGID: 106568] [glusterd-svc-mgmt.c:229:glusterd_svc_stop] 0-management: glustershd service is stopped
[2018-03-20 09:56:35.765543] I [MSGID: 106567] [glusterd-svc-mgmt.c:197:glusterd_svc_start] 0-management: Starting glustershd service
[2018-03-20 09:56:36.769601] I [MSGID: 106131] [glusterd-proc-mgmt.c:83:glusterd_proc_stop] 0-management: bitd already stopped
[2018-03-20 09:56:36.769666] I [MSGID: 106568] [glusterd-svc-mgmt.c:229:glusterd_svc_stop] 0-management: bitd service is stopped
[2018-03-20 09:56:36.769703] I [MSGID: 106131] [glusterd-proc-mgmt.c:83:glusterd_proc_stop] 0-management: scrub already stopped
[2018-03-20 09:56:36.769715] I [MSGID: 106568] [glusterd-svc-mgmt.c:229:glusterd_svc_stop] 0-management: scrub service is stopped
[2018-03-20 09:56:36.866845] E [MSGID: 106115] [glusterd-mgmt.c:124:gd_mgmt_v3_collate_errors] 0-management: Commit failed on ec2-52-30-223-46.eu-west-1.compute.amazonaws.com. Please check log file for details.
[2018-03-20 09:56:37.969097] E [MSGID: 106122] [glusterd-mgmt.c:1668:glusterd_mgmt_v3_commit] 0-management: Commit failed on peers
[2018-03-20 09:56:37.969133] E [MSGID: 106122] [glusterd-mgmt.c:2201:glusterd_mgmt_v3_initiate_all_phases] 0-management: Commit Op Failed


On new worker:

[2018-03-20 09:56:36.793344] I [run.c:241:runner_log] (-->/usr/lib/x86_64-linux-gnu/glusterfs/4.0.0/xlator/mgmt/glusterd.so(+0x37c85) [0x7f7de426ec85] -->/usr/lib/x86_64-linux-gnu/glusterfs/4.0.0/xlator/mgmt/glusterd.so(+0xd72f6) [0x7f7de430e2f6] -->/usr/lib/x86_64-linux-gnu/libglusterfs.so.0(runner_log+0x105) [0x7f7de8fd98e5] ) 0-management: Ran script: /var/lib/glusterd/hooks/1/add-brick/pre/S28Quota-enable-root-xattr-heal.sh --volname=swarm --version=1 --volume-op=add-brick --gd-workdir=/var/lib/glusterd
[2018-03-20 09:56:36.793383] I [MSGID: 106578] [glusterd-brick-ops.c:1354:glusterd_op_perform_add_bricks] 0-management: replica-count is set 3
[2018-03-20 09:56:36.793396] I [MSGID: 106578] [glusterd-brick-ops.c:1364:glusterd_op_perform_add_bricks] 0-management: type is set 0, need to change it
[2018-03-20 09:56:36.854539] E [MSGID: 106053] [glusterd-utils.c:13863:glusterd_handle_replicate_brick_ops] 0-management: Failed to set extended attribute trusted.add-brick : Transport endpoint is not connected [Transport endpoint is not connected]
[2018-03-20 09:56:36.865926] E [MSGID: 101042] [compat.c:597:gf_umount_lazy] 0-management: Lazy unmount of /tmp/mntq3gy0R [Transport endpoint is not connected]
[2018-03-20 09:56:36.883217] E [MSGID: 106073] [glusterd-brick-ops.c:2590:glusterd_op_add_brick] 0-glusterd: Unable to add bricks
[2018-03-20 09:56:36.883237] E [MSGID: 106122] [glusterd-mgmt.c:312:gd_mgmt_v3_commit_fn] 0-management: Add-brick commit failed.
[2018-03-20 09:56:36.883247] E [MSGID: 106122] [glusterd-mgmt-handler.c:603:glusterd_handle_commit_fn] 0-management: commit failed on operation Add brick
