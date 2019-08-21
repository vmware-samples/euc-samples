import os
import json
import subprocess

from api_client.application_details import get_app_details
from config import config
from testing import test_config
from Logs.log_configuration import configure_logger

log = configure_logger('default')


def execute_script(option, *args):
    """
    Execute the app deployment script from command prompt, update log file and return the details fetched
    from internal app API
    :param option: additional options like -a, -v
    :param args: command line arguments
    :return: json returned from the internal app API, False when the script execution fails
    """

    if option == 'None':
        cmd_to_execute = ['python', 'deployment.py']

    else:
        cmd_to_execute = ['python', 'deployment.py', '-' + option]

    cmd_to_execute.extend([argument for argument in args])
    log.info('Executing: ' + str(cmd_to_execute))

    try:
        # Run the script
        script_output = str(subprocess.check_output(cmd_to_execute, shell=True))
        log.info('Script Output: \n' + script_output)

        if 'deployed successfully' in script_output:
            if option is not 'None':
                build_info = str.split(args[3], ',')

            else:
                build_info = str.split(args[2], ',')

            # get the internal app details
            return get_internal_app_details(build_info)

        else:
            return False

    except Exception as e:
        print('Script Execution failed: {}'.format(str(e)))
        return False


def get_assignment_details(app_detail_result):
    """
    Method to fetch smart group ids, names and push mode where the app has been deployed
    :param app_detail_result: json returned from the app details api
    :return: list of smart group ids, list of smart group names and push mode
    """

    assignments = app_detail_result['Assignments']
    sg_ids = [groups['SmartGroupId'] for groups in assignments]
    sg_names = [groups['SmartGroupName'] for groups in assignments]
    push_mode = [groups['PushMode'] for groups in assignments]

    return sg_ids, sg_names, push_mode


