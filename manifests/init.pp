# @summary Configures the servicenow
#
# @example
#   include servicenow_reporting_integration
# @param [String[1]] instance
#   The FQDN of the ServiceNow instance
# @param [String[1]] user
#   The username of the account
# @param [String[1]] password
#   The password of the account
# @param [String[1]] pe_console_url
#   The PE console url
# @param [String[1]] caller_id
#  The sys_id of the incident's caller as specified in the sys_user table
# @param [Optional[String[1]]] category
#  The incident's category
# @param [Optional[String[1]]] subcategory
#  The incident's subcategory
# @param [Optional[String[1]]] contact_type
#  The incident's contact type
# @param[Optional[Integer]] state
#  The incident's state
# @param[Optional[Integer]] impact
#  The incident's impact
# @param[Optional[Integer]] urgency
#  The incident's urgency
# @param [Optional[String[1]]] assignment_group
#  The sys_id of the incident's assignment group as specified in the
#  sys_user_group table
# @param [Optional[String[1]]] assigned_to
#  The sys_id of the user assigned to the incident as specified in the
#  sys_user table. Note that if assignment_group is also specified, then
#  this must correspond to a user who is a member of the assignment_group.
class servicenow_reporting_integration (
  String[1] $instance,
  String[1] $user,
  String[1] $password,
  String[1] $pe_console_url,
  String[1] $caller_id,
  Optional[String[1]] $category         = undef,
  Optional[String[1]] $subcategory      = undef,
  Optional[String[1]] $contact_type     = undef,
  Optional[Integer] $state              = undef,
  Optional[Integer] $impact             = undef,
  Optional[Integer] $urgency            = undef,
  Optional[String[1]] $assignment_group = undef,
  Optional[String[1]] $assigned_to      = undef,
) {
  # Warning: These values are parameterized here at the top of this file, but the
  # path to the yaml file is hard coded in the report processor
  $puppet_base = '/etc/puppetlabs/puppet'

  $resource_dependencies = flatten([
    file { "${puppet_base}/servicenow_reporting.yaml":
      ensure  => file,
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0640',
      content => epp('servicenow_reporting_integration/servicenow_reporting.yaml.epp', {
        instance         => $instance,
        user             => $user,
        password         => $password,
        pe_console_url   => $pe_console_url,
        caller_id        => $caller_id,
        category         => $category,
        subcategory      => $subcategory,
        contact_type     => $contact_type,
        state            => $state,
        impact           => $impact,
        urgency          => $urgency,
        assignment_group => $assignment_group,
        assigned_to      => $assigned_to,
      }),
    }
  ])

  # Update the reports setting in puppet.conf
  ini_subsetting { 'puppetserver puppetconf add servicenow report processor':
    ensure               => present,
    path                 => "${puppet_base}/puppet.conf",
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'servicenow',
    subsetting_separator => ',',
    notify               => Service['pe-puppetserver'],
    require              => $resource_dependencies,
  }
}
