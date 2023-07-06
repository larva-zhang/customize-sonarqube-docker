#!/usr/bin/env bash

set -eux
extensions_plugins_dir=${SQ_EXTENSIONS_DIR}/plugins
community_branch_plugin_version=${PLUGIN_COMMUNITY_BANCH_VERSION}

echo "append community branch plugin javaagent options"

# Append sonarqube-community-branch-plugin required javaagent java option to SONAR_WEB_JAVAOPTS & SONAR_CE_JAVAOPTS Environment Variables
web_javaopts_envvar=${SONAR_WEB_JAVAOPTS:-""}
ce_javaopts_envvar=${SONAR_CE_JAVAOPTS:-""}
web_javaopts_envvar+=" -javaagent:$extensions_plugins_dir/sonarqube-community-branch-plugin-${community_branch_plugin_version}.jar=web"
ce_javaopts_envvar+=" -javaagent:$extensions_plugins_dir/sonarqube-community-branch-plugin-${community_branch_plugin_version}.jar=ce"
export SONAR_WEB_JAVAOPTS=$web_javaopts_envvar
export SONAR_CE_JAVAOPTS=$ce_javaopts_envvar

# call next command
exec "$@"