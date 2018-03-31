#!/bin/bash

# Bash shell script that will prompt the user to install R, R dev tools, the
# tidyverse of packages and data.table, and RStudio Desktop (in that order). The GNU/Linux
# utilities installed will correspond with the R configuration desired, and are
# organized based on how the docker images by Dirk Eddelbuettel are set up, for
# reliability and maximum reproducibility: https://github.com/rocker-org/rocker

# Exit on any error, or undeclared variable
set -eu


# User must run with elevated privileges
if [ "$EUID" -ne "0" ]; then
    printf "This script must be run with higher privileges. Aborting.\n" >&2
    exit 1
fi


# If not explicitly made exectuable, stop if bash isn't installed (try common places)
# bash_installed="$(find /bin -name bash)"
# if [ -z "$bash_installed" ]; then bash_installed="$(find /usr/bin -name bash)"; fi
bash_installed="ls /bin | grep '^bash$'"
if [ -z "$bash_installed" ]; then bash_installed="ls /usr/bin | grep '^bash$'"; fi

if [ -z "$bash_installed" ]; then
    printf "To be safe, this script must be run using bash, and not another shell. Aborting.\n" >&2
    exit 1
fi


# Distribution-specific settings ----

# Need the repo assigned early so distro-specific assignments pass
cran_repo_toplevel="https://cran.rstudio.com/bin/linux"

# Get distro name, keep only the actual name, and set to all lowercase
distro="$(cat /etc/*-release | grep '^ID=' | sed 's/ID=//g' | sed 's/\"//g')"
distro="${distro,,}"

# Big Ol' Case Block
case "$distro" in
    "debian"|"ubuntu" )
        pkg_update="apt-get update"
        pkg_install="apt-get install -y"
        sources_list="/etc/apt/sources.list"
        $pkg_update
        $pkg_install apt-transport-https lsb-release
        if [ "$distro" == "debian" ]; then
            distro_repo="deb $cran_repo_toplevel/$distro $(lsb_release -cs)-cran34/"
            $pkg_install gnupg2
            apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF'
        else
            distro_repo="deb $cran_repo_toplevel/$distro $(lsb_release -cs)/"
            apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 'E084DAB9'
        fi
        $pkg_update
        ;;
    "fedora" )
        pkg_update="dnf check-update"
        pkg_install="dnf install -y"
        # printf "Sorry; Fedora install is still in the works\n"
        # exit 0
        ;;
    "centos"|"rhel"|"amzn" )
        # Add EPEL (EL7) repo list
        # If this fails, check the link to see if the epel-release version changed
        rpm -Uvh "http://download.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm"
        pkg_update="yum check-update"
        pkg_install="yum install -y"
        $pkg_update
        # printf "Sorry; CentOS/RHEL/Amazon Linux install is still in the works\n"
        # exit 
        ;;
    * )
        printf "Sorry, your GNU/Linux distribution ($distro) is not supported."
        exit 1
esac


# Add appropriate CRAN repo to sources list, if applicable
if [ "$distro" == "debian" ] || [ "$distro" == "ubuntu" ]; then
    
    printf "\nTo get the latest version of R, you must update your package repo.\n"
    printf "Otherwise, you can only use whatever the latest R version is available for this distribution ($(lsb_release -ds)).\n"
    printf "Would you like to add the official CRAN repo to your sources list? (y/n) "
    read addrepo
    
    if [ "$addrepo" == "y" ]; then
        if grep --quiet "cran" "$sources_list"; then
            printf "Up-to-date CRAN repo already found.\n"
        else
            printf "No CRAN repo found: appending to /etc/sources.list and updating\n"
            echo "$distro_repo" | tee -a "$sources_list"
        fi
    else
        printf "Not adding CRAN repo; using defaults.\n"
    fi
fi


# Prompt to install base R
printf "\nWould you like to install base R? (y/n) "
read install_base_r

if [ "$install_base_r" == "y" ]; then
    case "$distro" in
        "debian"|"ubuntu" )
            $pkg_update
            $pkg_install \
                ed \
                less \
                locales \
                vim-tiny \
                wget \
                ca-certificates \
                fonts-texgyre \
                littler \
                r-cran-littler \
                r-base \
                r-base-dev \
                r-recommended
            ;;
        "fedora" )
            $pkg_update
            $pkg_install \
                R
            ;;
        "centos"|"rhel"|"amzn" )
            $pkg_install R
            printf "Uhhh... soon."
    esac
