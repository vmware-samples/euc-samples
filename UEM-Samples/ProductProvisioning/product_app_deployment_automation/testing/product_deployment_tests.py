import json
import os
import subprocess

from Logs.log_configuration import configure_logger
from api_client.product_search import search_product
from configuration import config
from testing import product_test_config

log = configure_logger('default')
FILE_DIRECTORY = os.path.dirname(os.path.dirname(__file__))


def execute_script(option, *args):
    """
    Execute the product deployment script from command prompt, update log file and return the details fetched
    from maintain product API
    :param option: additional options like -h
    :param args: command line arguments
    :return: json returned from the maintain product API, False when the script execution fails
    """

    if option == 'None':
        cmd_to_execute = ["python", os.path.join(FILE_DIRECTORY, 'deployment.py')]

    else:
        cmd_to_execute = ['python', os.path.join(FILE_DIRECTORY, 'deployment.py'), '-' + option]

    cmd_to_execute.extend([argument for argument in args])
    log.info('Executing: ' + str(cmd_to_execute))

    try:
        # Run the script
        script_output = str(subprocess.check_output(cmd_to_execute, shell=False))
        log.info('Script Output: \n' + script_output)

        if 'created successfully' or 'updated successfully' in script_output:
            if option is not 'None':
                build_info = str.split(args[2], ',')

            else:
                build_info = str.split(args[1], ',')

            # get the product details
            return get_product_details(build_info)

        else:
            return False

    except Exception as e:
        print('Script Execution failed: {}'.format(str(e)))
        log.info('Exception: \n' + str(e))
        return False


