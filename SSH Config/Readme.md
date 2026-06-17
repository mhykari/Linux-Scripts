# Useful scripts to find server in SSH-Config file
This Repository contains a script to find the server you want to connect in ssh-config file with the command fs

## 1- Find and connect to the servers using SSH-Config by fs.sh script:
This script search and finde the hostname in your ssh config file
### How to Use fs.sh file:
1- Create the fs.sh bash script file <br />
2- Run command "chmod +x fs.sh" <br />
3- Add "export PATH=$PATH:path/to/script" to the .bashrc file ("~/.bashrc" or "~/.zshrc")<br />
4- Run the command "source ~/.bashrc" or "source ~/.zshrc"
5- Use the the script with the command "fs something"  
  
## 2- Find and connect to the servers using SSH-Config by fssh.sh script:
This script find and connect automatically to the host.<br />
  
### How to use fssh.sh file:
1- Edit the file and set the "ssh_username" value<br />
2- Run command "chmod +x fssh.sh" <br />
3- Finde your server with directly run script "./fssh.sh <last_two_octets_or_hostname>" or use "fssh <last_two_octets_or_hostname>" command if you have added the path of script to .bashrc file by adding "export PATH=$PATH:path/to/script" to the .bashrc file <br />
4- If just one host matches, you directly connect to the host, but if multiple hosts match, you can select the hosts and connect to it.<br />
