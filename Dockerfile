FROM ubuntu:20.04

WORKDIR /app

RUN apt-get update && apt-get install -y curl tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get remove -y tzdata

RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs


COPY package*.json ./
RUN npm install

COPY ./src ./src
COPY ./node_modules ./node_modules


RUN npm run build

RUN apt-get update && \
    apt-get install -y nginx && \
    rm /etc/nginx/sites-available/default && \
    ln -sf /etc/nginx/nginx.conf /etc/nginx/sites-available/default && \
    ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default


FROM nginx:alpine

COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./dist/ /usr/share/nginx/html/


RUN chown -R nginx:nginx /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]

