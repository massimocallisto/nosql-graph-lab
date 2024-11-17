#!/bin/sh

arangoimport \
	--file "iot_entities-edges.csv" \
	--type csv \
	--translate "id=_key" \
	--translate "from=_from" \
	--translate "to=_to" \
	--collection iot_entities_link \
	--on-duplicate replace \
	--create-collection-type edge \
	--ignore-missing true