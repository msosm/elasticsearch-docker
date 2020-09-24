#!/bin/sh

ulimit -l unlimited

sleep 5

### make elasticsearch configuration
cat <<EOF >> $ES_CONF_FILE
network:
  host: $(hostname -i)
  publish_host: $(hostname -i)
  bind_host: 0.0.0.0
EOF

# cluster
cat <<EOF >> $ES_CONF_FILE
cluster:
  name: $CLUSTER_NAME
  initial_master_nodes:
EOF

echo $ES_CLUSTER_MASTER_HOSTS | awk '{hosts=split($0,hosts," ");for (i=1; i<=hosts; i++)print hosts[i]}' | xargs -I {} echo "    - "{} >> $ES_CONF_FILE

# node
cat <<EOF >> $ES_CONF_FILE
node:
  name: $HOSTNAME
  master: $NODE_MASTER
  data: $NODE_DATA
  ingest: false
discovery:
  seed_hosts:
EOF

echo $DISCOVERY_SEED_HOSTS | awk '{hosts=split($0,hosts,",");for (i=1; i<=hosts; i++)print hosts[i]}' | xargs -I {} echo "    - "{} >> $ES_CONF_FILE

cat <<EOF >> $ES_CONF_FILE
  initial_state_timeout: 5m
  zen:
    minimum_master_nodes: $MINIMUM_MASTER_NODE
gateway:
  recover_after_nodes: 3
  expected_nodes: $EXPECTED_NODES

EOF


### plugins install
echo $PLUGINS | awk '{plugins=split($0,plugins," ");for (i=1; i<=plugins; i++)print plugins[i]}' | xargs -I {} /elasticsearch-7.8.1/bin/elasticsearch-plugin install {}

### start elasticsearch
su-exec elasticsearch /elasticsearch-$ES_VERSION/bin/elasticsearch