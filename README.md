# Methods for Network Enumeration

## ARP Scan
  
  The ARP Scan Tool (AKA ARP Sweep or MAC Scanner) is a very fast ARP packet scanner that shows every active IPv4 device on your subnet. Since ARP is non-routable, this type of scanner only works on the local LAN (local subnet or network segment).

### Usage:
Scans the local network, provides IP, MAC, # of responded hosts.

    $ sudo arp-scan -l

### Target Selection Options 

    --file (-f) Read the list of targets from the specified file
    --localnet (-l) Generate the list of targets from the outgoing interface address and netmask
    --random (-R)  Randomize the target list so hosts are scanned in a random order
    --numeric (-N) Only allow IP addresses, no hostnames. Never perform DNS lookup 

  If neither the --file or --localnet options are specified, then targets must be specified as arguments. The target argument can either be a list of addresses or names, an IP network in the form <network>/<bits> or <network>:<netmask>, or a range of IP addresses in <start>-<end> format.

### References:
  - https://github.com/royhills/arp-scan
  - http://www.royhills.co.uk/wiki/index.php/Arp-scan_option_summary

## AutoRecon

  AutoRecon is a multi-threaded network reconnaissance tool which performs automated enumeration of services. It is intended as a time-saving tool for use in CTFs and other penetration testing environments (e.g. OSCP). It may also be useful in real-world engagements. 

### Initial Install 

    $ python3 -m pip install git+https://github.com/Tib3rius/AutoRecon.git
    $ cd AutoRecon
    $ pip3 install -r requirements.txt
    $ sudo apt install seclists

  Requirements: Python 3, python3-pip, pipx (optional, but recommended)

### Scanning Single Target

    $ python3 autorecon.py <Target_IP>

### Scanning Multiple Targets

    $ python3 autorecon.py <Target_IP> <Target_IP/Range> localhost

### Results Location

    Results for each scan will appear under /opt/tools/Autorecon/results.
    In the results folder it should have the Target IP folder created with additional content.
    The AutoRecon tool will compile Nmap Scans into txt documents or xml's. The report folder will have txt documents with summarized content found.

## LEGION

### Initial Install

    $ cd tools
    $ git clone https://github.com/GoVanguard/legion.git
    $ cd legion
    $ sudo chmod +x startLegion.sh
    $ sudo ./startLegion.sh

  Or  

  Docker Install:

    $ apt-get update
    $ apt-get install -y docker.io python-pip -y
    $ groupadd docker
    $ pip install --user docker-compose
    $ chmod +x startLegion.sh

### Usage

    $ ./startLegion.sh

  Add host(s) to scan seperated by semicolons

### Timing and Performance Options

    - Paranoid
    - Sneaky
    - Polite
    - Normal
    - Aggressive
    - Insane

## NMAP

### Quick Scan
  Scan faster than the intense scan by limiting the number of TCP ports scanned to only the top 100 most common TCP ports.

    $ nmap -T4 -F <ip range>
    $ nmap -T4 -F <target> -oX ~/notes/filename.xml

### Quick Scan Plus
  Add a little bit of version and OS detection and you got the Quick scan plus.

    $ nmap -sV -T4 -O -F –version-light <target> -oX ~/notes/filename.xml

### Quick Traceroute 
  Use this option when you need to determine hosts and routers in a network scan. It will traceroute and ping all hosts defined in the target.

    $ nmap -sn –traceroute <target> -oX ~/notes/filename.xml

### Regular Scan 
  Default everything. This means it will issue a TCP SYN scan for the most common 1000 TCP ports, using ICMP Echo request (ping) for host detection.
  
    $ nmap <target> -oX ~/notes/filename.xml

### Intense Scan    
  Should be reasonable quick, scan the most common TCP ports. It will make an effort in determining the OS type and what services and their versions are running.
  
    $ nmap -T4 -A -v <ip range> 

  This comes from having a pretty fast timing template (-T4) and for using the -A option which will try determine services, versions and OS. With the verbose output (-v) it will also give us a lot of feedback as Nmap makes progress in the scan.

    $ nmap -T4 -A -v <target> -oX ~/notes/filename.xml

### Intense Scan plus UDP 
  Same as the regular Intense scan, just that we will also scan UDP ports (-sU). The -sS option is telling Nmap that it should also scan TCP ports using SYN packets. Because this scan includes UDP ports this explicit definition of -sS is necessary.

    $ nmap -sS -sU -T4 -A -v <target> -oX ~/notes/filename.xml

### Intense Scan all TCP Ports 
  Leave no TCP ports unchecked. Normally Nmap scans a list of 1000 most common protocols, but instead we will in this example scan everything from port 1 to 65535 (max). The 1000 most common protocols listing can be found in the file called nmap-services.

    $ nmap -p 1-65535 -T4 -A -v <target> -oX ~/notes/filename.xml
    
