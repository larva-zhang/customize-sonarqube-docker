FROM sonarqube:8.9-community

ARG PREINSTALL_PLUGINS_DIR=${SONARQUBE_HOME}/preinstall/plugins

# https://github.com/spotbugs/sonar-findbugs
ARG PLUGIN_FINDBUGS_VERSION=4.0.4
ARG PLUGIN_FINDBUGS_URL=https://github.com/spotbugs/sonar-findbugs/releases/download/${PLUGIN_FINDBUGS_VERSION}/sonar-findbugs-plugin-${PLUGIN_FINDBUGS_VERSION}.jar

# https://github.com/dependency-check/dependency-check-sonar-plugin
ARG PLUGIN_DEPENCY_CHECK_VERSION=2.0.8
ARG PLUGIN_DEPENCY_CHECK_URL=https://github.com/dependency-check/dependency-check-sonar-plugin/releases/download/${PLUGIN_DEPENCY_CHECK_VERSION}/sonar-dependency-check-plugin-${PLUGIN_DEPENCY_CHECK_VERSION}.jar

# https://github.com/Inform-Software/sonar-groovy
ARG PLUGIN_GROOVY_VERSION=1.8
ARG PLUGIN_GROOVY_URL=https://github.com/Inform-Software/sonar-groovy/releases/download/${PLUGIN_GROOVY_VERSION}/sonar-groovy-plugin-${PLUGIN_GROOVY_VERSION}.jar

# https://github.com/xuhuisheng/sonar-l10n-zh
ARG PLUGIN_CHINESE_PACK_VERSION=8.9
ARG PLUGIN_CHINESE_PACK_URL=https://github.com/xuhuisheng/sonar-l10n-zh/releases/download/sonar-l10n-zh-plugin-${PLUGIN_CHINESE_PACK_VERSION}/sonar-l10n-zh-plugin-${PLUGIN_CHINESE_PACK_VERSION}.jar

# https://github.com/jensgerdes/sonar-pmd
ARG PLUGIN_PMD_VERSION=3.3.1
ARG PLUGIN_PMD_URL=https://github.com/jensgerdes/sonar-pmd/releases/download/${PLUGIN_PMD_VERSION}/sonar-pmd-plugin-${PLUGIN_PMD_VERSION}.jar

# https://github.com/donhui/sonar-mybatis
ARG PLUGIN_MYBATIS_VERSION=1.0.6
ARG PLUGIN_MYBATIS_URL=https://github.com/donhui/sonar-mybatis/releases/download/${PLUGIN_MYBATIS_VERSION}/sonar-mybatis-plugin-${PLUGIN_MYBATIS_VERSION}.jar

# https://github.com/vaulttec/sonar-auth-oidc
ARG PLUGIN_OPENID_VERSION=2.1.0
ARG PLUGIN_OPENID_URL=https://github.com/vaulttec/sonar-auth-oidc/releases/download/v${PLUGIN_OPENID_VERSION}/sonar-auth-oidc-plugin-${PLUGIN_OPENID_VERSION}.jar

# https://github.com/mc1arke/sonarqube-community-branch-plugin
ARG PLUGIN_COMMUNITY_BANCH_VERSION=1.8.1
ARG PLUGIN_COMMUNITY_BANCH_URL=https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${PLUGIN_COMMUNITY_BANCH_VERSION}/sonarqube-community-branch-plugin-${PLUGIN_COMMUNITY_BANCH_VERSION}.jar

# https://github.com/sbaudoin/sonar-yaml
ARG PLUGIN_YAML_ANALYZER_VERSION=1.5.2
ARG PLUGIN_YAML_ANALYZER_URL=https://github.com/sbaudoin/sonar-yaml/releases/download/v${PLUGIN_YAML_ANALYZER_VERSION}/sonar-yaml-plugin-${PLUGIN_YAML_ANALYZER_VERSION}.jar

# https://github.com/sbaudoin/sonar-shellcheck
ARG PLUGIN_SHELL_CHECK_VERSION=2.4.0
ARG PLUGIN_SHELL_CHECK_URL=https://github.com/sbaudoin/sonar-shellcheck/releases/download/v${PLUGIN_SHELL_CHECK_VERSION}/sonar-shellcheck-plugin-${PLUGIN_SHELL_CHECK_VERSION}.jar

COPY --chown=sonarqube:sonarqube copy_preinstall_plugins_and_run.sh ${SONARQUBE_HOME}/bin/

RUN set -eux \
  && chmod 777 ${SONARQUBE_HOME}/bin/copy_preinstall_plugins_and_run.sh \
  && apk add aria2 \
  && mkdir -p $PREINSTALL_PLUGINS_DIR ${SQ_EXTENSIONS_DIR}/plugins \
  && aria2c -s 10 -x 10 -m 5 -d $PREINSTALL_PLUGINS_DIR ${PLUGIN_FINDBUGS_URL} \
  && aria2c -s 10 -x 10 -m 5 -d $PREINSTALL_PLUGINS_DIR ${PLUGIN_DEPENCY_CHECK_URL} \
  && aria2c -s 10 -x 10 -m 5 -d $PREINSTALL_PLUGINS_DIR ${PLUGIN_GROOVY_URL} \
  && aria2c -s 10 -x 10 -m 5 -d $PREINSTALL_PLUGINS_DIR ${PLUGIN_CHINESE_PACK_URL} \
  && aria2c -s 10 -x 10 -m 5 -d $PREINSTALL_PLUGINS_DIR ${PLUGIN_PMD_URL} \
  && aria2c -s 10 -x 10 -m 5 -d $PREINSTALL_PLUGINS_DIR ${PLUGIN_MYBATIS_URL} \
  && aria2c -s 10 -x 10 -m 5 -d $PREINSTALL_PLUGINS_DIR ${PLUGIN_OPENID_URL} \
  && aria2c -s 10 -x 10 -m 5 -d $PREINSTALL_PLUGINS_DIR ${PLUGIN_YAML_ANALYZER_URL} \
  && aria2c -s 10 -x 10 -m 5 -d $PREINSTALL_PLUGINS_DIR ${PLUGIN_SHELL_CHECK_URL} \
  && aria2c -s 10 -x 10 -m 5 -d $PREINSTALL_PLUGINS_DIR ${PLUGIN_COMMUNITY_BANCH_URL} \

ENTRYPOINT ["bin/copy_preinstall_plugins_and_run.sh"]
CMD ["bin/sonar.sh"]