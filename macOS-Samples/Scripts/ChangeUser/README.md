# ChangeUser

* Author: Brian Buchholtz
* Email: bbuchholtz@vmware.com
* Originally based off: https://github.com/TheJumpCloud/support/blob/master/scripts/macos/RenameMacUserNameAndHomeDirectory.sh
* Date Created: 6/1/2020

DEP/ABM provides a mechanism for automatically creating a local macOS user account, based on enrollment user. However, no such mechanism exists for enrollment taking place outside of DEP/ABM. ChangeUser is a collection of scripts used for automatically renaming the local macOS user account, when DEP/ABM enrollment is not possible.

There are two scripts:

* oldUser.sh - Utilizes REST API for finding EnrollmentUser. This script is run during login.
* newUser.sh - This script is run during start up.

You can copy/paste the contents of these scripts directly into the Custom Attributes payload. Be sure to update the REST API settings, to match your tenant.
