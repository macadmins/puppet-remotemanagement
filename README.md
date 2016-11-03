# remotemanagement

## Overview

This modules abstracts the kickstart command line utility and allows for simple management of the remote management service on macOS.

## How to Use

### With Hiera

Simply include the class
```
include remotemanagement
```

Then specify the rest of the parameters in hiera
```
---
remotemanagement::ard::enable: true
remotemanagement::ard::users:
  user_a: -1073741569
  user_b: -1073741568
remotemanagement::ard::enable_dir_logins: true
remotemanagement::ard::allowed_dir_groups:
  - com.apple.local.ard_admin
  - com.apple.local.ard_interact
  - com.apple.local.ard_manage
  - com.apple.local.ard_reports
```

### Standard Class Definition

```
class remotemanagement::ard {
    enable          => true,
    allow_all_users => false,
    users           => {
        'john' => -1073741569,
        'jane' => -2147483646
    }
}
```

## Reference

### Classes
* `remotemanagement`
* `remotemanagement::ard`

### Class: `remotemanagement`
This is the main class and should be included when using hiera to supply the data.

### Class: `remotemanagement::ard`
This is the class that manages the apple remote desktop service and where is where pass in the required parameters.

#### Parameters
* `enable` Whether to enable the service or not
    - type: boolean
    - default: `undef`
* `allow_all_users` Whether to enable access for all local users or not
    - type: boolean
    - default: `false`
* `all_users_privs` The privileges granted to users when `allow_all_users => true`
    - type: string
    - Privileges are represented using a signed integer stored as a string see chart blow for reference
```
64 Bit Hex Int Bit Decimal Checkbox Item
================================================================
FFFFFFFFC0000000 0 -1073741824 enabled but nothing set
FFFFFFFFC0000001 1 -1073741823 send text msgs
FFFFFFFFC0000002 2 -1073741822 control and observe, show when observing
FFFFFFFFC0000004 3 -1073741820 copy items
FFFFFFFFC0000008 4 -1073741816 delete and replace items
FFFFFFFFC0000010 5 -1073741808 generate reports
FFFFFFFFC0000020 6 -1073741792 open and quit apps
FFFFFFFFC0000040 7 -1073741760 change settings
FFFFFFFFC0000080 8 -1073741696 restart and shutdown

FFFFFFFF80000002 -2147483646 control and observe don't show when observing
FFFFFFFFC00000FF -1073741569 all enabled
FFFFFFFFC00000FF -2147483648 all disabled
```
* `enable_menu_extra` Whether or not to active the ARD menu bar 
    - type: boolean
    - default: `true`
* `enable_dir_logins` Whether or not to enable open directory group ACLs
    - type: boolean
    - default: `false`
* `enable_dir_groups` A list of groups allowed to use ARD ACLs
    - type: array
    - default: `[]`
* `enable_legacy_vnc` Whether or not to enable lecacy VNC connections
    - type: boolean
    - default: `false`
* `vnc_password` The *plain text* VNC password for connecting. This is bad.
    - type: string
    - default: `undef`
* `allow_vnc_requests` Whether or not to allow incoming VNC requests
    - type: boolean
    - default: `false`
* `allow_webm_requests` Whether or not to allow incoming WEBM requests
    - type: boolean
    - default: `false`
* `users` A hash mapping users to their ARD privileges (see privilege reference above)
    - type: hash
    - default `{}`
* `strict` Controls the exclusivity of the user list. When true, only the listed users are allowed access to ARD. Existing users not contained in puppet will have their privileges revoked.
    - type: boolean
    - default: `true`
