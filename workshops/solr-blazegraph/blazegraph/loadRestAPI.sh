#!/bin/bash
# copied from https://wiki.blazegraph.com/wiki/index.php/Bulk_Data_Load

FILE_OR_DIR=$1

if [ -f "/etc/default/blazegraph" ] ; then
    . "/etc/default/blazegraph" 
else
    JETTY_PORT=9999
fi

LOAD_PROP_FILE=/tmp/$$.properties

#export NSS_DATALOAD_PROPERTIES=/usr/local/blazegraph/conf/RWStore.properties
export NSS_DATALOAD_PROPERTIES=$2

#Probably some unused properties below, but copied all to be safe.

cat <<EOT >> $LOAD_PROP_FILE
quiet=false
verbose=2
closure=false
durableQueues=true
format="text/rdf+n3"
#Needed for quads
#defaultGraph=
com.bigdata.rdf.store.DataLoader.flush=true
com.bigdata.rdf.store.DataLoader.bufferCapacity=100000
com.bigdata.rdf.store.DataLoader.queueCapacity=10
#Namespace to load
namespace=kb
#Files to load
fileOrDirs=$1
#Property file (if creating a new namespace)
propertyFile=$NSS_DATALOAD_PROPERTIES
EOT

echo "Loading with properties..."

cat $LOAD_PROP_FILE

curl -X POST --data-binary @${LOAD_PROP_FILE} --header 'Content-Type:text/plain' http://localhost:${JETTY_PORT}/blazegraph/dataloader

#Let the output go to STDOUT/ERR to allow script redirection

rm -f $LOAD_PROP_FILE
