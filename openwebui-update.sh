
#!/bin/bash

#update
docker pull ghcr.io/open-webui/open-webui:main

#stop docker
docker stop open-webui

#remove docker
docker rm open-webui

#start new one
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

# Restart any running Open Web UI containers
docker restart $(docker ps -q --filter name=open-webui)

echo "Starting countdown..."

# Start the countdown from 10 seconds
for i in {5..1}; do
    echo "$i..."
    # Sleep for 1 second and let the current process continue when it wakes up
    sleep 1
done
echo "Blast off!"


#open Open Web UI
open http://localhost:3000/
