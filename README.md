# Re-SyncMysqlMasterSlaveReplication
How to Reset (Re-Sync) MySQL Master-Slave Replication

Prerequisites:

1) this tool must be run on master server

2) ssh access to both servers (master & slave)

2) ssh access from master to slave using ssh without pass (google: ssh without password)
	
	Some help at this point.
	Use ssh to login to your server under the account name you want to use. 
	When prompting for passphrase hit enter.
	
	Steps:
	
	On master server:

		root@master-server$ cd ~/.ssh
		root@master-server$ ssh-keygen
		root@master-server$ ssh-copy-id -i ~/.ssh/id_rsa.pub slave-server
		# test connection
		root@master-server$ ssh slave-server
		
	If do not work, please google for some tutorial

