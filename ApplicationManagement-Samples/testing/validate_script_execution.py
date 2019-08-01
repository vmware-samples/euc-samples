import os
import json
import getopt

from api_client.application_details import get_app_details
from config import config
from Logs.log_configuration import configure_logger
from testing import app_deployment_tests

log = configure_logger('default')
sample_app_dir = os.getcwd()
expected_sg = {'alpha': config.ALPHA_GROUPS, 'beta': config.BETA_GROUPS, 'prod': config.PRODUCTION_GROUPS}


def test_script_execution(sysparam):
    """
    Method to validate the script execution. It fetches the details of the uploaded app using internal
    app APIs and compares it against the parameters given during script execution and config file.
    :param sysparam: takes the script parameters as input
    """

    options, args = getopt.getopt(sysparam.argv[1:], 'hv:a:', ["help", "Version=", "AppID="])
    application_name = args[1]
    build_name = args[2].split(',')[0]
    build_number = args[2].split(',')[1]
    deployment_type = str.lower(args[3])
    expected_push_mode = args[4] if (len(args) > 4) else 'Auto'

    # Get the app id of the uploaded app
    with open('appdetails.json') as f:
        result_app_deployment = json.load(f)
    app_id = result_app_deployment[build_name][build_number]['app_id']

    # Hit the internal app details API using app id to fetch details of the app
    status, result_app_details = get_app_details(app_id)

    assert(status is True)

    # Assertions
    if status:
        log.info("Validating the App deployment:")

        app_deployment_tests.common_assertions(deployment_type,
                                               application_name,
                                               expected_push_mode,
                                               result_app_details)
