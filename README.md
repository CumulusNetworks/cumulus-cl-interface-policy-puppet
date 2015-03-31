# cumulus_interface_policy

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What`cumulus_interface_policy` affects](#what-cumulus_interface_policy-affects)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)

## Overview

This module provides a way of enforcing what interfaces are configured on
Cumulus Linux.

## Module Description

Interface configuration is performed by [ifupdown2](http://docs.cumulusnetworks.com/display/CL25/Network+Interface+Management+Using+ifupdown) which has the ability to place each interface configuration in a separate file. This module assumes that the switch has a /etc/network/interfaces that looks like this

```
# Managed by Puppet
source /etc/network/interfaces.d/*
```

Interface configuration can be found in files located in `/etc/network/interfaces.d`

Below is an example:

cumulus# tree /etc/network/interfaces.d
/etc/network/interfaces.d
├── bond0
├── eth0
├── lo
├── swp1
└── swp2


Given an allowed list, this module will delete any interface that is not mentioned in the allowed list. This ensures that only approved interfaces will exist on the system when `service networking reloaded` is activated at the end of each interface configuration check.

`service networking reload` will un-configure any interface from the kernel that is not defined in [ifupdown2](http://docs.cumulusnetworks.com/display/CL25/Network+Interface+Management+Using+ifupdown2).

## Setup

### What cumulus_interface_policy affects

This module affects the configuration files located in the interfaces folder and used by [ifupdown2](http://docs.cumulusnetworks.com/display/CL25/Network+Interface+Management+Using+ifupdown2).

By default this is `/etc/network/interfaces.d`. To activate the changes run `/sbin/ifreload -a`.

**NOTE**:
reloading interface config will not be disruptive if there is no change in the configuration.


## Usage

The module accepts 2 parameters.
*  ``allowed`` _(required)_
* ``location`` _(optional)_.

The output below states that the loopback, management (eth0) and swp5
through swp48 can be configured. If  swp1 is defined, this interface
will be removed from the Ifupdown2 interfaces directory.
```
node default {
  cumulus_interface_policy { 'policy':
    allowed => ['lo', 'eth0', 'swp5-48']
  }
}

```

## Reference

 `allowed` : Required option. This option must be an array. It lists all the interfaces that can be configured on the switch. A range of interface are allowed.

    ```
    allowed => ['lo', eth0', 'swp1-30', 'bond0-20']
    ```

 `location`:  This defines where interface files are stored. By default this is ``/etc/network/interfaces.d``.

`/etc/network/interfaces` must be configured with the following line
```
source /etc/network/interfaces.d/*
```

## Limitations

This module only works on Cumulus Linux.

Include **lo** and **eth0** in the interface allowed list to ensure that these
interfaces are not deleted. If using inband management communication,
**eth0** can be left out of the list.

_puppet resource cumulus_interface_policy_ does not currently produce any output.

## Development

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create new Pull Request.


![Cumulus icon](http://cumulusnetworks.com/static/cumulus/img/logo_2014.png)

### Cumulus Linux

Cumulus Linux is a software distribution that runs on top of industry standard networking hardware. It enables the latest Linux applications and automation tools on networking gear while delivering new levels of innovation and ﬂexibility to the data center.

For further details please see: [cumulusnetworks.com](http://www.cumulusnetworks.com)

## CONTRIBUTORS

- Stanley Karunditu [@skamithi](https://github.com/skamithi)
