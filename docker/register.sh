#!/bin/bash
cd "$(dirname "$0")"
source .env
MATRIC="$1"
if [[ ! "$MATRIC" =~ ^[0-9]+$ ]]; then
  echo "Usage: ./register.sh MATRICNUMBER (digits only)"
  exit 1
fi
EXISTS=$(docker exec docker-db-1 mariadb -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -N -e "SELECT COUNT(*) FROM users WHERE username='$MATRIC';")
if [ "$EXISTS" != "0" ]; then
  echo "$MATRIC is already registered. They should use their existing code."
  exit 0
fi
PIN=$(shuf -i 1000-9999 -n 1)
if docker exec docker-libki-1 perl /app/script/administration/create_user.pl -u "$MATRIC" -p "$PIN" -m 120 > /dev/null; then
  echo "Registered: $MATRIC   Password: $PIN"
  echo "$(date '+%F %T'),$MATRIC" >> registrations.csv
else
  echo "Could not create $MATRIC."
fi
