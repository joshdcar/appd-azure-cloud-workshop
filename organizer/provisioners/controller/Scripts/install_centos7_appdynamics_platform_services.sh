#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics Events Service and Controller Platform Services by AppDynamics.
#
# The Events Service is the on-premises data storage facility for unstructured data generated by
# Application Analytics, Database Visibility, and End User Monitoring deployments. It provides
# high-volume, performance-intensive, and horizontally scalable storage for analytics data.
#
# The Controller sits at the center of an AppDynamics deployment. It's where AppDynamics agents
# send data on the activity in the monitored environment. It's also where users go
# to view, understand, and analyze that data.
#
# For more details, please visit:
#   https://docs.appdynamics.com/display/LATEST/Events+Service+Deployment
#   https://docs.appdynamics.com/display/LATEST/Getting+Started
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] appdynamics platform install parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"
set +x  # temporarily turn command display OFF.
appd_platform_admin_username="${appd_platform_admin_username:-admin}"
appd_platform_admin_password="${appd_platform_admin_password:-welcome1}"
set -x  # turn command display back ON.
appd_platform_home="${appd_platform_home:-platform}"
appd_platform_name="${appd_platform_name:-My Platform}"
appd_platform_description="${appd_platform_description:-My platform config.}"
appd_platform_product_home="${appd_platform_product_home:-product}"
appd_platform_hosts="${appd_platform_hosts:-platformadmin}"

# [OPTIONAL] appdynamics events service install parameters [w/ defaults].
appd_events_service_hosts="${appd_events_service_hosts:-platformadmin}"
appd_events_service_profile="${appd_events_service_profile:-DEV}"

# [OPTIONAL] appdynamics controller install parameters [w/ defaults].
appd_controller_primary_host="${appd_controller_primary_host:-platformadmin}"
set +x  # temporarily turn command display OFF.
appd_controller_admin_username="${appd_controller_admin_username:-admin}"
appd_controller_admin_password="${appd_controller_admin_password:-welcome1}"
appd_controller_root_password="${appd_controller_root_password:-welcome1}"
appd_controller_mysql_password="${appd_controller_mysql_password:-welcome1}"
set -x  # turn command display back ON.

# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics Events Service and Controller Platform Services by AppDynamics.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [OPTIONAL] appdynamics platform install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_platform_admin_username="admin"                 # [optional] platform admin user name (defaults to user 'admin').
    [root]# export appd_platform_admin_password="welcome1"              # [optional] platform admin password (defaults to 'welcome1').
    [root]# export appd_platform_home="platform"                        # [optional] platform home folder (defaults to 'machine-agent').
    [root]# export appd_platform_name="My Platform"                     # [optional] platform name (defaults to 'My Platform').
    [root]# export appd_platform_description="My platform config."      # [optional] platform description (defaults to 'My platform config.').
    [root]# export appd_platform_product_home="product"                 # [optional] platform base installation directory for products
                                                                        #            (defaults to 'product').
    [root]# export appd_platform_hosts="platformadmin"                  # [optional] platform hosts
                                                                        #            (defaults to 'platformadmin' which is the localhost).

  [OPTIONAL] appdynamics events service install parameters [w/ defaults].
    [root]# export appd_events_service_hosts="platformadmin"            # [optional] events service hosts
                                                                        #            (defaults to 'platformadmin' which is the localhost).
    [root]# export appd_events_service_profile="DEV"                    # [optional] appd events service profile (defaults to 'DEV').
                                                                        #            valid profiles are:
                                                                        #              'DEV', 'dev', 'PROD', 'prod'

  [OPTIONAL] appdynamics controller install parameters [w/ defaults].
    [root]# export appd_controller_primary_host="platformadmin"         # [optional] controller primary host
                                                                        #            (defaults to 'platformadmin' which is the localhost).
    [root]# export appd_controller_admin_username="admin"               # [optional] controller admin user name (defaults to 'admin').
    [root]# export appd_controller_admin_password="welcome1"            # [optional] controller admin password (defaults to 'welcome1').
    [root]# export appd_controller_root_password="welcome1"             # [optional] controller root password (defaults to 'welcome1').
    [root]# export appd_controller_mysql_password="welcome1"            # [optional] controller mysql root password (defaults to 'welcome1').

  [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
    [root]# export kickstart_home="/opt/appd-cloud-kickstart"           # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -n "$appd_events_service_profile" ]; then
  case $appd_events_service_profile in
      DEV|dev|PROD|prod)
        ;;
      *)
        echo "Error: invalid 'appd_events_service_profile'."
        usage
        exit 1
        ;;
  esac
fi

# set appdynamics platform installation variables. -------------------------------------------------
appd_platform_folder="${appd_home}/${appd_platform_home}"
appd_product_folder="${appd_home}/${appd_platform_home}/${appd_platform_product_home}"

# start the appdynamics enterprise console. --------------------------------------------------------
cd ${appd_platform_folder}/platform-admin/bin
./platform-admin.sh start-platform-admin

# verify installation.
cd ${appd_platform_folder}/platform-admin/bin
./platform-admin.sh show-platform-admin-version

# login to the appdynamics platform. ---------------------------------------------------------------
set +x  # temporarily turn command display OFF.
./platform-admin.sh login --user-name "${appd_platform_admin_username}" --password "${appd_platform_admin_password}"
set -x  # turn command display back ON.

