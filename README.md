# ninicobox-v3-deploy

Deployment for Ninicobox

## Clone the repository, get submodules and checkout to master branch

```bash
git clone https://github.com/nicolaspernoud/ninicobox-v3-deploy.git
cd ninicobox-v3-deploy
git submodule update --init --recursive --remote
git submodule foreach --recursive git checkout master
```

## Run in developpment mode

```bash
# Start the server (or use vs code debug config)
cd ninicobox-v3-server
go run main.go -debug -framesource=https://localhost:4200 -https_port=2443
# Start the client in another terminal
cd ninicobox-v3-client
npm start
```

Visit https://localhost:4200 to try the app

## Run with docker

```bash
docker-compose up
```