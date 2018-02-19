#!/bin/bash
# This shell script sets up Amazon Linux images. It adds the EPEL repo, installs any GNU packages required for our tools, then installs R, as well as the tidyverse & other needed/desired R packages

# Add EPEL (EL7) repo list
# If this fails, check the link to see if the epel-release version changed
rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm

# Install important GNU/Linux packages
yum check-update
yum install libcurl-devel openssl-devel libxml2-devel python-devel

# Install pip, for python modules, then install some modules
yum install python-pip
pip install pandas requests pycrypto

# Install R ("R" is an EPEL keyword that installs several other packages, like R-devel, etc.)
yum install R

# Install tidyverse & other packages
# This will take a long time on GNU/Linux vs. Windows/Mac, because C++-dependent packages need to compile from source, so be patient
# NOTE: readr & haven are failing on install; some C++ notes I don't understand
Rscript -e 'install.packages(c("tidyverse", "getPass"), dependencies = TRUE, repos = "https://cloud.r-project.org")'
