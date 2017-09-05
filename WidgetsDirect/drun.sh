#!/bin/bash
if [ $# -eq 0 ]
then
    printf "\nNo argument supplied. \nPlease supply version #\n"
    exit 0
fi

printf "\nStarting container...\n"
#docker run -d -p 5900$1:57772 -p 5800$1:1972 --volume /data/idp:/usr/cachesys -h idp:v$1 --privileged --name idpv$1 idp:v$1
docker stop wdv$1
docker rm wdv$1
docker run -d -p 5900$1:57772 -p 5800$1:1972 -h wd:v$1 --privileged -e ISC_DATA_DIRECTORY=/data/docker/SYS/IDP2017 --name wdv$1 wd:v$1
docker container ls
printf "\nYou can point your browser to http://localhost:5900$1/csp/sys/UtilHome.csp for Management Protal\n"
printf "\nYou can point your browser to http://localhost:5900$1/widgetsdirect/Welcome.csp for Widgets Direct\n"
