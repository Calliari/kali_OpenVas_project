# This is the README file For Kali OS with OpenVas installed

This is the details about OpenVan

There are two scripts for this project on for the installation of OpenVas (Greenbone software) and another one to Scan the ip address selected using that script.

This is used on Jenkins, there isa Jenkins' job to run these scripts automatically.
* Scripts:
  - kali_installation_openVas.sh
  - scan_script.sh

Usage of `scan_script.sh`, manually.

``` ./scan_script.sh --scan-options="Full and fast" --report-format="PDF" --ip-address=192.168.1.1```

Usage of `scan_script.sh`, automatically, just go to Jenkins tab view name "system", job name "Pen_Scan_OpenVas.

Now just select the parameters to run the job...

=====================================================

This job may be set up with some advanced configurations with a slave node on cloud to spin up an VM to run the script to install and run the scan Pen Test, after the complete process Jenkins would destroy/terminate the Kali_EC2 instance on cloud and the results/report will be sent via email.


=====================================================

### References:

Vagrant send email
https://gist.github.com/codekipple/688b3f4f8ec00eb0c0c4

Use kali
https://komunity.komand.com/learn/article/how-to-use-openvas-to-audit-the-security-of-your-network-22/

Install OpenVas on Kali
https://www.kali.org/penetration-testing/openvas-vulnerability-scanning/

How to connect Jenkins to AWS EC2 instance and deploy it on cloud
https://wiki.jenkins.io/display/JENKINS/Amazon+EC2+Plugin
