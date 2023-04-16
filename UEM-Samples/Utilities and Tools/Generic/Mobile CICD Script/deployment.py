"""
Usage:
1. Adding new application
   Command - python deployment.py <File Path>, <Application Name>, <Build Information>, <Deployment Type>,<Push Mode>,
   <Retire Previous Version>, <Supported Device Models> <Device Type>
   Arguments: File Path, Application Name, Build Information and Deployment Typea are required parameters
   All the arguments are required in case of Windows Universal App

2. Adding new assignments for an existing app
   Command - python deployment.py -a(or -AppID) <AppID> <Build Information> <Deployment Types> <Push Mode>
   All the arguments are required.

***Refer Documentation for detailed information***

Flags: -h or --help
       -v or --Version
       -a or --AppID
"""

import sys
import os
import getopt

import application_deployment
from config import config
from testing import validate_script_execution


def usage():
    """
    Returns the doc that mentions on how to use the script with command line arguments
    """

    sys.exit(__doc__)


def validate_arguments(sysparam):
    """
    Validate command line arguments passed to the script
    :param sysparam: Command line arguments : Script Name,
                    File Path, Application Name, Build Information, Deployment Type are required
                    Optional Parameters - Push Mode, Retire Previous Version Flag, Supported Device Models
                    and Options
    :return: void
    """

    app_version = '0'
    application_id = 0
    try:
        options, arguments = getopt.getopt(sysparam.argv[1:], 'hv:a:', ["help", "Version=", "AppID="])

    except getopt.GetoptError as error:
        options = None
        arguments = None
        print(error)
        usage()

    for option, arg in options:
        if option in ("-h", "--help"):
            usage()

        if option in ("-v", "--Version"):
            app_version = arg

        if option in ("-a", "--AppID"):
            application_id = arg
            arguments = arguments[(len(options) - 1):]

            if len(arguments) < 3 or not(arguments[0] and arguments[1] and arguments[2]):
                usage()

            return arguments, app_version, application_id

    if len(options) > 0:
        arguments = arguments[(len(options) - 1):]

    if len(arguments) < 4 or not(arguments[0] and arguments[1] and arguments[2] and arguments[3]):
        usage()

    if not os.path.exists(arguments[0]):
        print('Cannot locate the file path {}'.format(arguments[0]))
        sysparam.exit(1)

    return arguments, app_version, application_id


if __name__ == "__main__":
    args, version, app_id = validate_arguments(sys)
    if not int(app_id):
        application_deployment.add_new_application(args, version)
    else:
        application_deployment.edit_assignments(args, app_id)

    # Execute validations if the POST_SCRIPT_VALIDATION flag is set to 1 in config file,
    # Skip validations in case of editing assignments (app_id != 0 )
    if config.POST_SCRIPT_VALIDATION == 1 and app_id == 0:
        validate_script_execution.test_script_execution(sys)