def get_product_details(build_info):
    """
    Get the product id of the uploaded product and using it, fetch product details via search product API
    :param build_info: build name and number for the app
    :return: json returned from the maintain product API.
    """

    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as file:
        result_product_deployment = json.load(file)

    for product in result_product_deployment[build_info[0]][build_info[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            app_id = product['app_id']
            product_id = product['product_id']
            product_name = product['product_name']
            log.info('App Id: ' + str(app_id))
            log.info('Product Id: ' + str(product_id))
            log.info('Product Name: ' + str(product_name))

    # Hit the Product extensive search API using the product_name
    api_params = {'name': product_name, 'managedbyorganizationgroupid': int(config.TENANT_GROUP_ID)}
    product_status, product_details_json = search_product(api_params)

    assert (product_status is True)
    return product_details_json


def get_file_location(file_name):
    """
    Gets file location
    :param file_name: File name
    :return : File location
    """
    sample_app_dir = os.path.dirname(os.path.realpath(__file__))
    return sample_app_dir + '\\Sample_Apps\\' + file_name


def get_file_with_different_version_location(file_name):
    """
    Gets file location
    :param file_name: File name
    :return : File location
    """
    sample_app_dir = os.path.dirname(os.path.realpath(__file__))
    return sample_app_dir + '\\Sample_Apps_2\\' + file_name


def common_assertions(deployment_type, expected_product_name, product_detail_json):
    """
    Assertions for common values like Product Name, App Status, Organization Group, Assigned SmartGroups
    :param deployment_type: Deployment type of the application: Alpha/Beta/Prod
    :param expected_product_name: Expected name of the product
    :param product_detail_json: Result of the search product API
    """

    list_of_all_deployment_types = {
        'alpha': config.ALPHA_GROUPS,
        'beta': config.BETA_GROUPS,
        'prod': config.PRODUCTION_GROUPS
    }
    expected_smart_groups = []

    for deployment in deployment_type.split(','):
        expected_smart_groups.append(list_of_all_deployment_types[deployment.lower()])
    # flatten the list
    expected_smart_groups = [mode for modes in expected_smart_groups for mode in modes]

    assignments = product_detail_json['SmartGroups']
    actual_sg_ids = [str(groups['SmartGroupId']) for groups in assignments]

    # Check for the product name
    assert product_detail_json['Name'] == expected_product_name, \
        'Product name is: {actual_name}.Expected was: {expected_name}' \
            .format(actual_name=product_detail_json['Name'], expected_name=expected_product_name)

    log.info('Name of the uploaded product matches the name provided in script arguments: {}'
             .format(expected_product_name))

    # Newly uploaded product should be in Active state
    assert product_detail_json['Active'] is True, 'Product Active Status is {}'.format(
        product_detail_json['Active'])

    log.info('Product Active Status is: {}'.format(product_detail_json['Active']))

    # Product should be managed by the correct Organization Group
    assert product_detail_json['ManagedByOrganizationGroupID'] == config.TENANT_GROUP_ID, \
        'Product was uploaded to Organization Group: {og_uploaded} instead of {og_config}' \
            .format(og_uploaded=product_detail_json['ManagedByOrganizationGroupID'],
                    og_config=config.TENANT_GROUP_ID)

    log.info('Product uploaded to the same Organization Group as mentioned in the Config File: {}'
             .format(config.TENANT_GROUP_ID))

    # Product should be assigned to correct Smart Groups
    assert actual_sg_ids == expected_smart_groups, \
        'Product assigned to {} which is same as SG mentioned in the config file'.format(actual_sg_ids)

    log.info('Product assigned to correct Smart Group as mentioned in the Config File: {}'.format(actual_sg_ids))


# test case 1
def test_upload_product():
    """
    End to End test case for uploading an product
    """

    # Input Values
    app_path = get_file_location(product_test_config.APK_1_FILE)
    deployment_type = 'Alpha'
    build_info = 'news project,1'
    deactivate_old_product = 'true'

    result_product_details = execute_script('None', app_path, build_info, deployment_type, deactivate_old_product)

    # Check if script execution was completed
    assert result_product_details is not False, 'Script execution failed!'

    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment = json.load(f)
    build_info = build_info.split(',')
    for product in result_product_deployment[build_info[0]][build_info[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            product_name = product['product_name']

    # Assertions
    common_assertions(deployment_type, product_name, result_product_details['Product'][0])


# test case 2
def test_invalid_file_path():
    """
    To test the script behaviour if we provide an invalid file path
    """

    expected_error_msg = 'Cannot locate the file path'
    script_error = None

    # Input Values
    app_path = product_test_config.APK_1_FILE
    build_info = 'No Job,8'
    deployment_type = 'Beta'
    deactivate_old_product = 'true'

    try:
        subprocess.check_output(
            ['python', os.path.join(FILE_DIRECTORY, 'deployment.py'), app_path, build_info, deployment_type,
             deactivate_old_product],
            shell=True)

    except subprocess.CalledProcessError as e:
        script_error = e.output

    # Assert that the script displays proper error message
    assert expected_error_msg in str(script_error), 'Script did not display error message for Invalid Path!'
    log.info('Proper error message was displayed for invalid file path.')


# test case 3
def test_invalid_file_type():
    """
    To test the script behaviour if we provide an invalid file type
    """

    expected_error_msg = 'Invalid File Type. Allowed File Type is .apk'
    script_error = None

    # Input Values
    app_path = get_file_location(product_test_config.INVALID_FILE)
    build_info = 'Image Job,9'
    deployment_type = 'Beta'
    deactivate_old_product = 'true'

    try:
        subprocess.check_output(
            ['python', os.path.join(FILE_DIRECTORY, 'deployment.py'), app_path, build_info, deployment_type,
             deactivate_old_product],
            shell=True)

    except subprocess.CalledProcessError as e:
        script_error = e.output

    # Assert that the script displays proper error message
    assert expected_error_msg in str(script_error), 'Script did not display error message for Invalid file type!'
    log.info('Proper error message was displayed for invalid file type.')


# test case 4
def test_upload_same_app_again():
    """
    To test the script behaviour if we try to upload the same app again
    """
    expected_error_msg = 'Application deployment failed'
    script_error = None

    # Input Values
    app_path = get_file_location(product_test_config.APK_3_FILE)
    build_info = 'workone,2'
    deployment_type = 'Alpha'
    deactivate_old_product = 'true'

    # Upload a product
    result_product_details = execute_script('None', app_path, build_info, deployment_type, deactivate_old_product)

    # Assertions
    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment = json.load(f)
    build_info_list = build_info.split(',')
    for product in result_product_deployment[build_info_list[0]][build_info_list[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            product_name = product['product_name']

    common_assertions(deployment_type, product_name, result_product_details['Product'][0])

    # Try to upload the same product again

    build_info = 'work,2'
    try:
        subprocess.check_output(
            ['python', os.path.join(FILE_DIRECTORY, 'deployment.py'), app_path, build_info, deployment_type,
             deactivate_old_product],
            shell=False)

    except subprocess.CalledProcessError as e:
        script_error = e.output

    # Assert that the script displays proper error message
    assert expected_error_msg in str(script_error), 'No error message shown when trying to upload an existing app!'
    log.info('Proper error message was displayed for when trying to upload the same app twice.')


# test case 5
def test_upload_product_with_different_version_of_same_application():
    """
    End to End test case for uploading product with different versions of same application
    """

    # Input Values
    app_path_version_1 = get_file_location(product_test_config.APK_4_FILE)
    deployment_type_version_1 = 'Alpha'
    build_info_version_1 = 'news project,1'
    deactivate_old_product = 'true'

    result_product_details = execute_script('None', app_path_version_1, build_info_version_1, deployment_type_version_1,
                                            deactivate_old_product)

    # Assertions
    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment = json.load(f)
    build_info = build_info_version_1.split(',')
    for product in result_product_deployment[build_info[0]][build_info[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            product_name = product['product_name']

    # Assertions
    common_assertions(deployment_type_version_1, product_name, result_product_details['Product'][0])

    # Try upload product with different version of same application
    app_path_version_2 = get_file_with_different_version_location(product_test_config.APK_4_FILE)
    deployment_type_version_2 = 'Alpha'
    build_info_version_2 = 'demo project,1'

    result_product_details = execute_script('None', app_path_version_2, build_info_version_2, deployment_type_version_2,
                                            deactivate_old_product)

    # Check if script has executed properly
    assert result_product_details is not False, 'Script execution failed!'

    # Check older product should be deactivated
    old_product = get_product_details(build_info)

    assert old_product['Product'][0]['Active'] is False, 'Older Product not deactivated'

    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment = json.load(f)
    build_info = build_info_version_2.split(',')
    for product in result_product_deployment[build_info[0]][build_info[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            product_name_version_2 = product['product_name']

    # Assertions
    common_assertions(deployment_type_version_2, product_name_version_2, result_product_details['Product'][0])


# test case 6
def test_upload_product_for_beta_deployment():
    """
    End to End test case for uploading an product for beta deployment
    """

    # Input Values
    app_path = get_file_location(product_test_config.APK_2_FILE)
    deployment_type = 'Beta'
    build_info = 'demoapp,1'
    deactivate_old_product = 'true'

    result_product_details = execute_script('None', app_path, build_info, deployment_type, deactivate_old_product)

    # Check if script execution was completed
    assert result_product_details is not False, 'Script execution failed!'

    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment = json.load(f)
    build_info = build_info.split(',')
    for product in result_product_deployment[build_info[0]][build_info[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            product_name = product['product_name']

    # Assertions
    common_assertions(deployment_type, product_name, result_product_details['Product'][0])


# test case 7
def test_update_product_to_beta_deployment():
    """
    End to End test case for uploading an product for beta deployment
    """

    # Input Values
    app_path = get_file_location(product_test_config.APK_5_FILE)
    deployment_type = 'Alpha'
    build_info = 'googledemo,1'
    deactivate_old_product = 'true'

    result_product_details = execute_script('None', app_path, build_info, deployment_type, deactivate_old_product)

    # Check if script execution was completed
    assert result_product_details is not False, 'Script execution failed!'

    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment = json.load(f)
    build_info_list = build_info.split(',')
    for product in result_product_deployment[build_info_list[0]][build_info_list[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            deployment_type = product['current_deployment']

    assert deployment_type == 'alpha', 'product creation failed'

    # updating product to Beta
    deployment_type_beta = 'Beta'
    result_product_beta_details = execute_script('None', app_path, build_info, deployment_type_beta,
                                                 deactivate_old_product)

    # Check if script execution was completed
    assert result_product_beta_details is not False, 'Script execution failed!'

    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment_beta = json.load(f)
    for product in result_product_deployment_beta[build_info_list[0]][build_info_list[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            deployment_type_result = product['current_deployment']
            product_name = product['product_name']

    assert deployment_type_result == 'beta', 'product creation failed'

    # Assertions
    common_assertions(deployment_type_beta, product_name, result_product_beta_details['Product'][0])


# test case 8
def test_four_digit_version():
    """
    End to End test case for uploading multiple versions of an app with 4 digit versions(Ex: 1.0.0.1)
    """

    # Input Values
    app1_path = get_file_location(product_test_config.APK_6_FOUR_DIGIT_V1_FILE)
    app2_path = get_file_with_different_version_location(product_test_config.APK_6_FOUR_DIGIT_V2_FILE)
    deployment_type = 'Beta'
    build_info_v1 = 'Four Digit,1'
    deactivate_old_product = 'true'

    # Push 1st App
    result_product_v1_details = execute_script('v', '1.0.0', app1_path, build_info_v1, deployment_type,
                                               deactivate_old_product)

    # Check if script execution was completed
    assert result_product_v1_details is not False, 'Script execution failed!'

    build_info_v2 = 'Four Digit,2'

    # Push 2nd App
    result_product_v2_details = execute_script('v', '1.0.1', app2_path, build_info_v2, deployment_type,
                                               deactivate_old_product)

    # Check if script execution was completed
    assert result_product_v2_details is not False, 'Script execution failed!'

    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment = json.load(f)

    build_info_v2 = str.split(build_info_v2, ',')
    for product in result_product_deployment[build_info_v2[0]][build_info_v2[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            product_name = product['product_name']

    # Assertions
    common_assertions(deployment_type, product_name, result_product_v2_details['Product'][0])


# test case 9
def test_alpha_numeric_version():
    """
    End to End test case for uploading multiple versions of an app with alphanumeric version number
    """

    # Input Values
    app1_path = get_file_location(product_test_config.APK_7_ALPHA_V1_FILE)
    app2_path = get_file_with_different_version_location(product_test_config.APK_7_ALPHA_V2_FILE)
    deployment_type = 'Beta'
    build_info_v1 = 'AlphaNum,6'
    deactivate_old_product = 'true'

    # Push 1st App
    result_product_v1_details = execute_script('v', '1.0.1', app1_path, build_info_v1, deployment_type,
                                               deactivate_old_product)

    # Check if script execution was completed
    assert result_product_v1_details is not False, 'Script execution failed!'

    build_info_v2 = 'AlphaNumeric,7'

    # Push 2nd App
    result_product_v2_details = execute_script('v', '1.0.2', app2_path, build_info_v2, deployment_type,
                                               deactivate_old_product)

    # Check if script execution was completed
    assert result_product_v2_details is not False, 'Script execution failed!'

    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment = json.load(f)

    build_info_v2 = str.split(build_info_v2, ',')
    for product in result_product_deployment[build_info_v2[0]][build_info_v2[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            product_name = product['product_name']

    # Assertions
    common_assertions(deployment_type, product_name, result_product_v2_details['Product'][0])


# test case 10
def test_check_invalid_product_name():
    """
    End to End test case for checking product name
    """
    expected_error = 'Product name invalid'

    app_path = get_file_location(product_test_config.APK_6_FILE)
    deployment_type = 'Alpha'
    build_info = 'news project,1'
    deactivate_old_product = 'true'

    result_product_details = execute_script('p', 'product_demo', app_path, build_info, deployment_type,
                                            deactivate_old_product)

    # Check if script execution was completed
    assert result_product_details is not False, 'Script execution failed!'

    app_path_2 = get_file_location(product_test_config.APK_7_FILE)
    deployment_type_2 = 'Alpha'
    build_info_2 = 'demo,1'

    try:
        subprocess.check_output(
            ['python', os.path.join(FILE_DIRECTORY, 'deployment.py'), '-p' 'product_demo', app_path_2, build_info_2,
             deployment_type_2, deactivate_old_product],
            shell=False)

    except subprocess.CalledProcessError as e:
        script_error = e.output

    # Assert that the script displays proper error message
    assert expected_error in str(script_error), 'Script did not display error message for Invalid product name!'
    log.info('Proper error message was displayed for invalid product name.')


# test case 11
def test_update_product_to_prod_deployment():
    """
    End to End test case for updating product for prod deployment
    """

    # Input Values
    app_path = get_file_location(product_test_config.APK_8_FILE)
    deployment_type = 'Alpha'
    build_info = 'testproduct,1'
    deactivate_old_product = 'true'

    result_product_details = execute_script('None', app_path, build_info, deployment_type, deactivate_old_product)

    # Check if script execution was completed
    assert result_product_details is not False, 'Script execution failed!'

    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment = json.load(f)
    build_info_list = build_info.split(',')
    for product in result_product_deployment[build_info_list[0]][build_info_list[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            deployment_type = product['current_deployment']

    assert deployment_type == 'alpha', 'product creation failed'

    # updating product to Prod
    deployment_type_prod = 'Prod'
    result_product_prod_details = execute_script('None', app_path, build_info, deployment_type_prod,
                                                 deactivate_old_product)

    # Check if script execution was completed
    assert result_product_prod_details is not False, 'Script execution failed!'

    with open(os.path.join(FILE_DIRECTORY, 'productdetails.json')) as f:
        result_product_deployment_prod = json.load(f)
    for product in result_product_deployment_prod[build_info_list[0]][build_info_list[1]]:
        if product['organization_group'] == config.TENANT_GROUP_ID:
            deployment_type_result = product['current_deployment']
            product_name = product['product_name']

    assert deployment_type_result == 'prod', 'product creation failed'

    # Assertions
    common_assertions(deployment_type_prod, product_name, result_product_prod_details['Product'][0])
