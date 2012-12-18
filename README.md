This module registers the node at RHN or Satellite. All required variables can be extracted from Hiera.

License
-------
Apache license 2.0

Usage
-----
  include rhn   # with Hiera
     - or -
  class { 'rhn':
    rhn_httpProxy_p     => $::proxy_server,
    rhn_activationKey_p => '99324696916956420524alsjdkkdfjkas',
  }

Contact
-------
If you have questions, improvements or suggestions please contact me.

Support
-------
Ger Apeldoorn <info@gerapeldoorn.nl>

http://puppetspecialist.nl
