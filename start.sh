#!/bin/sh

mkdir -p $KIBANA_HOME/conf

install_plugins() {

  if [ -n "$PLUGINS" ]; then
    for p in $(echo $PLUGINS | awk -v RS=, '{print}')
    do
      echo "Installing the plugin $p"
      $KIBANA_HOME/bin/kibana-plugin install $p --batch
    done
  else
    mkdir -p $KIBANA_HOME/plugins
  fi
}

fix_kibana_version() {
    rm -f $KIBANA_HOME/plugins/c3_charts/package.json
    echo "{
	\"name\": \"k5p-c3\",
	\"version\": \"$KIBANA_VERSION\",
	\"authors\": [
  		\"Momchil Stoyanov Momchilov <mom4il13@hotmail.com>\"
  	],
  	\"dependencies\" : {
    	\"c3\": \"0.4.11\"
  	}
    }" >> $KIBANA_HOME/plugins/c3_charts/package.json

    rm -f $KIBANA_HOME/plugins/extended_metric_vis/package.json
    echo "{
      \"name\": \"extended_metric_vis\",
      \"version\": \"0.1.0\",
      \"main\": \"index.js\",
      \"kibana\": {
        \"version\": \"$KIBANA_VERSION\"
      },
      \"author\": \"Olaf Horstmann <oh@omm-solutions.de>\",
      \"website\": \"http://www.omm-solutions.de\"
    }" >> $KIBANA_HOME/plugins/extended_metric_vis/package.json

}

install_plugins
fix_kibana_version

if [ -n "$ES_ENCRYPTION_KEY" ]; then
    echo "xpack.security.enabled: \"true\"" >> $KIBANA_HOME/conf/kibana.yml
    echo "xpack.security.encryptionKey: \"$ES_ENCRYPTION_KEY\"" >> $KIBANA_HOME/conf/kibana.yml
    echo "xpack.security.sessionTimeout: $SESSION_INTERVAL" >> $KIBANA_HOME/conf/kibana.yml
fi

if [ -n "$ES_URL" ]; then
    echo "elasticsearch.url: \"$ES_URL\"" >> $KIBANA_HOME/conf/kibana.yml
fi

if [ -n "$ES_USERNAME" ]; then
   echo "elasticsearch.username: \"$ES_USERNAME\"" >> $KIBANA_HOME/conf/kibana.yml
fi

if [ -n "$ES_PASSWORD" ]; then
   echo "elasticsearch.password: \"$ES_PASSWORD\"" >> $KIBANA_HOME/conf/kibana.yml
fi



echo "kibana.index: \".kibana\"" >> $KIBANA_HOME/conf/kibana.yml
echo "kibana.defaultAppId: \"discover\"" >> $KIBANA_HOME/conf/kibana.yml



OPTS="-c  $KIBANA_HOME/conf/kibana.yml"

exec bin/kibana $OPTS
