FROM node:0.12.2-onbuild
COPY . /src
RUN cd /src; npm install --production
RUN npm install -g pm2
EXPOSE  3200
CMD ["pm2", "start", "/src/server/server.js"]
