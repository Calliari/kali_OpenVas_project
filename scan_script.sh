#!/bin/bash

# Deployment script to run Vulnerability pen testing
#
#
# @revisions
#   1.0: Initial script

# ./scan_script.sh --scan-options="Full and fast" --report-format="PDF" --ip-address="1.2.3.4 127.0.0.1 192.168.1.1"

# reload bash session before start this script "solved the problem of being held on "create task for scan"
source ~/.bashrc

slep 2

# Simple timer
start=$(date +'%m%s')

# show ip address
echo $(curl -s https://api.ipify.org)

 # display how to use the script
usage() {
  echo "Usage: $0\
 [--scan-options <string>]\
 [--report-format <string>]\
 [--ip-address <string>]\
 [--verbose|-v (optional)]" 1>&2
  exit 1
}


# show ip address
echo $(curl -s https://api.ipify.org)

# Define variables from options.
OPTS=`getopt -o v --long verbose,scan-options:,report-format:,ip-address: -- "$@"`
if [ $? != 0 ]; then
  usage
fi

eval set -- "$OPTS"
# set initial values of the parameters, Set defaults.
VERBOSE=false
SCAN_OPTIONS=
REPORT_FORMAT=
IP_ADDRESS=
HOSTS_LIST=


while true; do
  case "$1" in
    -v | --verbose )
      VERBOSE=true;
      shift;;
    --scan-options )
      SCAN_OPTIONS="$2";
      shift 2;;
    --report-format )
      REPORT_FORMAT="$2"
      shift 2;;
    --ip-address )
      IP_ADDRESS="$2"
      shift 2;;
    *)
      break;;
  esac
done

# All of these parameters are required
if [ "${SCAN_OPTIONS}" = "" ] || [ "${REPORT_FORMAT}" = "" ] || [ "${IP_ADDRESS}" = "" ] ; then
  usage
fi

  # additional ip addresses added by the jenkins parameters
echo -e "$IP_ADDRESS" | tee hosts_list.txt
HOSTS_LIST=$(<hosts_list.txt)

# Make sure the variable are set to null at the beginning of the script
DT=$(date +%d-%m-%Y---%H:%M:%S)


# "========================================================"
# HOSTS_LIST=(locahost 192.168.10.100
echo ""
echo "========================================================"
echo "HOSTS_LIST: $HOSTS_LIST"
echo "SCAN_OPTIONS: $SCAN_OPTIONS"
echo "REPORT_FORMAT: $REPORT_FORMAT"
echo ""
echo "========================================================"



# sudo openvasmd --user=admin --new-password=admin

 # Create a target host
TARGET_RETURN=$(omp -u admin -w admin --xml="\
    <create_target>\
        <name>BBD IPs Scan $DT</name>\
        <hosts>$HOSTS_LIST</hosts>\
    </create_target>")

# If it does not contain the string resource created, we halt execution as our command has failed.
echo "$TARGET_RETURN" | grep -m1 'resource created' || exit 1
# get the 36 digits from the target ID e.g(75902805-281f-4d99-931f-fe4915d06da0)
T_ID=${TARGET_RETURN:28:36}
echo "T_ID $T_ID"


# select the type of scan e.g Full and fast(daba56c8-73ec-11df-a475-002264764cea)
C_ID=$(omp -u admin -w admin -g | grep "$SCAN_OPTIONS")
C_ID=${C_ID:0:36}
echo "C_ID $C_ID"

# C_ID=$(omp -u admin -w admin --xml="\
#     <create_task>\
#       <name>Task Scanner $DT</name>\
#         <comment>$SCAN_OPTIONS</comment>\
#         <config id="daba56c8-73ec-11df-a475-002264764cea"/>\
#       <target id="$T_ID"/>\
#     </create_task>")
# echo "$C_ID" | grep -m1 'resource created' || exit 1
# C_ID=${C_ID:28:36}
# echo "$C_ID"

# Create task with the target ID (75902805-281f-4d99-931f-fe4915d06da0) and type of scan (daba56c8-73ec-11df-a475-002264764cea)
T_ID=$(omp -u admin -w admin -C --name="Task Scanner $DT" --target="$T_ID" --config="$C_ID")

# Start task
R_ID=$(omp -u admin -w admin -S "$T_ID")

# If the output—reduced to the current task id—contains done, the task has finished
while true; do
    RET=$(omp -u admin -w admin -G)
    RET=$(echo "$RET" | grep -m1 "$T_ID")
    echo "$RET" | grep -m1 -i "Done" && break
    sleep 1
done

# Afther the scan has finished generate a report in PDF format
F_ID=$(omp -u admin -w admin -F | grep -i "$REPORT_FORMAT")
F_ID=${F_ID:0:36}


# https://gist.github.com/codekipple/688b3f4f8ec00eb0c0c4
# Redirect the results to a PDF report file
omp -u admin -w admin -R "$R_ID" -f "$F_ID" > $R_ID-openvas_Scan_report-"$DT".PDF


# send the PDF via email
REPORT=$(ls | grep $R_ID)

# https://linoxide.com/linux-shell-script/send-email-subject-body-attachment-linux/
swaks -t "example@email.com" --header "Subject: Subject" --body "Email Text" --attach $REPORT

# Script complete. Give stats:
end=$(date +'%m%s')
diff=$(($end-$start))
echo ""
echo "OpenVas Pen Scan completed in $diff seconds."
echo "=================================================================="
echo ""
echo "Kali EC2_IP Address $(curl -s https://api.ipify.org)"
echo ""
echo "=================================================================="

# ===== END =====
exit
