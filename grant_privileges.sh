#!/bin/bash

# Set MySQL root user password
MYSQL_ROOT_PASSWORD="abc123"
OPEN_SIS_USER="openSIS_rw"
OPEN_SIS_PASSWORD="Op3nS!S"

# Wait for the database service to be ready
until mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1" &> /dev/null; do
  echo "Waiting for database service to be ready..."
  sleep 5
done

# Execute SQL commands to grant privileges
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
GRANT ALL PRIVILEGES ON *.* TO '${OPEN_SIS_USER}'@'%' IDENTIFIED BY '${OPEN_SIS_PASSWORD}' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "Privileges granted to ${OPEN_SIS_USER} on all databases."
