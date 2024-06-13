#! /bin/bash
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

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version


docker-compose up --build -d
docker-compose ps
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
  docker exec -it $CONTAINER_NAME /$SCRIPT_NAME

  echo "Privileges setup completed."
else
  echo "Database container is not running. Please start the container first."
  exit 1
fi


# Get the public IP address and store it in a variable
PUBLIC_IP=$(curl -s ifconfig.me)

# Print the public IP address
echo "The public IP address of the server is: $PUBLIC_IP"

echo "Accres the application on $PUBLIC_IP/openSIS "

