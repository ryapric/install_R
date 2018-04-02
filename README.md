Install R via Interactive Bash Script
=====================================
Ryan Price

This repository provides a bash script, `install_R.bash`, that installs the R
software on various popular GNU/Linux distributions: Debian, Ubuntu, Fedora,
RHEL, CentOS, Amazon Linux, and Raspbian. Once run, the script becomes
interactive, prompting the user for input on how they would like their
installation configured. This program is designed to make the fresh R
configuration of a new system or virtual machine as painless as possible. To
that end, simply following the prompts should be all a user has to do to get up
and running with R with a few keystrokes.

Currently, the script leads the user through the following main prompts:

1. Installation of the base R software (which will also install development
tools for R)

1. Installation of the [tidyverse](tidyverse.org) of R packages. The tidyverse
is a collection of R packages designed for consistency in data analysis code.
Approving this install will also install the `data.table` package, a lightweight
package for very fast data analysis & transformation that has zero non-core-R
dependencies.

1. Installation of the [RStudio desktop IDE](rstudio.com). Even if you don't
care for the tidyverse, which is developed by the people at RStudio, this IDE is
very high-quality, and supports syntax highlighting and shell execution of other
software, as well. Highly recommended.

<br>

Installation Instructions
-------------------------

The easiest way to get the installation running is to run the following in your
terminal:

```
# Requires root privileges, obviously
curl -sSL "https://raw.githubusercontent.com/ryapric/install_R/master/install_R.bash" | bash
```

Please note that piping to bash _**can be very dangerous**_, and you should only do so
if you have full inspected the source code that you will be running. If you are
uncomfortable piping directly to bash, then you can `curl` the script (or clone
the whole repository) locally, inspect the `install_R.bash` script, then run the
script manually. Either approach will have the same results.

<br>

Things to Note
--------------

- There are various GNU/Linux utilities that R, the tidyverse, and RStudio
depend on to function properly (`libxml`, `libssl`, PostgreSQL backend, etc.).
Those utilities will only be installed if the relevant selection is approved
when running this script.

- As this is a *bash* script, you will need the bash shell to execute it. I have
tried to keep as many "bashisms" out of it as possible, but some were
unavoidable for more concise code.

- Some machines, like `micro`-size Amazon AWS EC2 and Google Cloud instances
(and Raspberry Pis) do not have enough RAM to compile the `tidyverse` source
code successfully. Therefore, if you try and install the package suite, and your
system memory is determined to be too low, you will be prompted to allocate
space for a temporary swapfile so that compilation can succeed. The swapfile is
"swapped off" after a successful install, but please note that whatever swap
settings you may have had before *will not be restored*.
    - If installation fails or is interrupted, the swapfile may not be removed.
    You can check and remove it yourself by inspecting the `/mnt` folder for a
    `*.swap` file (where `*` is the size you gave the swapfile, in GB). Then you
    can turn off & remove it by running the following:
    ```
    swapoff /mnt/*.swap
    rm /mnt/*.swap
    ```

- If you chose to make a swapfile, please note that for systems like the
Raspberry Pi, which use SD cards as storage, this is not a great idea. SD cards
have shorter life spans than magnetic persistent storage, and I do not know how
thrashed they may be by so much C++ compilation at once. Proceed with caution
when agreeing to that prompt on such a system.

Please feel free to file bug reports, or reach out with any questions or
suggestions.

<br>

#### License
GPL-3
