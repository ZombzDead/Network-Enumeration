import socket

with open("ips.txt") as f:
    for ip in f:
        ip = ip.strip()
        try:
            hostname = socket.gethostbyaddr(ip)[0]
            print(f"{ip},{hostname}")
        except:
            print(f"{ip},N/A")