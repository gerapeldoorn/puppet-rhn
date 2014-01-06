This module registers the node at RHN or Satellite.

Note: that the parameter names have changed!

License
-------
Apache license 2.0

Usage
-----

    include rhn   # with Hiera
       - or -
    class { 'rhn':
      httpProxy     => $::proxy_server,
      activationKey => '99324696916956420524alsjdkkdfjkas',
    }

Contact
-------
If you have questions, improvements or suggestions please contact me.

Support
-------
Ger Apeldoorn, Freelance Puppet consultant/trainer <info@gerapeldoorn.nl>

http://puppetspecialist.nl
