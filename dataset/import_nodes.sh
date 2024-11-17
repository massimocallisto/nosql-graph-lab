#!/bin/sh

arangoimport \
	--file "iot_entities-nodes.csv" \
	--type csv \
	--translate "id=_key" \
	--create-collection true \
	--collection iot_entities \
	--on-duplicate replace \
	--create-collection-type document \
	--ignore-missing true
