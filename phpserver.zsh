#!/usr/bin/zsh

# Get the IP address of the current network interface that starts with "172" 
# This command uses ifconfig to get the IP addresses of all network interfaces,
# and then filters the output to only show the IP address of the interface that starts with "172".
# The IP address is then saved to a temporary file.
ifconfig | grep "inet " | awk '{print $2}' | grep "172" > /tmp/phpserverURL.tmp

# Read the IP address from the temporary file into a variable
url=$(cat /tmp/phpserverURL.tmp)

# Generate a random port number between 8000 and 8999
# This command uses the shuf command to generate a random number between 8000 and 8999.
# The -n 1 flag specifies that only one number should be generated.
port=$(shuf -i 8000-8999 -n 1)

# Create an alias for opening URLs in the default browser using PowerShell on Windows
# This command creates an alias for the PowerShell command that opens URLs in the default browser on Windows.
alias open="powershell.exe /c start"

# Start the PHP web server on the random port and IP address
# This command uses the php -S command to start the PHP web server on the random port and IP address.
# The & at the end of the command runs the server in the background so that the script can continue running.
php -S $url:$port &

# Open the URL in the default browser
# This command uses the open alias to open the URL in the default browser on Windows.
open http://$url:$port/
echo " "

# Print the URL for accessing the web server
echo "PHP web server started on http://$url:$port"
echo "========================================================="
echo " "
read -s -k "? Press any key to QUIT.

"

#Kill open PHP servers in background
#killall -9 php
echo "
PHP -S "$url:$port" server killed
"
kill $(ps -aef | grep "php -S "$url | grep -v "grep" | awk '{print $2}')
