
# foremannodes








#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with foremannodes](#setup)
    * [What foremannodes affects](#what-foremannodes-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with foremannodes](#beginning-with-foremannodes)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

Foreman nodes was created to leverage Foreman as an ENC to Puppet and allow Puppet to make configuration changes based on items changed within Foreman.


## Setup

### What foremannodes affects

* Remote Execution (nix)
 * User
 * SSH Key
 * Sudo rule
* Network Interfaces
 * Default Gateway
 * Static Interfaces
 * Dynamic Interfaces
 * Static Bonded Interfaces
 * Dynamic Bonded Interfaces
 * Slave Interfaces for Bonds
 * Virtual Interfaces / Aliases


### Setup Requirements

Requires:
* pluginsync
* Foreman setup as ENC

Requires Modules:
* puppetlabs/stdlib
* razorsedge/network

Developed against Foreman 1.17

### Beginning with foremannodes

To use this module, simply include it in your site.pp or in you Puppet Classes in Foreman for your host group or groups.

## Usage

To use this module, include it.


To enable the ability to change interface data in Foreman and have Puppet change it on the systems, you must set Ignore Puppet facts for provisioning = Yes

This is found in **Administer > Settings > Provisioning** in the Foreman web interface.

**Be advised that this will affect Puppet Facts from changing some information in Foreman.**
**It is advised to toggle this setting when making the changes so that Foreman data and Puppet / System data are in sync.**


## Limitations

If managing network interfaces with Puppet from Foreman, the following limitations currently apply.
* IPv4 only at this time
* Bridge Interfaces not managed at this time
* Network Routing not managed at this time


## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
