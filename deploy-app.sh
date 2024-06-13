#! /bin/bash
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

