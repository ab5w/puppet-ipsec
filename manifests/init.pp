#
#
#   This module installs and configures an IPSEC/L2TP VPN on RHEL6 with
#   unix authentication (system users). You need to set the public listening 
#   IP and the PSK in the class within your servers manifest. If you don't set 
#   an IP it will default to em1, you must set a PSK (long and random is best).
#
#   Copyright (C) 2013 Craig Parker <craig@paragon.net.uk>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 3 of the License, or
#   (at your option) any later version.
#   
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; If not, see <http://www.gnu.org/licenses/>.
#

class ipsec ($publicip = '$ipaddress_em1', $psk = 'plzchangeme') {

    if $psk == 'plzchangeme' {
        fail("Please set the psk to a randomly generated string.")
    }
    
    Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin' }

    sysctl::value { "net.ipv4.ip_forward": 
        value => "1",
    } ->
	
    sysctl::value { "net.ipv4.conf.all.accept_redirects":
        value => "0",
    } ->
	
    sysctl::value { "net.ipv4.conf.all.send_redirects": 
        value => "0",
    } ->

    sysctl::value { "net.ipv4.conf.default.accept_redirects":
        value => "0",
    } ->

    sysctl::value { "net.ipv4.conf.default.send_redirects":
        value => "0",
    } ->

    package { "openswan":
        ensure => "installed",
    } ->

    package { "xl2tpd":
        ensure => "installed",
    } ->

    package {"ppp":
        ensure => "installed",
    } ->

    exec { "iptablesnat":
        command => "iptables --table nat --append POSTROUTING --jump MASQUERADE",
        unless => "iptables -t nat -L | grep MASQUERADE",
    } ->

    exec { "echo0redirects":
        command => "sh -c 'for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done'",
        unless => "sh -c 'for vpn in /proc/sys/net/ipv4/conf/*; do grep 0 $vpn/accept_redirects && grep 0 $vpn/send_redirects; done'",
    } ->

    exec { "echo0redirects-rc.local":
        command => 'echo -e "for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done" >> /etc/rc.local',
        unless => "grep 'for vpn in /proc/sys/net/ipv4/conf/*; do grep 0 $vpn/accept_redirects && grep 0 $vpn/send_redirects; done' /etc/rc.local",
    } ->

    file { "/etc/ipsec.conf":
        content => template("ipsec/ipsec.conf.erb"),
        notify  => Service["ipsec"],
    } ->

    file { "/etc/ipsec.secrets":
        content => template("ipsec/ipsec.secrets.erb"),
        notify  => Service["ipsec"],
    } ->

    file { "/etc/xl2tpd/xl2tpd.conf":
        source => "puppet:///modules/ipsec/xl2tpd.conf",
        notify  => Service["xl2tpd"],
    } ->

    file { "/etc/ppp/options.xl2tpd":
        source => "puppet:///modules/ipsec/options.xl2tpd",
        notify  => Service["xl2tpd"],
    } ->

    file { "/etc/pam.d/ppp":
        source => "puppet:///modules/ipsec/ppp",
        notify  => Service["xl2tpd"],
    } ->

    file { "/etc/ppp/pap-secrets":
        source => "puppet:///modules/ipsec/pap-secrets",
        notify  => Service["xl2tpd"],
    } ->

    service { "ipsec":
        ensure => "running",
    } ->

    service { "xl2tpd":
        ensure => "running",
    }

}
