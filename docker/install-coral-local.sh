
mongod --fork --syslog

docker-machine rm -y coral 
docker-machine create -d virtualbox coral 
eval $(docker-machine env)


docker-compose -f ask-basic-local.yaml up -d
docker-compose -f ask-basic-local.yaml down
docker-compose -f ask-basic-local.yaml up -d
