# Find Server In SSH-Config File
This Repository contains a script to find the server you want to connect in ssh-config file with the command fs

## fs.sh script:
This script search and finde the hostname in your ssh config file
### How to Use fs.sh file:
1- Make the fs.sh bash script file <br />
2- Run command "chmod +x fs.sh <br />
3- Add the line in the .bashrc file in "~/.bashrc" or "~/.zshrc"<br />
4- Run the command "source ~/.bashrc" or "source ~/.zshrc"
4- Use the command.

## fssh.sh script:
This script find and connect automatically to the host.<br />
### How to use fssh.sh file:
1- Edit the file and set the "ssh_username" value<br />
2- Run command "chmod +x fs.sh" <br />
3- finde your server with command "./fssh.sh <last_two_octets_or_hostname>"<br />
4- If just one host matches, you directly connect to the host, but if multiple hosts match, you can select the hosts and connect to it.<br />