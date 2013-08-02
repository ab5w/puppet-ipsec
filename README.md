puppet-ipsec
============

This module installs and configures an IPSEC/L2TP VPN on RHEL6 with
unix authentication (system users). You need to set the public listening 
IP and the PSK in the class within your servers manifest. If you don't set 
an IP it will default to em1, you must set a PSK (long and random is best).

Requires the following module to work;

https://github.com/duritong/puppet-sysctl

Example usage is as follows;

    class { 'ipsec':
        publicip => "192.168.1.100",
        psk => "t8uVeCeMaBUhufraSPUraha2R",
    }



Copyright (C) 2013 Craig Parker <craig@paragon.net.uk>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; If not, see <http://www.gnu.org/licenses/>
