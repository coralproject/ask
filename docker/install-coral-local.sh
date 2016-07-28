# Coral Ask basic install script

# Requirements:
#   Docker Toolbox
#   MongoDB

# start mongo in the background
mongod --fork --syslog

# clear your current coral docker machine
docker-machine rm -y coral 

# create a new docker machine
docker-machine create -d virtualbox coral 

# set up your docker environment
eval $(docker-machine env coral)

# run the docker compose
docker-compose -f ask-basic-local.yaml up -d

# due to a snafu with database authentication, 
#  we need to bring the stack down then up
#  again before it will be ready
docker-compose -f ask-basic-local.yaml down
docker-compose -f ask-basic-local.yaml up -d
