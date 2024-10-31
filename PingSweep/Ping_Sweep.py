#!/usr/bin/python3
import sys
import subprocess
import os
from datetime import datetime
NetworkScan = ""

### Class to check list of clients live in a network to scan the network you have to provide the cidr block ###

class PingSweep(object):
    
    def __init__(self):
        self.active_hosts = []

    ### Start scanning the network ###
    def start(self, cidr_address):
        if NetworkScan(cidr_address):
            self.scan_network(cidr_address)
        else:
            print("Invalid network, please try again")

    ### Utility method to scan the network and add ip address in the list which is live while scanning the whole network ###
    def scan_network(self, network):
        start_time = datetime.now()
        print("starting scan at: ", start_time)

        with open(os.devnull, "wb") as limbo:
            for ip in NetworkScan(network).iter_hosts():
                result = subprocess.Popen(["ping","-c", "1", "-n", "-W", "2", str(ip)], stdout=limbo, stderr=limbo).wait()
                if not result:
                    if ip not in self.active_hosts:
                        self.active_hosts.append(str(IPAddress(ip)))

        print(self.active_hosts)

def main():
    ping_sweep = PingSweep()
    cidr_addr = input('What network would you like to scan? (ie 10.1.1.0/24): ')
    try:
        ping_sweep.start(cidr_addr)
    except KeyboardInterrupt:
        print("\nExiting due to user break")
    except EnvironmentError:
        print("\nInvalid Network, Please try again")
        main()

if __name__ == '__main__':
    main()