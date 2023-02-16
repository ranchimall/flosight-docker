# Flosight Docker files
[![Docker Build main](https://github.com/ranchimall/flosight-docker-files/actions/workflows/build-publish-main.yml/badge.svg)](https://github.com/ranchimall/flosight-docker-files/actions/workflows/build-publish-main.yml)   [![Docker Build dev](https://github.com/ranchimall/flosight-docker-files/actions/workflows/build-publish-dev.yml/badge.svg)](https://github.com/ranchimall/flosight-docker-files/actions/workflows/build-publish-dev.yml)

## Command to run the docker

```
docker volume create flosight

docker run -d --name=flosight -p 9200:80  --mount source=flosight,target=/data --env NETWORK=mainnet --env ADDNODE=ramanujam.ranchimall.net  --env BLOCKCHAIN_BOOTSTRAP=https://bootstrap.ranchimall.net/flosight1.tar.gz ranchimallfze/flosight:github

docker logs --follow --tail 500 flosight

# If you want flosight to automatically start after your server/computer restarts, then add restart policy 
# --restart=always

docker run -d --restart=always --name=flosight -p 9200:80  --mount source=flosight,target=/data --env NETWORK=mainnet --env ADDNODE=ramanujam.ranchimall.net  --env BLOCKCHAIN_BOOTSTRAP=https://bootstrap.ranchimall.net/flosight1.tar.gz ranchimallfze/flosight:github

# If you want to change the restart policy of an existing container

docker update --restart=always <container>

```    

Open the page http://localhost:8080/api/sync to view the sync status (available API endpoints). After sync is at 100%, you can open the page http://localhost:8080. If you open the homepage while it is still syncing, you will quickly get rate limited, as the UI makes a request for every block update that comes in (this is a bug that may be fixed at some point in the future).

## Environment Variables
Flo Explorer uses Environment Variables to allow for configuration settings. You set the Env Variables in your docker run startup command. Here are the config settings offered by this image.

* NETWORK: [mainnet|testnet] The Flo network you wish to run the Flo Explorer on (Default mainnet).
* ADDNODE: [ip-address] An IP address of a Flo node to be used as a source of blocks. This is useful if you are running isolated networks, or if you are having a hard time connecting to the network.
* CUSTOM_FCOIN_CONFIG: [String] A string (seperated with \n to split lines lines) of extra config variables to add to fcoin.conf (fcoin is the internal Flo Fullnode for the Flo Explorer)

## Instructions to build the image

### Manually
```
git clone https://github.com/ranchimall/flosight-docker-files/

cd flosight-docker-files

sudo docker build -t ranchimallfze/flosight:1.0.0 .
```

### CI 

This repo has continuos integration workflows setup with Github Actions. On every commit or pull request to ranchimall/flosight-docker-files, 2 workflows will be triggered to build Docker images: 
1. For main branch of flocore-node JS
2. For dev branch of flocore-node JS 

After building the images they are pushed to DockerHub under the following tags:
* flocore-node main branch - ranchimallfze/flosight:github
* flocore-node dev branch  - ranchimallfze/flosight:dev

Note - If there have been changes in the dependent repositories mentioned inside the Docker file, then you'll want trigger the workflows again since Github Actions cannot detect changes in them. Steps to trigger workflows again:
1. Go to **Actions** tab of the repository
2. Click the latest Workflow run mentioned in the list, under the column "x workflow runs"
3. On the left side under **Jobs**, click rebuild icon

