#!/bin/bash
## running via editing /etc/rc.local

# v1 - Working with 7x Firmware version.

# Configuration
chargeHQ_URI="https://api.chargehq.net/api/public/push-solar-data"

# Add ChargeHQ apiKey and envoy ip below and logfile location
apiKey='' # Get this from ChargeHQ Application
envoy_username='' # Your login username for Enphase
envoy_password='' # Your login password for Enphase
envoy_serial_number='' # Your serial number for Enphase
envoy_local_ip='' # Your local IP address for Enphase
LOGFILE="/home/pi/chargehq/chargehq.log" # Log Location - easy for troubleshooting

## To not log simply delete all reference to '>> $LOGFILE'


# Function to obtain JWT token
get_jwt_token() {
  echo "$(date "+%Y-%m-%d %H:%M:%S") Executing get_jwt_token()" >> $LOGFILE
  session_id=$(curl -sX POST "https://enlighten.enphaseenergy.com/login/login.json?" -F "user[email]=$envoy_username" -F "user[password]=$envoy_password" | jq -r ".session_id")
  jwt_token=$(curl -sX POST "https://entrez.enphaseenergy.com/tokens" -H "Content-Type: application/json" -d "{\"session_id\": \"$session_id\", \"serial_num\": \"$envoy_serial_number\", \"username\": \"$envoy_username\"}")
}

# Function to push data to ChargeHQ
push_to_chargeHQ() {
  JSON_payload="{\"apiKey\":\"$apiKey\",\"siteMeters\":{\"imported_kwh\":\"$imported_kwh\",\"exported_kwh\":\"$exported_kwh\",\"net_import_kw\":\"$net_import_kw\",\"consumption_kw\":\"$consumption_kw\",\"production_kw\":\"$production_kw\"}}"
  echo "$JSON_payload" >> $LOGFILE 
  curl -sX POST -H "Content-Type: application/json" -d "$JSON_payload" "$chargeHQ_URI" > /dev/null
  echo "$(date "+%Y-%m-%d %H:%M:%S") Pushed to ChargeHQ" >> $LOGFILE
}

# Initial JWT token retrieval
get_jwt_token

# Main script loop
while true; do

  envoycontent=$(curl -ks -H 'Accept: application/json' -H "Authorization: Bearer $jwt_token" "https://$envoy_local_ip/production.json?details=1" -b cookie -c cookie)

  if [ $? -ne 0 ] || [ -z "$envoycontent" ]; then
    echo "$(date "+%Y-%m-%d %H:%M:%S") Failed to obtain envoycontent. Refreshing JWT token..." >> $LOGFILE
    get_jwt_token
    continue
  fi

  production_kw=$(jq -r '.production[1].wNow/1000 | if . < 0 then 0 else . end' <<<"${envoycontent}")
  consumption_kw=$(jq -r '.consumption[0].wNow/1000' <<<"${envoycontent}")
  net_import_kw=$(bc -l <<< "$consumption_kw - $production_kw")

  if (( $(bc -l <<< "$net_import_kw < 0") )); then
    imported_kwh=0
    exported_kwh=$(bc -l <<< "$net_import_kw * -1")
  else
    imported_kwh=$net_import_kw
    exported_kwh=0
  fi

  push_to_chargeHQ

  sleep 5
done
