#!/bin/bash

# Define the location for the local blacklist file
#BLACKLIST_FILE="/config/coredns/blacklist.txt"
BLACKLIST_FILE="blacklist.txt"

# URLs to download blocklists from
BLOCKLIST_URLS=(
    "https://urlhaus.abuse.ch/downloads/text/"
    "https://big.oisd.nl/domainswild2"
)

# Clear the current blacklist file
> $BLACKLIST_FILE

# Fetch each blocklist and format for CoreDNS
for url in "${BLOCKLIST_URLS[@]}"; do
    # Download each list
    curl -s "$url" | \
    # Remove lines with IP addresses (matches any line containing an IP address)
    grep -Ev '([0-9]{1,3}\.){3}[0-9]{1,3}' | \
    # Remove lines with domain names containing non-standard ports (matches domains with a port number)
    grep -Ev ':[0-9]{2,5}' | \
    # For URLHaus, extract domains from full URLs if needed
    grep -Eo 'https?://[^/"]+' | sed 's|https\?://||' | \
    # Filter out comments and empty lines, and format for hosts
    grep -v '^#' | grep -v '^$' | sed 's/^/0.0.0.0 /' >> $BLACKLIST_FILE
done

# Ensure no duplicate entries in the blacklist file
sort -u $BLACKLIST_FILE -o $BLACKLIST_FILE

# Reload CoreDNS to apply the new blacklist
#systemctl reload coredns