### Intense Scan no Ping 
  Just like the other intense scans, however this will assume the host is up. Useful if the target is blocking ping request and you already know the target is up.

    $ nmap -T4 -A -v -Pn <target> -oX ~/notes/filename.xml

### Live Host Scan    
  Nmap will return a list of all detected hosts

    $ nmap -sP <Target IP> -v (-sP is deprecated)

  Will search for all hosts on that network that are currently up

    $ nmap -sn <Target IP>

### Stealth Scan 

    $ nmap -sS <IP Address>

  Shows the OS Fingerprint/MAC/Open Ports
    
    $ nmap -sS -O 

  Or  

    $ nmap -sS -sV <Target IP> 

### Full Connect Scan 

    $ nmap -sT <IP Address>
    
### Service Detection 

    $ nmap -sV <IP Address>

### Eternal Blue Vuln Scan (mS17-010) 

    $  nmap  -Pn -p445 --open --max-hostgroup 3 --script smb-vuln-ms17-010  <Target IP> 

  Or 

    $  nmap -p445 --script smb-vuln-ms17-010 <target>/24 

  Or 

    $ nmap -Pn -p445 — open — max-hostgroup 3 — script smb-vuln-ms17–010 <target> -oX ~/notes/filename.xml
    
### Ping Scan 
  Does only a ping only on the target, no port scan.

    $ nmap -sn <target> -oX ~/notes/filename.xml 

### Slow Comprehensive Scan 
  This scan has a whole bunch of options in it and it may seem daunting to understand at first. It is however not so complicated once you take a closer look at the options. The scan can be said to be a “Intense scan plus UDP” plus some extras features.
  It will put a whole lot of effort into host detection, not giving up if the initial ping request fails. It uses three different protocols in order to detect the hosts; TCP, UDP and SCTP.
  If a host is detected it will do its best in determining what OS, services and versions the host are running based on the most common TCP and UDP services. Also the scan camouflages itself as source port 53 (DNS).

    $ nmap -sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 -PU40125 -PY -g 53 –script “default or (discovery and safe)” <target> -oX ~/notes/filename.xml

### Firewall / IDS Evasion 

    $ nmap -v --script firewall-bypass

## NMAP - NSE
  
### Cloning nmap scripts into nmap directory. 
  Vulscan is a module which enhances nmap to a vulnerability scanner. The nmap option -sV enables version detection per service which is used to determine potential flaws according to the identified product. The data is looked up in an offline version of VulDB.

    $ cd /usr/share/nmap/scripts
      $ git clone https://github.com/vulnersCom/nmap-vulners.git
      $ git clone https://github.com/scipag/nmap-vulscan.git

**Reference:** 
- https://github.com/scipag/vulscan 
- https://nmap.org/book/nse.html

### Usage:

     $ nmap –script [scriptname]-p [port][host]

### Scan Target for Vulners Vulnerabilities in NSE 

    $ nmap --script nmap-vulners -sV <target IP>

### Scan Target for Vulscan
  Can take a lot longer than vulners because it is searching through several databases for vulnerabilities instead of just the one database.
  
    $ nmap --script vulscan -sV <target IP>

### Webserver Directories Enumeration
  Enumerate directories used by popular web applications.

    $ nmap –script http-enum.nse

### Script Categories 

    $ nmap –script [category] [target]
    $ nmap –script [category1,category2, etc]
    $ nmap –script-updatedb

  Script Categories: all, auth, default, discovery, external, intrusive, malware, safe, vuln

## SPOONMAP
   This script is simply a wrapper for NMAP and Masscan. Install them from your favorite package manager, or install from source.

### Initial install 

    $ git clonehttps://github.com/trustedsec/spoonmap
    $ cd spoonmap 

Reference: https://github.com/trustedsec/spoonmap 

### Launch Spoonmap 

    $ ./spoonmap.py 

     ** Select type of scanning** 
      Scan Type 
      (1) Small Port Scan
      (2) Medium Port Scan 
      (3) Large Port Scan
      (4) Extra Large Port Scan (Small, Medium, and Large) 
      (5) Full Port Scan
      (6) Custom Port Scan
      What type of scan would you like to perform (default: Small Port Scan)? 
      Would you like to enumerate service banners for any identified services (default: Yes)? 
    
    **Choose Target Scan**
      (1) External
      (2) Internal
      Is this an internal or external scan (default: External)? 
      How fast would you like to scan (default: 20000 packets/second)? 
      
      Example Target File 
        One CIDR or IP Address per line 
          192.168.ø.ø/24 
          192.168.1.23 
      Please enter the full path for the file containing target hosts (default: /opt/spoonmap/ranges . txt)
   
 
