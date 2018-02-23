#!/bin/bash
# Bash shell script that will install R, RStudio Server, their various
# development tools, and the main Linux packages that the tidyverse needs
# to have installed.
# Then, install the tidyverse itself, and other R packages.

# First, you have to add the most current CRAN repository to Linux, since
# the official version via (at least) Ubuntu is out-of-date.
# (The exact repo may change based on your particular distro, if not Ubuntu)
if grep --quiet cran /etc/apt/sources.list
then
  echo "Up-to-date CRAN repo found"
else
  echo "deb https://cran.rstudio.com/bin/linux/ubuntu $(lsb_release -cs)/" | tee -a /etc/apt/sources.list
fi

# # OPTIONAL: Make a bigger swapfile so installs pass on low-RAM machines
# (like AWS EC2 micro instances; 1G is too small for packages like readr/haven compilation)
# swapoff -a
# fallocate -l 1g swap2
# chmod swap2 600
# mkswap swap2
# swapon swap2

# Then, if using Ubuntu (and maybe other distros), you need to add the
# public key of the CRAN repository, so it's trusted by the OS.
# Based on instructions from:
# https://cran.r-project.org/bin/linux/ubuntu/README
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# Now, update the repository list to reflect the new source, and upgrade packages
apt-get update
apt-get upgrade -y

# Now, install the Linux packages (you can comment out those you
apt-get install -y \
	r-base \
	r-base-dev \
	r-recommended \
	libxml2-dev \
	libcurl4-openssl-dev \
	libssh2-1-dev \
	libssl-dev \
	python-pip

# (the following  may be commented out as desired)
# 	libsecret-1-dev \
# 	libmariadb-client-lgpl-dev
#   libpg-dev

# Remove dependency-only programs that were just installed
apt-get autoremove -y

# Install some python modules
# pip install pandas pycrypto requests

# Install the R packages (this will take about half an hour by itself)
Rscript -e 'install.packages(c("tidyverse", "devtools", "getPass"), dependencies = TRUE, repos = "https://cran.rstudio.com/")'

# OPTIONAL:
# Add user who ran this script to "staff" group, so all R library installs
# are in one place in the future
usermod -aG staff ${SUDO_USER}

# OPTIONAL:
# Install .deb package installer, and install RStudio Server
# apt-get install gdebi-core
# wget https://download2.rstudio.org/rstudio-server-1.1.383-amd64.deb
# gdebi rstudio-server-1.1.383-amd64.deb

# Remind to reboot, so that group change takes effect
printf "\nNOTE: please be sure to reboot before installing any new R packages,\n"
printf "so that staff group addition takes effect!\n\n"

# OPTIONAL:
# Reboot (if for no other reason than to make sure the group changes
# take effect immediately
# reboot now
