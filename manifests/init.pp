# == Class: rhn
#
# This class registers the node at RHN or Satellite. All required variables can be extracted from Hiera.
#
# === Parameters
#
# All parameters 
#
# [*rhn_serverURL_p*]
#   Provide the URL of the Satellite Server or RHN (Default)
#    Optional, defaults to RHN URL, overridden by Hiera rhn_serverURL
#
# [*rhn_sslCACert_p*]
#   Provide the path to the RHN CACert on the local filesystems
#    Optional, defaults to default location, overridden by Hiera rhn_sslCACert
#
# [*rhn_httpProxy_p*]
#   Provide HTTP proxy, if applicable.
#    Optional, defaults to empty, overridden by Hiera rhn_httpProxy
#
# [*rhn_activationKey_p*]
#   Mandantory, either as a parameter or Hiera value.
#   Create this key using Satellite or RHN-classic. (Management->Activation Keys)
#
# [*rhn_description_p*]
#   Provide extra description to the RHN registration.
#   Optional, defaults to empty, overridden by Hiera description
#
# === Examples
#
#  include rhn   # with Hiera
#     - or -
#  class { 'rhn':
#    rhn_httpProxy_p     => $::proxy_server,
#    rhn_activationKey_p => '99324696916956420524alsjdkkdfjkas',
#  }
#
# === Authors
#
# Ger Apeldoorn <info@gerapeldoorn.nl>
#
# === Copyright
#
# Copyright 2012 Ger Apeldoorn
#
class rhn (
	$rhn_serverURL_p     = 'https://xmlrpc.rhn.redhat.com/XMLRPC',
	$rhn_sslCACert_p     = '/usr/share/rhn/RHNS-CA-CERT',
	$rhn_httpProxy_p     = '',
	$rhn_activationKey_p = '',
	$rhn_description_p   = '',
){

	# Tries to load settings from Hiera, if that fails it uses the regular parameters.
	$rhn_serverURL     = hiera('rhn_serverURL',     $rhn_serverURL_p)
	$rhn_sslCACert     = hiera('rhn_sslCACert',     $rhn_sslCACert_p)
	$rhn_httpProxy     = hiera('rhn_httpProxy',     $rhn_httpProxy_p)
	$rhn_activationKey = hiera('rhn_activationKey', $rhn_activationKey_p)
	$rhn_description   = hiera('description',       '')

	# It really needs an activationkey, either from a parameter or Hiera.
	if !$rhn_activationKey {
		fail("activationkey not set")
	}

	file_line { "up2date_serverURL":
		path   => '/etc/sysconfig/rhn/up2date',
		line   => "serverURL=${rhn_serverURL}",
		notify => Exec['rhnreg_ks'],
	}
	file_line { "up2date_sslCACert":
		path   => '/etc/sysconfig/rhn/up2date',
		line   => "sslCACert=${rhn_sslCACert}",
		notify => Exec['rhnreg_ks'],
	}

	# Only execute the register command when the up2date file is changed. This should prevent multiple registrations.
	exec { "rhnreg_ks":
		command     => $rhn_httpProxy ? {
			''      => "/usr/sbin/rhnreg_ks --force --activationkey=\"${rhn_activationKey}\" --profilename=\"${::fqdn} - ${rhn_description}\"",
			default => "/usr/sbin/rhnreg_ks --force --proxy=${rhn_httpProxy} --activationkey=\"${rhn_activationKey}\" --profilename=\"${::fqdn} - ${rhn_description}\"",
		},
		refreshonly => true,
	}
}
