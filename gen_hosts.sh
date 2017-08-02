#!/bin/bash

for stack in $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks | awk -F= '{print $2}')
do
	for service in $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/${stack}/services | awk -F= '{print $2}')
	do
		for container in $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/${stack}/services/${service}/containers | awk -F= '{print $2}')
		do
			echo $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/${stack}/services/${service}/containers/${container}/primary_ip) ${stack}-${container} ${container}
		done
	done
done
