# == Class: rhn
#
# This class registers the node at RHN or Satellite. All required variables can
# be extracted from Hiera.
#
# === Parameters
#
# All parameters
#
# [*serverURL*]
#   Provide the URL of the Satellite Server or RHN (Default)
#    Optional, defaults to RHN URL.
#
# [*sslCACert*]
#   Provide the path to the RHN CACert on the local filesystems
#    Optional, defaults to default location.
#
# [*httpProxy*]
#   Provide HTTP proxy, if applicable.
#    Optional, defaults to empty.
#
# [*activationKey*]
#   Mandantory, either as a parameter or Hiera value.
#   Create this key using Satellite or RHN-classic. (Management->Activation
#   Keys)
#
# [*description*]
#   Provide extra description to the RHN registration.
#   Optional, defaults to empty.
#
# === Examples
#
#  include rhn   # with Hiera
#     - or -
#  class { 'rhn':
#    httpProxy     => $::proxy_server,
#    activationKey => '99324696916956420524alsjdkkdfjkas',
#  }
#
# === Authors
#
# Ger Apeldoorn <info@gerapeldoorn.nl>
#
# === Copyright
#
# Copyright 2014 Ger Apeldoorn
#
class rhn (
  $serverURL     = 'https://xmlrpc.rhn.redhat.com/XMLRPC',
  $sslCACert     = '/usr/share/rhn/RHNS-CA-CERT',
  $httpProxy     = '',
  $activationKey = '',
  $description   = '',
){

  # It really needs an activationkey, either from a parameter or Hiera.
  if !$activationKey {
    fail('Activationkey not set for RHN module.')
  }

  file_line { 'up2date_serverURL':
    path   => '/etc/sysconfig/rhn/up2date',
    line   => "serverURL=${serverURL}",
    match  => '^serverURL=.*',
    notify => Exec['rhnreg_ks'],
  }
  file_line { 'up2date_sslCACert':
    path   => '/etc/sysconfig/rhn/up2date',
    line   => "sslCACert=${sslCACert}",
    match  => '^sslCACert=.*',
    notify => Exec['rhnreg_ks'],
  }

  # Only execute the register command when the up2date file is changed. This
  # should prevent multiple registrations.
  $command = $httpProxy ? {
      ''      => "/usr/sbin/rhnreg_ks --force --activationkey=\"${activationKey}\" --profilename=\"${::fqdn} - ${description}\"",
      default => "/usr/sbin/rhnreg_ks --force --proxy=${httpProxy} --activationkey=\"${activationKey}\" --profilename=\"${::fqdn} - ${description}\"",
  }
  exec { 'rhnreg_ks':
    command     => $command,
    refreshonly => true,
  }

}
