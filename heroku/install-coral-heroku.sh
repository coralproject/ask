#!/usr/bin/env bash
# Script to Install Ask on Heroku

cd $HOME

# Install Go, if necessary
which go
if [ $? -ne 0 ]; then
  wget https://storage.googleapis.com/golang/go1.7.1.linux-amd64.tar.gz
  tar xvfz go*
  rm go*.tar.gz
fi
export PATH=$PATH:$HOME/go/bin
export GOROOT=$HOME/go
export GOPATH=$HOME

# Install askd via Shelf, if necessary
if [ ! -d "$GOPATH/src/github.com/coralproject/shelf" ]; then
  go get github.com/coralproject/shelf
fi
cd $GOPATH/src/github.com/coralproject/shelf/cmd/askd
go build
export XENIA_MONGO_HOST=`echo $MONGODB_URI | cut -d '@' -f 2 | cut -d '/' -f 1`
export XENIA_MONGO_USER=`echo $MONGODB_URI | cut -d ':' -f 2 | cut -d '/' -f 3`
export XENIA_MONGO_AUTHDB=`echo $MONGODB_URI | cut -d '/' -f 4`
export XENIA_MONGO_DB=`echo $MONGODB_URI | cut -d '/' -f 4`
export XENIA_MONGO_PASS=`echo $MONGODB_URI | cut -d ':' -f 3 | cut -d '@' -f 1`
export XENIA_AUTH_PUBLIC_KEY=
export XENIA_LOGGING_LEVEL=1
export XENIA_HOST=:16181
$GOPATH/src/github.com/coralproject/shelf/cmd/askd/askd &
cd $HOME

# Install NodeJS, if necessary
which node
if [ $? -ne 0 ]; then
  wget https://nodejs.org/dist/v6.7.0/node-v6.7.0-linux-x64.tar.xz
  tar xvf node*
  rm node*.tar.xz
  mv node* node
fi
export PATH=$PATH:$HOME/node/bin

# Install Elkhorn, if necessary
if [ ! -d "$HOME/elkhorn" ]; then
  git clone https://github.com/coralproject/elkhorn.git
  cd elkhorn
  npm install
  cp config.sample.json config.json
  sed -i 's/  "askHost": "https:\/\/my-ask-service.com",/  "askHost": "http:\/\/localhost:16181",/g' config.json
  cd $HOME
fi
cd elkhorn
npm start &
cd $HOME

# Install Cay, if necessary
if [ ! -d "$HOME/cay" ]; then
  git clone https://github.com/coralproject/cay.git
  cd cay
cat << EOF >> public/config.json
{
  "xeniaHost": "http://localhost:16181",
  "askHost": "http://localhost:16181",
  "trustHost": "",
  "elkhornHost": "http://localhost:4444.",
  "elkhornStaticHost": "",
  "environment": "development",
  "brand": "Coral Project",
  "googleAnalyticsId": "UA-12345678-9",
  "requireLogin": false,
  "basicAuthorization": "",
  "features": {
    "trust": false,
    "ask": true
  },
  "recaptcha": false
}
EOF
  sed -i "s/server.listen(3000, 'localhost', function(err) {/server.listen($PORT, 'localhost', function(err) {/g" dev-server.js
  cd $HOME
fi
mv $HOME/cay/src/app/layout/Sidebar/* $HOME/cay/src/app/layout/sidebar
cd cay
npm install
npm start

exit 0
