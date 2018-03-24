#!/bin/bash

# Bash shell script that will prompt the user to install R, R-dev, the tidyverse
# of packages, and RStudio Desktop (in that order). The GNU/Linux utilities
# installed will correspond with the R configuration desired.

# User must run with elevated privileges
if [[ $EUID -ne 0 ]]; then
   printf "This script must be run with higher privileges. Aborting.\n"
   exit 1
fi

# Get distro name
apt-get update && apt-get install lsb-release
distro="$(lsb_release -is)"
distro="${distro,,}"

# Add appropriate CRAN repo to sources.list
if grep --quiet "cran" /etc/apt/sources.list; then
  printf "Up-to-date CRAN repo found.\n"
  else
  cran_repo_toplevel="https://cran.rstudio.com/bin/linux"
  echo "deb $cran_repo_toplevel/$distro $(lsb_release -cs)/" | tee -a /etc/apt/sources.list
fi



# # Then, if using Ubuntu (and maybe other distros), you need to add the
# # public key of the CRAN repository, so it's trusted by the OS.
# # Based on instructions from:
# # https://cran.r-project.org/bin/linux/ubuntu/README
# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
# 
# # Now, update the repository list to reflect the new source, and upgrade packages
# apt-get update
# apt-get upgrade -y
# 
# # Now, install the Linux packages (you can comment out those you
# apt-get install -y \
# 	r-base \
# 	r-base-dev \
# 	r-recommended \
# 	libxml2-dev \
# 	libcurl4-openssl-dev \
# 	libssh2-1-dev \
# 	libssl-dev \
# 	python-pip
# 
# # (the following  may be commented out as desired)
# # 	libsecret-1-dev \
# # 	libmariadb-client-lgpl-dev
# #   libpg-dev
# 
# # Remove dependency-only programs that were just installed
# apt-get autoremove -y
# 
# # Install some python modules
# # pip install pandas pycrypto requests
# 
# # Install the R packages (this will take about half an hour by itself)
# Rscript -e 'install.packages(c("tidyverse", "devtools", "getPass"), dependencies = TRUE, repos = "https://cran.rstudio.com/")'
# 
# # OPTIONAL:
# # Add user who ran this script to "staff" group, so all R library installs
# # are in one place in the future
# usermod -aG staff ${SUDO_USER}



# # Check if user needs more RAM for tidyverse source-package compilation (ex. AWS
# # EC2 micro instances; 1G is too small for packages like readr/haven compilation)
# # If yes, prompt to make a local swap file.
# sysmem="$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')"
# sysmem="$((sysmem / 1000000))"
# if [ "$sysmem" -le "1" ]; then
#   printf "WARNING:
#           Available system memory (~$sysmem GB) is likely too low to compile
#           packages for the tidyverse (i.e., install them on your system).
#           Would you like to create a local swapfile (~/swap2) to allow for
#           successful compilation?\n"
#   swapoff -a
#   fallocate -l 1g swap2
#   chmod swap2 600
#   mkswap swap2
#   swapon swap2
# fi



# # OPTIONAL:
# # Install better .deb package installer, and install RStudio
# # apt-get install gdebi-core
# # debfile="rstudio-$(lsb_release -cs)-1.1.442-amd64.deb"
# # https://download1.rstudio.org/$debfile
# # gdebi debfile
# 
# # Remind to reboot, so that group change takes effect
# printf "\nNOTE: please be sure to reboot before installing any new R packages,\n"
# printf "so that staff group addition takes effect!\n\n"
# 
# # OPTIONAL:
# # Reboot (if for no other reason than to make sure the group changes
# # take effect immediately
# # reboot now
# 
# 
# 
# # OTHER
# 
# # # Set up Ubutu so cron jobs get logged to a dedicated place
# # sudo nano /etc/rsyslog.d/50-default.conf
# # 
# # # Uncomment the following line (it's near the top):
# # #cron.*                          /var/log/cron.log
# # 
# # # Restart services
# # sudo service rsyslog restart
# # sudo service cron restart
