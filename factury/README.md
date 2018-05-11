# Setup
in order to add a new node to the factury network you will need:
* machine with fresh ubuntu install
* a postgres database running on an external host
  - the database superuser should be named postgres
* optionally a history archive such as amazon s3

there is a script in this directory called add-one.sh
this script will ask you the following questions:
* `number` - if you are not launching a pre-configured node then write here 0 (zero)
* `db_password` - this is the password for postgres user
* `db_host` - endpoint for machine that hosts the database
* `seed` - if you are launching a pre-configured node you CAN NOT use any random seed
* `aws_access_key_id` - if you do not intend to use aws s3 for archiving then write here anything
* `aws_secret_access_key` - if you do not intend to use aws s3 for archiving then write here anything

when you are prompted to edit the stellar-core configuration file there are two scenarios:
* you are seting up a new network.
    in this case you should put ip addresses of other nodes in `KNOWN_PEERS`
    you might need to reconfigure the history archives
* you want to join the existing network.
    make sure you are editing factury0.cfg
    in this case you can leave `KNOWN_PEERS` unchanged
    the config file itself provides further instructions
    to configure quorum set see end of the following file `https://github.com/stellar/stellar-core/blob/master/docs/stellar-core_example.cfg`
    if you do not intend to have a history archive then you can remove the `h0` entry however you should not remove other entries

if you are bootstraping a new network some of the nodes should be run with `--forcescp` flag set. Most likely you just want to press enter.

last part of the script tries to change the root password and remove ubuntu from sudo group for extra security. if you do not want this then you can kill the script with CTRL-C

now the node should be up and running. it will take some time for it to catch up and sync with the network.

this script is NOT intended to be run multiple times. See the next section on how to administrate your node.

# Administration

The script you ran built a docker container that in turn runs stellar-core, horizon and a zabbix agent.
The ports 11625, 8000 and 10050 that corespond to stellar core peer port, horizon api port and zabbix agent port are exposed to the host machine.
These processes within docker are managed by supervisor (supervisord.org).
All administration will happen from within the docker container so first you have to connect to it. You might need to escalate your privilages.
`
su root
docker exec -it node0 /bin/bash
`
To change your stellar-core configuration stop stellar core with supervisor. Then change the config file and then start stellar core with supervisor.
`
supervisorctl stop stellar-core
vim /opt/stellar/core/etc/factury0.cfg
supervisorctl start stellar-core
`
changing horizons configuration is simmilar
`
supervisorctl stop horizon
vim /opt/stellar/horizon/etc/horizon.env
supervisorctl start horizon
`
