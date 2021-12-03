"""
Usage:
1. Adding new product
   Command - python deployment.py <File Path>, <Build Information>, <Deployment Type>, <Deactivate Old Product>
   Arguments: File Path, Build Information, Deployment Type and Deactivate Old Product are required parameters

***Refer Documentation for detailed information***

Flags: -h or --help
       -v or --Version
       -p or --ProductName
"""

import sys
import os
import getopt

from configuration import config
from product_deployment import add_new_product
from testing import validate_product_script_execution


def usage():
    """
    Returns the doc that mentions on how to use the script with command line arguments
    """

    sys.exit(__doc__)


def validate_arguments(sys_param):
    """
    Validate command line arguments passed to the script
    :param sys_param: Command line arguments : Script Name,
                    File Path, Build Information, Deployment Type, Deactivate Old Product are required
                    and Options
    :return: void
    """

    app_version = '0'
    product_name_by_user = ''

    try:
        options, arguments = getopt.getopt(sys_param.argv[1:], 'hv:p:', ["help", "Version=", "ProductName="])

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

        if option in ("-p", "--ProductName"):
            product_name_by_user = arg
            arguments = arguments[(len(options) - 1):]

        if len(arguments) < 3 or not (arguments[0] and arguments[1] and arguments[2]):
            usage()

        return arguments, app_version, product_name_by_user

    if len(options) > 0:
        arguments = arguments[(len(options) - 1):]

    if len(arguments) < 4 or not(arguments[0] and arguments[1] and arguments[2] and arguments[3]):
        usage()

    if not os.path.exists(arguments[0]):
        print('Cannot locate the file path {}'.format(arguments[0]))
        sys_param.exit(1)

    return arguments, app_version, product_name_by_user


if __name__ == "__main__":
    args, application_version, product_name = validate_arguments(sys)

    add_new_product(args, application_version, product_name)

    # Execute validations if the POST_SCRIPT_VALIDATION flag is set to 1 in config file
    if config.POST_SCRIPT_VALIDATION == 1:
        validate_product_script_execution.test_script_execution(sys)
