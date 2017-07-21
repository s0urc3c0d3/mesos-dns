#!/bin/bash

MESOS_MASTERS_ARRAY=$(echo $MESOS_MASTERS | awk -F, '{for (i=1;i<NF+1;i++) {print "\""$i"\""}} END {print ""}' | tr '\n' ',' | sed 's/,,//g')

cat > /config.json <<EOF 
{
	"zk":"zk://$ZK_ADDRESSES/mesos",
		"masters":[$MESOS_MASTERS_ARRAY]",
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

exec /mesos-dns -v=2 -config=/config.json
