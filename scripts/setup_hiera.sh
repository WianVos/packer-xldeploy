#!/bin/bash
set -x

sudo mkdir -p /var/lib/hiera
echo $download_password

sudo bash -c 'cat > /var/lib/hiera/xldeploy.yaml' << EOF
---
 classes:
   - xldeploy::server
 xldeploy::server::install_java: true
 xldeploy::server::version: '4.5.2'
 xldeploy::server::admin_password: 'xebialabs'
 xldeploy::server::download_user: 'download'
 xldeploy::server::download_password: "${download_password}"
 xldeploy::server::install_type: 'download'
 xldeploy::server::enable_housekeeping: 'true'
 xldeploy::server::housekeeping_weekday: '5'
 xldeploy::server::housekeeping_month: '6'
 xldeploy::server::install_license: true
 xldeploy::server::custom_license_source: 'https://dist.xebialabs.com/customer/licenses/download/deployit-license.lic'
 xldeploy::server::http_context_root: '/'
 xldeploy::server::server_plugins:
  jbossdm-plugin:
    version: '4.5.1'
    distribution: true
 xldeploy::server::xld_community_edition: 'false'
 xldeploy::cli::install_java: true
 xldeploy::cli::version: '4.5.2'
 xldeploy::cli::admin_password: 'xebialabs'
 xldeploy::cli::download_user: 'download'
 xldeploy::cli::download_password: "${download_password}"
 xldeploy::server::use_exported_keys: true
EOF