# create an appdynamics platform. ------------------------------------------------------------------
./platform-admin.sh create-platform --name "${appd_platform_name}" --description "${appd_platform_description}" --installation-dir "${appd_product_folder}"

# add local host ('platformadmin') to platform. ----------------------------------------------------
./platform-admin.sh add-hosts --hosts "${appd_platform_hosts}"

# install appdynamics events service. --------------------------------------------------------------
./platform-admin.sh install-events-service --profile "${appd_events_service_profile}" --hosts "${appd_events_service_hosts}"

# verify installation.
./platform-admin.sh show-events-service-health

# configure the appdynamics events service as a service. -------------------------------------------
systemd_dir="/etc/systemd/system"
appd_events_service_service="appdynamics-events-service.service"
service_filepath="${systemd_dir}/${appd_events_service_service}"

# create systemd service file.
if [ -d "$systemd_dir" ]; then
  rm -f "${service_filepath}"

  touch "${service_filepath}"
  chmod 644 "${service_filepath}"

  echo "[Unit]" >> "${service_filepath}"
  echo "Description=The AppDynamics Events Service." >> "${service_filepath}"
  echo "After=network.target remote-fs.target nss-lookup.target appdynamics-enterprise-console.service" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Service]" >> "${service_filepath}"
  echo "Type=forking" >> "${service_filepath}"
  echo "RemainAfterExit=true" >> "${service_filepath}"
  echo "TimeoutStartSec=300" >> "${service_filepath}"
set +x  # temporarily turn command display OFF.
  echo "ExecStartPre=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh login --user-name ${appd_platform_admin_username} --password ${appd_platform_admin_password}" >> "${service_filepath}"
set -x  # turn command display back ON.
  echo "ExecStart=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh start-events-service" >> "${service_filepath}"
  echo "ExecStop=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh stop-events-service" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Install]" >> "${service_filepath}"
  echo "WantedBy=multi-user.target" >> "${service_filepath}"
fi

# reload systemd manager configuration.
systemctl daemon-reload

# enable the events service service to start at boot time.
systemctl enable "${appd_events_service_service}"
systemctl is-enabled "${appd_events_service_service}"

# check current status.
#systemctl status "${appd_events_service_service}"

# install appdynamics controller. ------------------------------------------------------------------
set +x  # temporarily turn command display OFF.
./platform-admin.sh submit-job --service controller --job install --args controllerPrimaryHost="${appd_controller_primary_host}" controllerAdminUsername="${appd_controller_admin_username}" controllerAdminPassword="${appd_controller_admin_password}" controllerRootUserPassword="${appd_controller_root_password}" mysqlRootPassword="${appd_controller_mysql_password}"
set -x  # turn command display back ON.

# install license file.
cp ${kickstart_home}/provisioners/scripts/centos/tools/appd-controller-license.lic ${appd_platform_folder}/product/controller/license.lic

# verify installation.
curl --silent http://localhost:8090/controller/rest/serverstatus

# configure the appdynamics controller as a service. -----------------------------------------------
systemd_dir="/etc/systemd/system"
appd_controller_service="appdynamics-controller.service"
service_filepath="${systemd_dir}/${appd_controller_service}"

# create systemd service file.
if [ -d "$systemd_dir" ]; then
  rm -f "${service_filepath}"

  touch "${service_filepath}"
  chmod 644 "${service_filepath}"

  echo "[Unit]" >> "${service_filepath}"
  echo "Description=The AppDynamics Controller." >> "${service_filepath}"
  echo "After=network.target remote-fs.target nss-lookup.target appdynamics-enterprise-console.service appdynamics-events-service.service" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Service]" >> "${service_filepath}"
  echo "Type=forking" >> "${service_filepath}"
  echo "RemainAfterExit=true" >> "${service_filepath}"
  echo "TimeoutStartSec=600" >> "${service_filepath}"
  echo "TimeoutStopSec=120" >> "${service_filepath}"
set +x  # temporarily turn command display OFF.
  echo "ExecStartPre=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh login --user-name ${appd_platform_admin_username} --password ${appd_platform_admin_password}" >> "${service_filepath}"
set -x  # turn command display back ON.
  echo "ExecStart=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh start-controller-appserver" >> "${service_filepath}"
  echo "ExecStop=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh stop-controller-appserver" >> "${service_filepath}"
  echo "ExecStop=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh stop-controller-db" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Install]" >> "${service_filepath}"
  echo "WantedBy=multi-user.target" >> "${service_filepath}"
fi

# reload systemd manager configuration.
systemctl daemon-reload

# enable the controller service to start at boot time.
systemctl enable "${appd_controller_service}"
systemctl is-enabled "${appd_controller_service}"

# check current status.
#systemctl status "${appd_controller_service}"

# verify overall platform installation. ------------------------------------------------------------
./platform-admin.sh list-supported-services
./platform-admin.sh show-service-status --service controller
./platform-admin.sh show-service-status --service events-service

# shutdown the appdynamics platform components. ----------------------------------------------------
# stop the appdynamics controller.
./platform-admin.sh stop-controller-appserver

# stop the appdynamics controller database.
./platform-admin.sh stop-controller-db

# stop the appdynamics events service.
./platform-admin.sh stop-events-service

# stop the appdynamics enterprise console.
./platform-admin.sh stop-platform-admin
