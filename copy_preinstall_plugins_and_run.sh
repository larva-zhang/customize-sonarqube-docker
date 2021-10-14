#!/usr/bin/env bash

# getPluginVersion sonar-auth-oidc-plugin-2.0.0.jar will return "2.0.0"
function getPluginVersion() {
  return "$(basename "$(echo $1|grep -Eo '[0-9]+(\.[0-9]+)*.jar')" .jar)"
}

# getPluginName sonar-auth-oidc-plugin-2.0.0.jar will return "sonar-auth-oidc-plugin"
function getPluginName() {
  return "$(basename $1 "$(echo $1|grep -Eo '[0-9]+(\.[0-9]+)*.jar')")"
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
      preinstall_plugin_name=$(getPluginName $preinstall_plugin_jar)
      for extensions_plugin_jar in $(ls $2|grep '.*.jar') ; do
          extensions_plugin_name=$(getPluginName $extensions_plugin_jar)
          if [ "$preinstall_plugin_name" -eq "$extensions_plugin_name" ]; then
              # exists the same name plugin, compare version, the higher version covered the lower version
              preinstall_plugin_version=$(getPluginVersion $preinstall_plugin_jar)
              extensions_plugin_version=$(getPluginVersion $extensions_plugin_jar)
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
community_branch_plugin_version=${PLUGIN_COMMUNITY_BANCH_VERSION}

echo "copy preinstall plugins from $preinstall_plugins_dir to $extensions_plugins_dir"
mkdir -p $extensions_plugins_dir
copyPlugins $preinstall_plugins_dir $extensions_plugins_dir

# Append sonarqube-community-branch-plugin required javaagent java option to SONAR_WEB_JAVAOPTS & SONAR_CE_JAVAOPTS Environment Variables
web_javaopts_envvar=${SONAR_WEB_JAVAOPTS:-""}
ce_javaopts_envvar=${SONAR_CE_JAVAOPTS:-""}
web_javaopts_envvar+=" -javaagent:./extensions/plugins/sonarqube-community-branch-plugin-${community_branch_plugin_version}.jar=web"
ce_javaopts_envvar+=" -javaagent:./extensions/plugins/sonarqube-community-branch-plugin-${community_branch_plugin_version}.jar=ce"
export SONAR_WEB_JAVAOPTS=$web_javaopts_envvar
export SONAR_CE_JAVAOPTS=$ce_javaopts_envvar

# call run.sh
exec bin/run.sh "$@"