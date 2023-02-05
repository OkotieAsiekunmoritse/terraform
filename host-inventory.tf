3.80.100.100
34.201.221.137
44.203.28.249

#Reassign the ip ansible public_ip addresses to new names and features 
minip-1 ansible_host=3.80.100.100 ansible_ssh_user=ubuntu ansible_ssh_private_key=project_key.pem
minip-2 ansible_host=34.201.221.137 ansible_ssh_user=ubuntu ansible_ssh_private_key=project_key.pem
minip-3 ansible_host=44.203.28.249 ansible_ssh_user=ubuntu ansible_ssh_private_key=project_key.pem

[apache]
minip-1
minip-2
minip-3
