#### BACKUP DAEMON MANUAL ####

For Your Reading Pleaseure,
- Spencer Foster
- 02/12/2024

1.)
Q: What if i run 'df -h' and nothing is mounted??
A: try the following:
	- sudo mount -t cifs //<SERVER_IP>/<SERVER_SHARE_DIR> /path/to/backup -o username=<share_user_name>,password=<share_user_password>
	EXAMPLE:
	- sudo mount -t cifs //10.37.3.16/log /Backup/Remote_Dir/ -o username=isadmin,password='AbC!1@4'
