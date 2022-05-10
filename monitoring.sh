#!/bin/bash

arc=$(uname -a) #displays system information, -a for all -v for machine os
pcpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l) #grep searches for "physical id" in the cpu info, sort prints out info in the physical id lines and uniq removes repeated lines/info, wc counts and prints the number of lines -l
vcpu=$(grep "^processor" /proc/cpuinfo | wc -l) #searches for lines containing processor and counts the lines, prints them.
fram=$(free -m | awk '$1 == "Mem:" {print $2}') #free finds the total amount of physical and swap memory,  -m for MB. awk will search the columns of info in the row 'Mem:' and will print information in the second column 2 (the total memory used)
uram=$(free -m | awk '$1 == "Mem:" {print $3}') #will print info in column 3 of 'Mem:' row (this is the used memory)
pram=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}') #takes the info pro column 2 and 3 and will print the percentage of used memory from total to two decimal points
fdisk=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}') #df displays the disks, and how the memory used on each, looks for the /dev/ disks and ignores the /boot disk (grep -v), awk takes column 2, adds the amount from all the rows of /dev and prints
udisk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}') #grabs the information of /dev disks from column 3, the available storage and adds it all together (-Bm in megabytes) and prints info.
pdisk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {printf("%d"), ut/ft*100}') #finds and adds all info in column 2 and 3, then prints the percentage total of info from column 3 in 2 (used storage compared to free)
cpul=$(top -bn1 | grep '^%Cpu' | awk '{printf("%.1f%%", (100.0-$8)%100)}') #top displays processor activity in real time of most cpu intensive tasks on the system -bn1 finds enters bath mode, runs for 1 iteration (n1). grep searches for the %Cpu column for information, awk prints the cpu load to one decimal place, finding the most recent cpu load and taking it away from 100, then finding the modulus of 100, givng the percent.
lb=$(who -b | awk '$1 == "system" {print $3 " " $4}') #who finds user and when they logged in, who -b finds when the system was booted. column with system is assigned the first column, we then find column 3 and 4 , date and time, and print them.
lvmt=$(lsblk | grep "lvm" | wc -l) #lsblk produces a list of the partitions/disks, grep finds the ones using lvm and wc -l counts the lines
lvmu=$(if [ $lvmt -eq 0 ]; then echo no; else echo yes; fi) #finds if lvmt is 0, no lvm is inuse, echos no, vice versa.
#You need to install net tools for the next step [$ sudo apt install net-tools]
ctcp=$(ss -s | grep "TCP:" | tr ',' ' ' | awk '{print($4)}') #ss shows socket statistics, the row containing the TCP connections is highlighted, tr deletes the commas and white space in the TCP row, and the value in the 4th column is printed.
ulog=$(users | wc -w) #counts the amount of users, should be the only one logged in
ip=$(hostname -I) #finds and prints the ip address attached to the hostname of the machine
mac=$(ip link show | awk '$1 == "link/ether" {print $2}') #shows the media access control address of the server, starts with row with "link/ether" and prints column 2
cmds=$(journalctl _COMM=sudo | grep COMMAND | wc -l) #journalctl finds all sudo logs, grep finds only the sudo logd from sudo commands and counts how many lines.
wall "  #Architecture: $arc
        #CPU physical: $pcpu
        #vCPU: $vcpu
        #Memory Usage: $uram/${fram}MB ($pram%)
        #Disk Usage: $udisk/${fdisk}Gb ($pdisk%)
        #CPU load: $cpul
        #Last boot: $lb
        #LVM use: $lvmu
        #TCP Connections: $ctcp ESTABLISHED
        #User log: $ulog
        #Network: IP $ip ($mac)
        #Sudo: $cmds cmd"
