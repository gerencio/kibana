#!/bin/sh

mkdir -p $KIBANA_HOME/conf

install_plugins() {

  if [ -n "$PLUGINS" ]; then
    for p in $(echo $PLUGINS | awk -v RS=, '{print}')
    do
      echo "Installing the plugin $p"
      kibana-plugin install $p --batch
    done
  else
    mkdir -p $KIBANA_HOME/plugins
  fi
}


install_plugins

if [ -n "$ES_ENCRYPTION_KEY" ]; then
    echo "xpack.security.enabled: \"true\"" >> $KIBANA_HOME/conf/kibana.yml
    echo "xpack.security.encryptionKey: \"$ES_ENCRYPTION_KEY\"" >> $KIBANA_HOME/conf/kibana.yml
    echo "xpack.security.sessionTimeout: $SESSION_INTERVAL" >> $KIBANA_HOME/conf/kibana.yml
fi

if [ -n "$ES_URL" ]; then
    echo "elasticsearch.url: \"$ES_URL\"" >> $KIBANA_HOME/conf/kibana.yml
fi

echo "kibana.index: \".kibana\"" >> $KIBANA_HOME/conf/kibana.yml
echo "kibana.defaultAppId: \"discover\"" >> $KIBANA_HOME/conf/kibana.yml



OPTS="-c  $KIBANA_HOME/conf/kibana.yml"

exec bin/kibana $OPTS