def common_assertions(deployment_type, expected_application_name, expected_push_mode, app_detail_json):
    """
    Assertions for common values like App Name, App Status, Organization Group, Assigned SmartGroups
    :param deployment_type: Deployment type of the application: Alpha/Beta/Prod
    :param expected_application_name: Expected name of the application
    :param expected_push_mode: Expected Push Mode for the App: Auto/OnDemand
    :param app_detail_json: Result of the internal app details API
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

    actual_sg_ids, actual_sg_names, actual_push_mode = get_assignment_details(app_detail_json)

    # Check for the application name
    assert app_detail_json['ApplicationName'] == expected_application_name, \
        'App name is: {actual_name}.Expected was: {expected_name}' \
        .format(actual_name=app_detail_json['ApplicationName'], expected_name=expected_application_name)

    log.info('Name of the uploaded app matches the name provided in script arguments: {}'
             .format(expected_application_name))

    # Newly uploaded app should be in Active state
    assert app_detail_json['Status'] == 'Active', 'App is in {} status'.format(app_detail_json['Status'])

    log.info('App Status is: {}'.format(app_detail_json['Status']))

    # App should be managed by the correct Organization Group
    assert app_detail_json['ManagedBy'] == config.TENANT_GROUP_ID, \
        'App was uploaded to Organization Group: {og_uploaded} instead of {og_config}' \
        .format(og_uploaded=app_detail_json['ManagedBy'], og_config=config.TENANT_GROUP_ID)

    log.info('App uploaded to the same Organization Group as mentioned in the Config File: {}'
             .format(config.TENANT_GROUP_ID))

    # App should be assigned to correct Smart Groups
    assert actual_sg_ids == expected_smart_groups, \
        'App assigned to {} which is not same as SG mentioned in the config file'.format(actual_sg_names)

    log.info('App assigned to correct Smart Group as mentioned in the Config File: {}'.format(actual_sg_names))

    # Push mode should be as specified in the script parameters ('Auto' if not specified)
    assert expected_push_mode.lower() == actual_push_mode[0].lower(), \
        'App was pushed in {actual_mode} mode, instead of {expected_mode}' \
        .format(actual_mode=actual_push_mode[0], expected_mode=expected_push_mode)

    log.info('App push mode is same as mentioned in the script parameters:  {}'.format(expected_push_mode))


def get_internal_app_details(build_info):
    """
    Get the app id of the uploaded app and using it, fetch app details via internal app API
    :param build_info: build name and number for the app
    :return: json returned from the internal app API.
    """

    with open('appdetails.json') as file:
        result_app_deployment = json.load(file)

    app_id = result_app_deployment[build_info[0]][build_info[1]]['app_id']
    log.info('App Id: ' + str(app_id))

    # Hit the Internal app details API using the app_id
    api_status, app_details_json = get_app_details(app_id)

    assert (api_status is True)
    return app_details_json


def get_file_location(file_name):
    sample_app_dir = os.path.dirname(os.path.realpath(__file__))
    return sample_app_dir + '\\Sample_Apps\\' + file_name


# Test Cases:
# 1
def test_upload_app_and_edit_assignments():
    """
    End to End test case for uploading an app and then editing the assignments
    """

    # Input Values
    app_path = get_file_location(test_config.APK_1_FILE)
    app_name = test_config.APK_1_NAME
    deployment_type = 'alpha'
    build_info = 'news project,1'

    result_app_details = execute_script('None', app_path, app_name, build_info, deployment_type)

    application_id = result_app_details['id']

    # Check if script execution was completed
    assert result_app_details is not False, 'Script execution failed!'

    # Assertions
    common_assertions(deployment_type, app_name, 'auto', result_app_details)

    # Edit the app assignments
    output = str(subprocess.check_output(['python', 'deployment.py', '-a', str(application_id), build_info,
                                          'beta', 'ondemand'], shell=True))
    log.info('Output of script execution for editing the assignments: ')
    log.info(output)

    # Get the details of the app
    app_details_json = get_internal_app_details(build_info.split(','))

    # Assert that the assignment should be updated and other details should be the same
    common_assertions('beta', app_name, 'ondemand', app_details_json)


# 2
def test_for_windows_xap():
    """
    End to End test case for uploading and assigning a windows xap
    """

    # Input Values
    app_path = get_file_location(test_config.XAP_1_FILE)
    app_name = test_config.XAP_1_NAME
    deployment_type = 'Beta'
    build_info = 'WIN APP Build Project,1'

    result_app_details = execute_script('None', app_path, app_name, build_info, deployment_type)

    # Check if script execution was completed
    assert result_app_details is not False, 'Script execution failed!'

    # Assertions
    common_assertions(deployment_type, app_name, 'Auto', result_app_details)


# 3
def test_on_demand_deployment():
    """
    End to End test case for testing the OnDemand deployment
    """

    # Input Values
    app_path = get_file_location(test_config.APK_2_FILE)
    app_name = test_config.APK_2_NAME
    deployment_type = 'Alpha'
    build_info = 'Quora Project,1'
    push_mode = 'OnDemand'

    result_app_details = execute_script('None', app_path, app_name, build_info, deployment_type, push_mode)

    # Check if script execution was completed
    assert result_app_details is not False, 'Script execution failed!'

    # Assertions
    common_assertions(deployment_type, app_name, push_mode, result_app_details)


# 4
def test_upload_higher_version():
    """
    End to End test case for testing the scenario when we upload 2 versions of the same app
    """

    # Input Values
    app_v1_path = get_file_location(test_config.APK_3_V1_FILE)
    app_v2_path = get_file_location(test_config.APK_3_V2_FILE)
    app_name = test_config.APK_3_NAME
    deployment_type = 'Alpha'
    push_mode = 'OnDemand'
    build_info_v1 = 'App Project,1'

    # Push 1st App
    result_app_v1_details = execute_script('None', app_v1_path, app_name, build_info_v1, deployment_type, push_mode)

    # Check if script execution was completed
    assert result_app_v1_details is not False, 'Script execution failed!'

    build_info_v2 = 'App Project,2'

    # Push 2nd App
    result_app_v2_details = execute_script('None', app_v2_path, app_name, build_info_v2, deployment_type, push_mode)

    # Check if script execution was completed
    assert result_app_v2_details is not False, 'Script execution failed!'

    # Assertions
    common_assertions(deployment_type, app_name, push_mode, result_app_v2_details)


# 5
def test_four_digit_version():
    """
    End to End test case for uploading multiple versions of an app with 4 digit versions(Ex: 1.0.0.1)
    """

    # Input Values
    app1_path = get_file_location(test_config.APK_4_FOUR_DIGIT_V1_FILE)
    app2_path = get_file_location(test_config.APK_4_FOUR_DIGIT_V2_FILE)
    app_name = test_config.APK_4_NAME
    deployment_type = 'Beta'
    build_info_v1 = 'Four Digit,1'
    push_mode = 'Auto'

    # Push 1st App
    result_app_v1_details = execute_script('v', '1.0.0', app1_path, app_name, build_info_v1, deployment_type, push_mode)

    # Check if script execution was completed
    assert result_app_v1_details is not False, 'Script execution failed!'

    build_info_v2 = 'Four Digit,2'

    # Push 2nd App
    result_app_v2_details = execute_script('v', '1.0.1', app2_path, app_name, build_info_v2, deployment_type, push_mode)

    # Check if script execution was completed
    assert result_app_v2_details is not False, 'Script execution failed!'

    # Assertions
    common_assertions(deployment_type, app_name, push_mode, result_app_v2_details)


# 6
def test_alpha_numeric_version():
    """
    End to End test case for uploading multiple versions of an app with alphanumeric version number
    """

    # Input Values
    app1_path = get_file_location(test_config.APK_7_ALPHA_V1_FILE)
    app2_path = get_file_location(test_config.APK_7_ALPHA_V2_FILE)
    app_name = test_config.APK_7_NAME
    deployment_type = 'Beta'
    build_info_v1 = 'AlphaNum,6'
    push_mode = 'ondemand'

    # Push 1st App
    result_app_v1_details = execute_script('v', '1.0.1', app1_path, app_name, build_info_v1, deployment_type, push_mode)

    # Check if script execution was completed
    assert result_app_v1_details is not False, 'Script execution failed!'

    build_info_v2 = 'AlphaNum,7'
    # Push 2nd App
    result_app_v2_details = execute_script('v', '1.0.2', app2_path, app_name, build_info_v2, deployment_type, push_mode)

    # Check if script execution was completed
    assert result_app_v2_details is not False, 'Script execution failed!'

    # Assertions
    common_assertions(deployment_type, app_name, push_mode, result_app_v2_details)


# 7
def test_upload_lower_version():
    """
    End to End test case for uploading lower version of an already uploaded application
    """

    # Input Values
    app1_path = get_file_location(test_config.APK_5_V2_FILE)
    app2_path = get_file_location(test_config.APK_5_V1_FILE)
    app_name = test_config.APK_5_NAME
    deployment_type = 'Alpha'
    build_info_v1 = 'Lower Version,1'
    push_mode = 'Auto'

    # Push 1st App
    result_app_v1_details = execute_script('None', app1_path, app_name, build_info_v1, deployment_type, push_mode)

    # Check if script execution was completed
    assert result_app_v1_details is not False, 'Script execution failed!'

    build_info_v2 = 'Lower Version,2'
    # Push 2nd App
    result_app_v2_details = execute_script('None', app2_path, app_name, build_info_v2, deployment_type, push_mode)

    # Check if script execution was completed
    assert result_app_v2_details is not False, 'Script execution failed!'

    # Assertions
    common_assertions(deployment_type, app_name, push_mode, result_app_v2_details)


# 8
def test_invalid_file_path():
    """
    To test the script behaviour if we provide an invalid file path
    """

    expected_error_msg = 'Cannot locate the file path'
    script_error = None

    # Input Values
    app_path = test_config.APK_1_FILE
    app_name = test_config.APK_1_NAME
    build_info = 'No Job,8'
    deployment_type = 'Beta'

    try:
        subprocess.check_output(
            ['python', 'deployment.py', app_path, app_name, build_info, deployment_type], shell=True)

    except subprocess.CalledProcessError as e:
        script_error = e.output

    # Assert that the script displays proper error message
    assert expected_error_msg in str(script_error), 'Script did not display error message for Invalid Path!'
    log.info('Proper error message was displayed for invalid file path.')


# 9
def test_invalid_file_type():
    """
    To test the script behaviour if we provide an invalid file type
    """

    expected_error_msg = 'Invalid File Type. Allowed File Types are .apk, .ipa, .xap, .appx'
    script_error = None

    # Input Values
    app_path = get_file_location(test_config.INVALID_FILE)
    app_name = 'Invalid file'
    build_info = 'Image Job,9'
    deployment_type = 'Beta'

    try:
        subprocess.check_output(
            ['python', 'deployment.py', app_path, app_name, build_info, deployment_type], shell=True)

    except subprocess.CalledProcessError as e:
        script_error = e.output

    # Assert that the script displays proper error message
    assert expected_error_msg in str(script_error), 'Script did not display error message for Invalid file type!'
    log.info('Proper error message was displayed for invalid file type.')


# 10
def test_invalid_deployment_type():
    """
    To test the script behaviour if we provide an invalid deployment type
    """

    expected_error_msg = 'Invalid deployment type'
    script_error = None

    # Input Values
    app_path = get_file_location(test_config.APK_1_FILE)
    app_name = test_config.APK_1_NAME
    build_info = 'Invalid Deployment,10'
    deployment_type = 'Invalid Deployment Type'

    try:
        subprocess.check_output(
            ['python', 'deployment.py', app_path, app_name, build_info, deployment_type], shell=True)

    except subprocess.CalledProcessError as e:
        script_error = e.output

    # Assert that the script displays proper error message
    assert expected_error_msg in str(script_error), 'Script did not display error message for Invalid deployment type!'
    log.info('Proper error message was displayed for invalid deployment type.')


# 11
def test_upload_same_app_again():
    """
    To test the script behaviour if we try to upload the same app again
    """
    expected_error_msg = 'Application deployment failed'
    script_error = None

    # Input Values
    app_path = get_file_location(test_config.APK_6_FILE)
    app_name = test_config.APK_6_NAME
    build_info = 'Hello App,11'
    deployment_type = 'alpha'
    push_mode = 'ondemand'

    # Upload an app
    result_app_details = execute_script('None', app_path, app_name, build_info, deployment_type, push_mode)

    # Assertions
    common_assertions(deployment_type, app_name, push_mode, result_app_details)

    # Try to upload the same app again
    try:
        subprocess.check_output(
            ['python', 'deployment.py', app_path, app_name, build_info, deployment_type], shell=True)

    except subprocess.CalledProcessError as e:
        script_error = e.output

    # Assert that the script displays proper error message
    assert expected_error_msg in str(script_error), 'No error message shown when trying to upload an existing app!'
    log.info('Proper error message was displayed for when trying to upload the same app twice.')


# 12
def test_for_ios_ipa():
    """
    End to End test case for uploading and assigning an iOS ipa application
    """

    # Input Values
    app_path = get_file_location(test_config.IPA_1_FILE)
    app_name = test_config.IPA_1_NAME
    deployment_type = 'Alpha'
    build_info = 'iOS Build Project,12'

    result_app_details = execute_script('None', app_path, app_name, build_info, deployment_type)

    # Check if script execution was completed
    assert result_app_details != False, 'Script execution failed!'

    # Assertions
    common_assertions(deployment_type, app_name, 'Auto', result_app_details)


# 13
def test_for_win_appx():
    """
    End to End test case for uploading and assigning a windows appx application
    """

    # Input Values
    app_path = get_file_location(test_config.APPX_1_FILE)
    app_name = test_config.APPX_1_NAME
    deployment_type = 'Alpha'
    build_info = 'Appx Build Project,13'

    result_app_details = execute_script('None', app_path, app_name, build_info, deployment_type, 'Auto',
                                        'false', 'Windows Phone 8', 'WindowsPhone8')

    # Check if script execution was completed
    assert result_app_details != False, 'Script execution failed!'

    # Assertions
    common_assertions(deployment_type, app_name, 'Auto', result_app_details)


# 14
def test_for_multi_deployment():
    """
    End to End test case for uploading an app with multiple deployment types
    """

    # Input Values
    app_path = get_file_location(test_config.APK_8_FILE)
    app_name = test_config.APK_8_NAME
    deployment_type = 'Alpha,Beta'
    build_info = 'Appx Build Project,14'

    result_app_details = execute_script('None', app_path, app_name, build_info, deployment_type)

    # Check if script execution was completed
    assert result_app_details != False, 'Script execution failed!'

    # Assertions
    common_assertions(deployment_type, app_name, 'Auto', result_app_details)
