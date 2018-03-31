#!/usr/bin/env bash

distro="centos"

docker build --no-cache -f ./testing/Dockerfile -t test_install_r_${distro} .

docker run -dit --name=test_${distro} test_install_r_${distro}

docker exec -ti test_${distro} bash -c "/root/install_R.bash"

printf "\nWould you like to leave the container running to inspect the results? (y/n) "
read rm_container

if [ "$rm_container" == "n" ]; then
    printf "\nStopping & removing docker container...\n"
    docker stop test_${distro} && docker rm test_${distro}
else
    printf "Leaving container up. Inspect interactively using 'docker attach test_${distro}'\n"
fi
