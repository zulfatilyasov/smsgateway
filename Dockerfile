# Set the base image to Ubuntu
FROM    ubuntu

MAINTAINER Zulfat Ilyasov

# Install Node.js and other dependencies
RUN apt-get update && \
    apt-get -y install nodejs
RUN apt-get -y install npm
RUN sudo ln -s /usr/bin/nodejs /usr/bin/node

# Install nodemon
RUN npm install -g pm2

# Provides cached layer for node_modules
ADD package.json /tmp/package.json
RUN cd /tmp && npm install --production
RUN mkdir -p /src && cp -a /tmp/node_modules /src/

# Define working directory
WORKDIR /src
ADD . /src

# Expose port
EXPOSE  3200

# Run app using nodemon
#CMD ["pm2", "-x", "start", "/src/server/server.js", "--no-daemon"]
CMD ["node", "server/server.js"]