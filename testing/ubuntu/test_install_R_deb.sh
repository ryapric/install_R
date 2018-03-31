#!/bin/sh

docker build -f ./testing/debian/Dockerfile -t test_install_r_debian .

docker run -dit --name=test_debian test_install_r_debian

docker exec -ti test_debian bash -c "/root/install_R_debian.bash"

printf "\nWould you like to leave the container running to inspect the results? (y/n) "
read rm_container
if [ "$rm_container" == "n" ]; then
    printf "\nStopping & removing docker container...\n"
    docker stop test_debian && docker rm test_debian
else
    printf "Leaving container up. Inspect interactively using 'docker attach test_debian'\n"
fi
