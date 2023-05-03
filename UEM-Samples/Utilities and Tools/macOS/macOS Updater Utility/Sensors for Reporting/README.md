## Sensors for Reporting

- **Authors**: Leon Letto, George Gonzalez, and others
- **Date Created**: 1/27/2023

### Overview of Sensors

1. upgradeble_to
    - Returns all of the available macOS versions that a device is able to update to.
2. check_if_update_req_matches
    - Returns the current OS version of the device as well as the requested OS version specified in the mUU configuration.
3. deferral_count
    - Returns the number of times a user has deferred the update as well as the maximum deferrals allowed per the configuration.
4. full_os_with_rsr
    - Returns the current OS version of the device with the RSR information. (i.e. 13.3.1 (a))
5. rsr_version
    - Returns just the RSR patch version (i.e. (a))

