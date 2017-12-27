#! /bin/bash
# Bash shell script that will install R, RStudio Server, their various development tools,
# and the main Linux packages that the tidyverse needs to have installed.
# Then, install the tidyverse itself, and other R packages.

# First, you have to add the most current CRAN repository to Linux, since the official
# version via (at least) Ubuntu is out-of-date.
# The exact repo will change based on your particular distro.
echo "deb https://cran.rstudio.com/bin/linux/ubuntu $(lsb_release -cs)/" | tee -a /etc/apt/sources.list

# Then, if using Ubuntu (and maybe other distros), you need to add the public key of the
# CRAN repository, so it's trusted by the OS.
# Based on instructions from: https://cran.r-project.org/bin/linux/ubuntu/README
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# Now, update the repository list to reflect the new source
apt-get update

# Now install the Linux packages (maybe a little overkill, here)
apt-get install -y \
	r-base \
	r-base-dev \
	r-recommended \
	r-cran-littler \
	libxml2-dev \
	libcurl4-openssl-dev \
	libssl-dev \
	libsecret-1-dev \
	libmariadb-client-lgpl-dev

# Install the R packages (this will take about half an hour by itself)
Rscript -e 'install.packages(c("tidyverse", "data.table", "openxlsx", "writexl",
"RcppRoll", "devtools", "roxygen2", "testthat", "validate"),
dependencies = TRUE, repos = "https://cran.rstudio.com/")'

# Optional: Install .deb package installer, and install RStudio Server
apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.383-amd64.deb
gdebi rstudio-server-1.1.383-amd64.deb
