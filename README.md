# enumai
Simple and smart script does the basic enumeration of any kind of open ports along with screenshots.



Download these two files:
#enumai.sh
#aicmd.config

#Here's how you can use this script:
Put both two files in a folder.
Put the list of ip address in a separate  file and give it a name.
Run the terminal with 'ROOT' user and navigate to the folder where it has been copied in step 1.
Run the this command: ./enumai.sh
When prompted for input, give the file name as copied in step 2.



#How to use the config file for adding/changin commands or scripts

aicmd.config file contain all the commands to run specific enumeration on a port number. Also this file can be updated easily.
Each command is separated by "@" symbol. 
For example:
Port 1433 , here's how you can Change it:

1433@nmap -p$port -Pn --script=nfs-ls $ip | grep "|"@nmap -p$port -Pn --script=nfs-statfs $ip | grep "|"@showmount -e $ip

And if you wanna add any Nmap scripts/commands you can write into this file like this:

1433@nmap -p$port -Pn --script=nfs-ls $ip | grep "|"@nmap -p$port -Pn --script=nfs-statfs $ip | grep "|"@showmount -e $ip@nmap -p$port -Pn --script=nfs-showmount $ip | grep "|"

Remember to add "@" symbol at the end of each command.


# Credits
Abhijit Maity
Wasim Halani
