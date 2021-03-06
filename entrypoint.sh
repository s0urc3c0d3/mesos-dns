#!/bin/bash

crond
crontab -r
echo "*/5 * * * * /gen_hosts.sh > /etc/hosts" > /tmp/mycron 
crontab /tmp/mycron

my_stack=$(curl -s rancher-metadata.rancher.internal/2015-12-19/self/stack/name)

MESOS_IPs=","

for i in $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/${my_stack}/services/mesos-master/containers/ | awk -F= '{print $2}')
do
        MESOS_IPs="${MESOS_IPs},$(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/${my_stack}/services/mesos-master/containers/${i}/primary_ip):5050"
done

MESOS_MASTERS=$(echo $MESOS_IPs | sed 's/,,//g')

MESOS_MASTERS_ARRAY=$(echo $MESOS_MASTERS | awk -F, '{for (i=1;i<NF+1;i++) {print "\""$i"\""}} END {print ""}' | tr '\n' ',' | sed 's/,,//g')

#!/bin/bash

ZK_IPs=","

for i in $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/${my_stack}/services/zookeeper/containers/ | awk -F= '{print $2}')
do
        ZK_IPs="${ZK_IPs},$(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/${my_stack}/services/zookeeper/containers/${i}/primary_ip):2181"
done

ZK_IPs=$(echo $ZK_IPs | sed 's/,,//g')


cat > /config.json <<EOF 
{
	"zk":"zk://$ZK_IPs/mesos",
		"masters":[$MESOS_MASTERS_ARRAY],
		"stateTimeoutSeconds":$stateTimeoutSeconds,
		"refreshSeconds":$refreshSeconds,
		"ttl":$ttl,
		"domain":"$MESOS_DOMAIN",
		"ns":"ns1",
		"port":$PORT,
		"resolvers":["$RESOLVERS"],
		"timeout":$timeout,
		"listener":"$listener",
		"SOAMname":"root.ns1.$MESOS_DOMAIN",
		"SOARefresh":$SOARefresh,
		"SOARetry":$SOARetry,
		"SOAExpire":$SOAExpire,
		"SOAMinttl":$SOAMinttl,
		"dnson":true,
		"httpon":true,
		"httpport":$HTTP_PORT,
		"externalon":true,
		"recurseon":true,
		"IPSources":["mesos","host"],
		"EnforceRFC952":false,
		"EnumerationOn":true
}
EOF

cat /config.json

exec /mesos-dns -v=2 -config=/config.json
