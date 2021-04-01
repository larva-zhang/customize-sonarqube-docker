#!/usr/bin/env bash

# getPluginVersion sonar-auth-oidc-plugin-2.0.0 will set tmp_plugin_version="2.0.0"
function getPluginVersion() {
    tmp_plugin_version="$(echo $1|grep -Eo '[0-9]+(\.[0-9]+)*')"
}

# getPluginName sonar-auth-oidc-plugin-2.0.0 will set tmp_plugin_name="sonar-auth-oidc-plugin"
function getPluginName() {
  tmp_plugin_name="$(echo $1|grep -Eo '^[[:alpha:]]+(\-[[:alpha:]]+)*')"
}

# isHigherVersion 2.0.0 1.9.5 will return 1.
# isHigherVersion 2.0.0 1.9.6634.223 will return 1.
# isHigherVersion 2 1.9.6634.223 will return 1.
# isHigherVersion 2.0.2332 2.1.0 will return 0.
# isHigherVersion 2.0.2332 2.0 will return 1.
function isHigherVersion() {
    firstVersionArray=(${$1//./})
    secondVersionArray=(${$2//./})
    firstVersionArrayLength=${#firstVersionArray[@]}
    secondVersionArrayLength=${#secondVersionArray[@]}
    if [ $firstVersionArrayLength -ge $secondVersionArrayLength ]; then
      for (( i = 0; i < $secondVersionArrayLength; i++ )); do
          if [ ${firstVersionArray[i]} -gt ${secondVersionArray[i]} ]; then
              return 1
          elif [ ${firstVersionArray[i]} -lt ${secondVersionArray[i]} ]; then
              return 0
          fi
      done
      return 1
    else
      for (( i = 0; i < $firstVersionArrayLength; i++ )); do
          if [ ${firstVersionArray[i]} -gt ${secondVersionArray[i]} ]; then
              return 1
          elif [ ${firstVersionArray[i]} -lt ${secondVersionArray[i]} ]; then
              return 0
          fi
      done
      return 0
    fi
}

# copyPlugins $preinstall_plugins_dir $extensions_plugins_dir
function copyPlugins() {
    preinstall_plugin_jars=$(ls $1|grep '.*.jar')
    for preinstall_plugin_jar in $preinstall_plugin_jars
    do
      covered_flag=0
      preinstall_plugin_filename=$(basename $preinstall_plugin_jar .jar)
      getPluginName $preinstall_plugin_filename
      preinstall_plugin_name=$tmp_plugin_name

      for extensions_plugin_jar in $(ls $2|grep '.*.jar') ; do
          extensions_plugin_filename=$(basename $extensions_plugin_jar .jar)
          getPluginName $extensions_plugin_filename
          extensions_plugin_name=$tmp_plugin_name
          if [ "$preinstall_plugin_name" -eq "$extensions_plugin_name" ]; then
              # exists the same name plugin, compare version, the higher version covered the lower version
              getPluginVersion $preinstall_plugin_filename
              preinstall_plugin_version=$tmp_plugin_version
              getPluginVersion $extensions_plugin_name
              extensions_plugin_version=$tmp_plugin_version
              if [ "$(isHigherVersion $preinstall_plugin_version $extensions_plugin_version)" -eq 1 ]; then
                # do cover
                rm -rf $2/$extensions_plugin_jar
                cp $1/$preinstall_plugin_jar $2/
                covered_flag=1
              fi
          fi
      done

      if [ $covered_flag -eq 0 ]; then
        # do copy
        cp $1/$preinstall_plugin_jar $2/
      fi
    done
}

set -eux
preinstall_plugins_dir=${SONARQUBE_HOME}/preinstall/plugins
extensions_plugins_dir=${SQ_EXTENSIONS_DIR}/plugins

echo "copy preinstall plugins from $preinstall_plugins_dir to $extensions_plugins_dir"
mkdir -p $extensions_plugins_dir
copyPlugins $preinstall_plugins_dir $extensions_plugins_dir

# call run.sh
exec bin/run.sh "$@"