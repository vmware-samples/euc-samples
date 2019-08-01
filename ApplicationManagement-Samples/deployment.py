"""
Usage: 1. python deployment.py <File Path>, <Application Name>, <Build Information>, <Deployment Type>(Alpha/Beta/Prod)
       2. python deployment.py <File Path>, <Application Name>, <Build Information>, <Deployment Type>(Alpha/Beta/Prod),
       <Push Mode>(Auto/Ondemand), <Retire Previous Version>(True/False), <Supported Device Models>(ex: "iPad,iPhone")
       3. Use v/Version option to give a numeric app version, if the file version is more than 4 digits/ Alpha numeric
       4. Please provide AppID using the option -a/AppID option, in case of edit assignment
       5. Supported models and device type are required in case of windows universal app
          python deployment.py <File Path>, <Application Name>, <Build Information>, <Deployment Type>, <PushMode>,
          <Retire Previous Version>, <Supported Device Models>, <Device Type>

        ***Refer Documentation for detailed information***

Arguments: File Path, Application Name, Build Information and Deployment Type are required parameters

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
    application_deployment.deploy_application(args, version, app_id)

    # Execute validations if the POST_SCRIPT_VALIDATION flag is set to 1 in config file,
    # Skip validations in case of editing assignments (app_id != 0 )
    if config.POST_SCRIPT_VALIDATION == 1 and app_id == 0:
        validate_script_execution.test_script_execution(sys)
