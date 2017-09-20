FROM node:7.10

RUN git clone https://github.com/antirek/dialplan-lua-manager.git /usr/src/manager

WORKDIR /usr/src/manager

RUN npm install

RUN npm install bower -g

RUN bower install --allow-root

RUN ./node_modules/.bin/gulp

CMD ["npm", "start"]