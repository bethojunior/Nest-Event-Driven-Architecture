FROM node:22-bullseye-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    vim curl wget unzip procps iproute2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY package.json yarn.lock ./
RUN yarn install

COPY . .

RUN npx prisma generate

RUN yarn build

RUN chmod +x infra/entrypoint.sh

## Set permissions for PostgreSQL scripts
RUN chmod +x infra/postgres/primary/init.sh
RUN chmod +x infra/postgres/replica/setup-replica.sh

ENV PATH=$PATH:/app/node_modules/.bin/

ENV NODE_OPTIONS="--max-old-space-size=1024"


ENTRYPOINT ["sh", "infra/entrypoint.sh"]