else
    printf "Well then... why did you run this script?\n"
    exit 0
fi

if [ "$distro" == "ubuntu" ]; then
    # Ask to add to staff group, so all packages install in the same location as for the root user
    printf "\nWould you like to be added to the 'staff' group?\n"
    printf "This allows for all R packages to be installed to the same location,\n"
    printf "i.e. accessible to all users on this machine without needing to reinstall.\n"
    printf "Add to staff group? (y/n) "
    read addto_staff
    
    if [ "$addto_staff" = "y" ]; then
        usermod -aG staff "$SUDO_USER"
        printf "Done. You must log out, then back in for changes to take effect.\n"
    else
        printf "Not adding sudo user to staff group.\n"
    fi
fi

# Prompt to install the tidyverse
printf "\nThe tidyverse of R packages is a suite of tools designed for, among other things, data analysis.\n"
printf "Installing the tidyverse may take a long time, and a few hundred MB of disk space.\n"
printf "Would you like to install the tidyverse of R packages? (y/n) "
read install_tidyverse

if [ "$install_tidyverse" == "y" ]; then
    # Check if user needs more RAM for tidyverse source-package compilation (ex. AWS
    # EC2 micro instances; 1G is too small for packages like readr/haven compilation)
    # If yes, prompt to make a local swap file.
    sysmem="$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')"
    sysmem="$((sysmem / 1000000))"
    if [ "$sysmem" -le "1" ]; then
        printf "\nWARNING: Available system memory (~$sysmem GB) is likely too low\n"
        printf "to compile packages for the tidyverse (i.e., install them on your system).\n"
        printf "Would you like to create a temporary swapfile (/swap2) to allow for successful compilation?\n"
        printf "(please note that choosing 'y' will NOT restore any original swap partition after intstall, but WILL remove swapfile) (y/n) "
        read make_swap
        if [ "$make_swap" == "y" ]; then
            printf "\n How large of a swapfile would you like?\n"
            printf "Please enter as an integer, in GB (at least 1 recommended) : "
            read swap_size
            swapoff -a
            fallocate -l ${swap_size}g /swap2
            chmod 600 /swap2
            mkswap /swap2
            swapon /swap2
        elif [ "$make_swap" == "n" ]; then
            printf "Not risking crashing your system. Skipping tidyverse installation, and stopping here.\n"
            printf "If you want to continue, re-run this script, and select 'no' when prompted for tidyverse installation.\n"
            exit 0
        fi
    fi
    apt-get install -y \
        libxml2-dev \
        libcurl4-openssl-dev \
        libcairo2-dev \
        libsqlite-dev \
        libmariadbd-dev \
        libmariadb-client-lgpl-dev \
        libpq-dev \
        libssh2-1-dev \
        unixodbc-dev
    # # Fedora/RHEL/CentOS
    # $pkg_install -y \
    #     libcurl-devel \
    #     openssl-devel \
    #     libssh2-devel \
    #     libxml2-devel \
    #     python-devel \
    #     gcc \
    #     gcc-c++ \
    #     automake \
    #     autoconf
    Rscript -e "
        install.packages(c('tidyverse', \
            'devtools', \
            'formatR', \
            'remotes', \
            'selectr', \
            'caTools', \
            'RSQLite', \
            'RMySQL', \
            'RMariaDB', \
            'RPostgreSQL'), \
            dependencies = TRUE, repos = 'https://cran.rstudio.com')"
    if [ "$make_swap" == "y" ]; then
        swapoff /swap2
        rm /swap2
    fi
else
    printf "Skipping tidyverse installation.\n"
fi

# Prompt to install RStudio Desktop
printf "\nWould you like to install RStudio Desktop, which is an IDE for R? (y/n) "
read install_rstudio

if [ "$install_rstudio" == "y" ]; then
    apt-get install -y gdebi-core
    debfile="rstudio-$(lsb_release -cs)-1.1.442-amd64.deb"
    wget https://download1.rstudio.org/$debfile
    gdebi --n $debfile
    rm $debfile
else
    printf "Skipping RStudio installation.\n"
fi

printf "You're all set! Enjoy R!\n"
exit 0
