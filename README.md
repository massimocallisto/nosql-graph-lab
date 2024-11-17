
# IoT Data Graph Database Model

To run ArangoDB we use a docker distribution. 

## Requirements

* Docker and Docker Compose environment

## Run

You can run the docker compose:
    
    docker-compose up

Then connect to the web interface ( change `localhost` with your remote VM ip if needed)

    http://localhost:8529/

## Load existing dataset

Login into the container to issue the import commands:

    docker exec -it arango sh

Then move to the dataset folder and load the import script

    cd /tmp/dataset
    sh import_nodes.sh


Before import the edges you have to create the edge collection first named `iot_entities_link`. Then from the container execute the second import 

    sh import_edges.sh


Once import is complete you have to create a graph linked to `iot_entities` for node collection and `iot_entities_link` for relation entities.

AQL reference: https://www.arangodb.com/docs/stable/aql/tutorial.html

Some query example:

```
/* Showing */
FOR n IN iot_entities
    RETURN n

```

```
FOR e IN iot_entities_link
    RETURN e
```

```
/* Counting*/
RETURN COUNT(iot_entities)
```

```
RETURN COUNT(iot_entities_link)
```

```
/* Filtering */
FOR n IN iot_entities
    FILTER n.type == "class_room"
    RETURN n
```

```
FOR n IN iot_entities
    FILTER n.category == "space"
    FILTER n.type == "department"
    RETURN n
```

```
FOR n IN iot_entities
    FILTER n.category == "sensor"
    RETURN { name: n.label, identifier: n._id }
```

```
/* Find all sensor and groups by type */
FOR n IN iot_entities
  FILTER n.category == "sensor"
  COLLECT sensor_type = n.type INTO groups

  RETURN { 
    "sensor_type" : sensor_type, 
    "sensor_list" : groups 
  }
```

```
/* Find child of type space stating fron node internal id */
FOR v IN 1..1 OUTBOUND "iot_entities/polob_ludovici" iot_entities_link
    //FILTER v.category == "space"
    RETURN {label: v.label, categry: v.category}
```

```
/* Find child of type space stating fron node identifier*/
FOR n in iot_entities
	FILTER n._key == "polob_ludovici"
	FOR v IN 1..1 OUTBOUND n iot_entities_link
		//FILTER v.category == "space"
		RETURN {label: v.label, categry: v.category}
```

```
/* Find all sensors in lb1 */
FOR v IN 1..10 INBOUND "iot_entities/lb1" 
    GRAPH "iot_entities"
    FILTER v.category == "sensor"
    RETURN {label: v.label, category: v.category}
```

```
/* Find all configured use cases */
FOR n IN iot_entities
    FILTER n.category == "logic"
    FOR v IN 1..1 OUTBOUND n
    GRAPH "iot_entities"
    RETURN {label: v.label, type: v.type, use_case : n.label }
```

```
/* Find the Department director */
FOR n IN iot_entities
    FILTER n.type == "city"
    FILTER n.label == "Camerino"
    FOR v IN 1..5 OUTBOUND n
        GRAPH "iot_entities"
        FILTER v.type == "department_director"
    RETURN {label: v.label, type: v.type, city : n.label }
    //RETURN DISTINCT {label: v.label, type: v.type, city : n.label }
```

```
/* Find the Department director */
FOR n IN iot_entities
    FILTER n.type == "city"
    FILTER n.label == "Camerino"
    FOR v, e, p IN 1..5 OUTBOUND n
        GRAPH "iot_entities"
        FILTER v.type == "department_director"
    RETURN {label: v.label, type: v.type, city : n.label, edges : p.edges[*].label  }
    //RETURN DISTINCT {label: v.label, type: v.type, city : n.label , edges : p.edges[*].label}
```

```
/* Walk from a start node to any direction */
FOR v, e, p IN 1..100 ANY "iot_entities/camerino"
        GRAPH "iot_entities"
        //FILTER v.type == "department_director"
        SORT v._key
        FILTER v._key != null
        return {id: v._key, label : v.label, category: v.category, type: v.type, edges : p.edges[*].label}
```

Checkout the documentation for further query examples.
