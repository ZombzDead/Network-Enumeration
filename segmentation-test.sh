#!/bin/bash

echo "====== Segmentation Testing Script ======"

# Auto-detect Non-CDE (source) IP
NON_CDE_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++){if($i=="src"){print $(i+1); exit}}}')
if [ -z "$NON_CDE_IP" ]; then
    echo "[!] Could not auto-detect source IP. Trying fallback..."
    NON_CDE_IP=$(ifconfig | grep -A1 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n1)
fi

if [ -z "$NON_CDE_IP" ]; then
    echo "[!] Could not determine the source IP. Please check your network settings."
    exit 1
fi

echo "Detected Source IP (Non-CDE): $NON_CDE_IP"
echo

# Ask for CDE input method
echo "Do you want to provide a CDE IP list or an IP range?"
echo "1. IP Range"
echo "2. IP List (file)"
read -p "Enter your choice (1 or 2): " choice

CDE_IPS=()

if [ "$choice" == "1" ]; then
    read -p "Enter the CDE IP range (e.g., 192.168.1.0/24): " CDE_RANGE
    echo "[*] Generating full IP list from range $CDE_RANGE..."
    mapfile -t CDE_IPS < <(nmap -n -sL "$CDE_RANGE" | awk '/Nmap scan report for/ {print $5}')
elif [ "$choice" == "2" ]; then
    read -p "Enter the filename containing the CDE IPs: " FILE
    if [ ! -f "$FILE" ]; then
        echo "File not found!"
        exit 1
    fi
    mapfile -t CDE_IPS < "$FILE"
else
    echo "Invalid option."
    exit 1
fi

# Output files
OUTPUT_FILE="segmentation_results_$(date +%Y%m%d_%H%M%S).txt"
PING_RESULT_FILE="ping_results_temp.txt"
: > "$OUTPUT_FILE"
: > "$PING_RESULT_FILE"

PINGABLE_IPS=()
NON_PINGABLE_IPS=()

# Pre-check: Ping each IP and classify
echo
echo "==== Ping Check Result ===="
printf "%-15s | %-10s\n" "CDE IP" "Pingable"
echo "-------------------------------"
for CDE_IP in "${CDE_IPS[@]}"; do
    ping -c 1 -W 1 "$CDE_IP" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        PINGABLE_IPS+=("$CDE_IP")
        echo "$CDE_IP | Yes" | tee -a "$PING_RESULT_FILE"
        printf "%-15s | %-10s\n" "$CDE_IP" "Yes"
    else
        NON_PINGABLE_IPS+=("$CDE_IP")
        echo "$CDE_IP | No" | tee -a "$PING_RESULT_FILE"
        printf "%-15s | %-10s\n" "$CDE_IP" "No"
    fi
done

# Perform full port scan on pingable IPs
echo
echo "==== Scanning Pingable IPs ===="
for CDE_IP in "${PINGABLE_IPS[@]}"; do
    echo "[*] Scanning $CDE_IP (pingable)..."
    nmap -p- --min-rate=1000 -T4 "$CDE_IP" -oN "nmap_output_$CDE_IP.txt"
done

# Perform full port scan using -Pn on non-pingable IPs
echo
echo "==== Scanning Non-Pingable IPs (Using -Pn) ===="
for CDE_IP in "${NON_PINGABLE_IPS[@]}"; do
    echo "[*] Scanning $CDE_IP (non-pingable)..."
    nmap -Pn -p- --min-rate=1000 -T4 "$CDE_IP" -oN "nmap_output_$CDE_IP.txt"
done

# Final segmentation result
echo
echo "==== Final Segmentation Test Results ===="
echo "Saving results to $OUTPUT_FILE"
echo "==== Segmentation Test Results ====" | tee "$OUTPUT_FILE"
printf "%-15s | %-15s | %-18s | %s\n" "Non-CDE IP" "CDE IP" "Pingable" "Open Ports" | tee -a "$OUTPUT_FILE"
echo "--------------------------------------------------------------------------------------------" | tee -a "$OUTPUT_FILE"

for CDE_IP in "${CDE_IPS[@]}"; do
    PING_RESULT=$(grep "$CDE_IP" "$PING_RESULT_FILE" | awk -F '|' '{gsub(/ /,"",$2); print $2}')
    [ "$PING_RESULT" == "Yes" ] && PINGABLE="Pass" || PINGABLE="Fail (Forced Scan)"

    if [ -f "nmap_output_$CDE_IP.txt" ]; then
        PORTS=$(grep -E "[0-9]+/tcp\s+open" "nmap_output_$CDE_IP.txt" | awk '{print $1}' | cut -d'/' -f1 | paste -sd "," -)
        [ -z "$PORTS" ] && PORTS="None"
    else
        PORTS="Scan failed"
    fi

    printf "%-15s | %-15s | %-18s | %s\n" "$NON_CDE_IP" "$CDE_IP" "$PINGABLE" "$PORTS" | tee -a "$OUTPUT_FILE"
done

# Cleanup
rm -f "$PING_RESULT_FILE"

echo
echo "Results saved in: $OUTPUT_FILE"
