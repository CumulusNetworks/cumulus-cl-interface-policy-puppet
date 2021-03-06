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

This module provides a way to enforce what interfaces are configured on Cumulus Linux.

## Module Description

You configure interfaces in Cumulus Linux using [ifupdown2](http://docs.cumulusnetworks.com/display/CL25/Network+Interface+Management+Using+ifupdown), which has the ability to place each interface configuration in a separate file. This module assumes that the switch has an `/etc/network/interfaces` file that looks like this:

```
# Managed by Puppet
source /etc/network/interfaces.d/*
```

You can find a switch's interface configuration in files located in `/etc/network/interfaces.d`.

For example:
```
cumulus# tree /etc/network/interfaces.d
/etc/network/interfaces.d
├── bond0
├── eth0
├── lo
├── swp1
└── swp2
```

Given an allowed list, this module will delete any interface that is not mentioned in the allowed list. This ensures that only approved interfaces will exist on the system when `service networking reloaded` is activated at the end of each interface configuration check.

`service networking reload` will remove the configuration of any interface from the kernel that was not defined using [ifupdown2](http://docs.cumulusnetworks.com/display/CL25/Network+Interface+Management+Using+ifupdown2).

## Setup

### What cumulus_interface_policy affects

This module affects the configuration files located in the interfaces folder and used by [ifupdown2](http://docs.cumulusnetworks.com/display/CL25/Network+Interface+Management+Using+ifupdown2).

By default this is `/etc/network/interfaces.d`. To activate the changes, run `/sbin/ifreload -a`.

**NOTE**:
_Reloading an interface configuration is not disruptive if the configuration wasn't changed._


## Usage

The module accepts two parameters:

* `allowed` _(required)_
* `location` _(optional)_

The output below states that the loopback, management (eth0), and swp5
through swp48 can be configured. If swp1 is defined, this interface
will be removed from the `ifupdown2` interfaces directory.

```
node default {
  cumulus_interface_policy { 'policy':
    allowed => ['lo', 'eth0', 'swp5-48']
  }
}

```

## Reference

### Parameters

#### `allowed`

_Required._ This option must be an array. It lists all the interfaces that can be configured on the switch. Ranges are allowed.

```
allowed => ['lo', eth0', 'swp1-30', 'bond0-20']
```

#### `location`

_Optional._ This defines where interface files are stored. By default, this is ``/etc/network/interfaces.d``.

You must configure `/etc/network/interfaces` with the following line:

```
source /etc/network/interfaces.d/*
```

## Limitations

This module only works on Cumulus Linux.

Include **lo** and **eth0** in the interface allowed list to ensure that these
interfaces are not deleted. If using in-band management communication,
**eth0** can be left out of the list.

The command `puppet resource cumulus_interface_policy` does not currently produce any output.

## Development

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create new Pull Request.

## Cumulus Linux

![Cumulus icon](http://cumulusnetworks.com/static/cumulus/img/logo_2014.png)

Cumulus Linux is a software distribution that runs on top of industry standard networking hardware. It enables the latest Linux applications and automation tools on networking gear while delivering new levels of innovation and ﬂexibility to the data center.

For further details please see: [cumulusnetworks.com](http://www.cumulusnetworks.com)
