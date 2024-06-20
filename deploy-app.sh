#!/bin/bash
################################### install docker 
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add the ubuntu user to the docker group
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Bring down any existing Docker Compose services
docker-compose down || true

# Remove any existing containers
docker rm -f database frontend || true

# Build and start the Docker Compose services
docker-compose up --build -d
docker-compose ps

# Make sure the script is not executable anymore
chmod -x grant_privileges.sh

CONTAINER_NAME="database"
SCRIPT_NAME="grant_privileges.sh"

# Check if the database container is running
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
  echo "Database container is running."

  # Copy the script into the container
  docker cp $SCRIPT_NAME $CONTAINER_NAME:/$SCRIPT_NAME

  # Make the script executable inside the container
  docker exec -it $CONTAINER_NAME chmod +x /$SCRIPT_NAME

  # Run the script inside the container
  docker exec -it $CONTAINER_NAME bash -c "bash /$SCRIPT_NAME"

  echo "Privileges setup completed."
else
  echo "Database container is not running. Please start the container first."
  exit 1
fi

# Get the public IP address and store it in a variable
PUBLIC_IP=$(curl -s ifconfig.me)

# Print the public IP address
echo "The public IP address of the server is: $PUBLIC_IP"

echo "Access the application at http://$PUBLIC_IP/openSIS"

################################### Create systemd service for database container
sudo tee /etc/systemd/system/database.service > /dev/null <<EOF
[Unit]
Description=Database Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a database
ExecStop=/usr/bin/docker stop -t 2 database

[Install]
WantedBy=default.target
EOF

################################### Create systemd service for frontend container
sudo tee /etc/systemd/system/frontend.service > /dev/null <<EOF
[Unit]
Description=Frontend Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a frontend
ExecStop=/usr/bin/docker stop -t 2 frontend

[Install]
WantedBy=default.target
EOF

# Reload systemd to recognize the new service files
sudo systemctl daemon-reload

# Enable and start the database and frontend services
sudo systemctl enable database.service
sudo systemctl start database.service
sudo systemctl enable frontend.service
sudo systemctl start frontend.service

echo "Database and frontend containers are set to start with systemd."
