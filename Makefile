Init:
	terraform apply -auto-approve 
	sleep (60)
	terraform output sshKey >> id_rsa
	ssh-keygen -f id_rsa -e -m pem >> sshKey.pem
	chmod -777 sshKey.pem
	chmod 400 sshKey.pem
	
	#ssh-keygen -f sshKey.pub -e -m pem >> sshKey.pem
	

Connect: 
	 ssh -i "sshKey.pem" ubuntu@