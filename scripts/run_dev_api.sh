#!/bin/bash

trap killgroup SIGINT

killgroup(){
  echo killing...
  kill 0
}

# nohup redis-cli -p 6379 FLUSHALL
# nohup redis-cli -p 6380 FLUSHALL
# nohup redis-cli -p 6381 FLUSHALL

# nohup redis-server --port 6379 > redis_1.log &
# nohup redis-server --port 6380 > redis_2.log &
# nohup redis-server --port 6381 > redis_3.log &

docker run --rm -p 6379:6379 --name ndid_redis_1 redis:4-alpine &
docker run --rm -p 6380:6379 --name ndid_redis_2 redis:4-alpine &
docker run --rm -p 6381:6379 --name ndid_redis_3 redis:4-alpine &

cd main-server

TENDERMINT_IP=127.0.0.1 \
TENDERMINT_PORT=45000 \
NODE_ID=ndid1 \
npm run initDevKey

TENDERMINT_IP=127.0.0.1 \
TENDERMINT_PORT=45000 \
NODE_ID=ndid1 \
NDID_NODE=true \
node build/server.js &

TENDERMINT_IP=127.0.0.1 \
TENDERMINT_PORT=45000 \
MQ_CONTACT_IP=127.0.0.1 \
MQ_BINDING_PORT=5555 \
MQ_SERVICE_SERVER_PORT=50051 \
SERVER_PORT=8100 \
NODE_ID=idp1 \
node build/server.js &

TENDERMINT_IP=127.0.0.1 \
TENDERMINT_PORT=45000 \
MQ_CONTACT_IP=127.0.0.1 \
MQ_BINDING_PORT=5655 \
MQ_SERVICE_SERVER_PORT=50052 \
SERVER_PORT=8101 \
NODE_ID=idp2 \
node build/server.js &

TENDERMINT_IP=127.0.0.1 \
TENDERMINT_PORT=45001 \
MQ_CONTACT_IP=127.0.0.1 \
MQ_BINDING_PORT=5556 \
MQ_SERVICE_SERVER_PORT=50053 \
SERVER_PORT=8200 \
NODE_ID=rp1 \
node build/server.js &

TENDERMINT_IP=127.0.0.1 \
TENDERMINT_PORT=45002 \
MQ_CONTACT_IP=127.0.0.1 \
MQ_BINDING_PORT=5557 \
MQ_SERVICE_SERVER_PORT=50054 \
SERVER_PORT=8300 \
NODE_ID=as1 \
node build/server.js &

TENDERMINT_IP=127.0.0.1 \
TENDERMINT_PORT=45002 \
MQ_CONTACT_IP=127.0.0.1 \
MQ_BINDING_PORT=5558 \
MQ_SERVICE_SERVER_PORT=50055 \
SERVER_PORT=8301 \
NODE_ID=as2 \
node build/server.js &

TENDERMINT_IP=127.0.0.1 \
TENDERMINT_PORT=45003 \
MQ_CONTACT_IP=127.0.0.1 \
MQ_BINDING_PORT=5658 \
MQ_SERVICE_SERVER_PORT=50056 \
SERVER_PORT=8400 \
NODE_ID=proxy1 \
DB_PORT=6380 \
node build/server.js &

TENDERMINT_IP=127.0.0.1 \
TENDERMINT_PORT=45003 \
MQ_CONTACT_IP=127.0.0.1 \
MQ_BINDING_PORT=5659 \
MQ_SERVICE_SERVER_PORT=50057 \
SERVER_PORT=8401 \
NODE_ID=proxy2 \
DB_PORT=6381 \
node build/server.js &

wait