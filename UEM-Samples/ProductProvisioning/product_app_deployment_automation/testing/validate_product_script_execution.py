import os
import json
import getopt

from api_client.product_application_search import search_product_with_application_id
from Logs.log_configuration import configure_logger
from api_client.product_search import search_product_with_id
from configuration import config
from testing import product_deployment_tests

log = configure_logger('default')
JSON_FILE_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'productdetails.json')


def test_script_execution(sys_param):
    """
    Method to validate the script execution. It fetches the details of the uploaded product using product
    APIs and compares it against the parameters given during script execution and config file.
    :param sys_param: takes the script parameters as input
    """

    product_name_by_user = ''

    options, args = getopt.getopt(sys_param.argv[1:], 'hv:p:', ["help", "Version=", "ProductName="])
    for option, arg in options:
        if option in ("-p", "--ProductName"):
            product_name_by_user = arg
            args = args[(len(options) - 1):]

    build_name = args[1].split(',')[0]
    build_number = args[1].split(',')[1]
    deployment_type = str.lower(args[2])

    # Get the app id of the uploaded app
    with open(JSON_FILE_PATH) as f:
        result_product_deployment = json.load(f)
    for product in result_product_deployment[build_name][build_number]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            product_name = product['product_name']
            app_id = product['app_id']
    if product_name_by_user == '':
        actual_product_name = product_name
    else:
        actual_product_name = product_name_by_user

    # Hit the product details API using app id to fetch details of the product
    # Assuming one application is associated with one product
    product_search_status, product_id = search_product_with_application_id(app_id)

    assert product_search_status is not False, "Product not found"
    assert product_id != 0, "Product creation failed"

    status, result_product_details = search_product_with_id(product_id)

    assert status is not False, "Product not found"

    # Assertions
    if product_search_status:
        log.info("Validating the Product deployment:")

        product_deployment_tests.common_assertions(deployment_type,
                                                   actual_product_name,
                                                   result_product_details)
