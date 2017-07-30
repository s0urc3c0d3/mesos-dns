from mesosphere/mesos-dns
add entrypoint.sh /entrypoint.sh
run apt-get update ; apt-get install cron cron-utils -y
env ZK_ADDRESSES=127.0.0.1:2181 stateTimeoutSeconds=300 refreshSeconds=60 ttl=60 MESOS_DOMAIN=mesos PORT=53 RESOLVERS=10.234.1.161 timeout=5 listener=0.0.0.0 SOARefresh=60 SOARetry=600 SOAExpire=86400 SOAMinttl=60 HTTP_PORT=8123
expose 53 8123
entrypoint /entrypoint.sh
