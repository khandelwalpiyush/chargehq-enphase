# Charge HQ + Enphase


This simple script allows your to upload your local Enphase Solar Energy data to ChargeHQ application. It is an excellent application which allows you to charge your Tesla / EV with your excess solar being generated. App doesn't have direct integration with Enphase thus this script comes in handy. 


**ChargeHQ:** https://chargehq.net

**Push API Integration:** https://chargehq.net/kb/push-api

**Enphase:** https://enphase.com/en-au


This script works with v7.x firmware of Enphase which needs login details to generate a JWT token. Although the expiry is long, it allows to renew it when expired.

**Tested on:** D7.6.175 Enphase + Raspberry Pi


It is a shell script which can be run on a windows / linux OS. Please change the following section


```
# Add ChargeHQ apiKey and envoy ip below and logfile location

apiKey='' # Get this from ChargeHQ Application (Push API)
envoy_username='' # Your login username for Enphase
envoy_password='' # Your login password for Enphase
envoy_serial_number='' # Your serial number for Enphase
envoy_local_ip='' # Your local IP address for Enphase
LOGFILE="/home/pi/chargehq/chargehq.log" # Log Location - easy for troubleshooting

## To not log simply delete all reference to '>> $LOGFILE'

```

The script needs to run as a task scheduler or cronjob / rc.local. Please google for various options. Below links are just example for reference

**Windows:** https://o365reports.com/2019/08/02/schedule-powershell-script-task-scheduler/

**Linux:** https://www.baeldung.com/linux/run-script-on-startup
