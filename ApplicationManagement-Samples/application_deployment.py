import os
import sys

from api_client.application_api import create_app, retire_app, add_assignments, edit_app_assignment
from api_client.application_extensive_search import search_application
from api_client.blob_api import chunk_upload
from config import config
import helper.helper_methods as helper
from Logs.log_configuration import configure_logger
from models.app_chunk_transaction_data import AppChunkTransactionData
from models.assignment_model import AppAssignment

log = configure_logger('default')


def create_application(app_chunk_transaction, source_file_path, build_info, assignment_group, retire_previous_version):
    """
    Adds application and assigns it to a particular smart group
    :param app_chunk_transaction: app_chunk_transaction_data model
    :param source_file_path: File path of the application
    :param build_info: Build Information(Build Project Name and Build Number)
    :param assignment_group: Assignment group
    :param retire_previous_version: Flag used to retire previous version of the app
    :return: True/False to indicate Success/Failure and Application ID
    """

    blob_upload_success, app_chunk_transaction.transaction_id = chunk_upload(source_file_path)

    if blob_upload_success:
        log.info('Application {application_name} uploaded successfully with transaction ID {id}'
                 .format(application_name=app_chunk_transaction.application_name,
                         id=app_chunk_transaction.transaction_id))

        app_create_success, app_id, current_app_version, bundle_id = create_app(app_chunk_transaction)

        if app_create_success:
            log.info('{application_name} application created successfully'
                     .format(application_name=app_chunk_transaction.application_name))

            # retire_previous_version is a string that can hold either true/false
            # (Not a boolean as it is a command line arg)
            if retire_previous_version == 'true':
                search_success, app_list = search_application(bundle_id)

                previous_version = '0.0.0'
                application_id = 0

                if len(app_list) > 1:
                    for app in app_list:
                        version = app['AppVersion']
                        organization_group_id = str(app['LocationGroupId'])

                        # Gets Application ID for previous version of the app
                        if current_app_version > version > previous_version \
                                and config.TENANT_GROUP_ID == organization_group_id:
                            previous_version = version
                            application_id = app['Id']['Value']

                    if not application_id == 0:
                        app_retire_success = retire_app(application_id)

                        if app_retire_success:
                            log.info('Previous version of {application_name} retired'
                                     .format(application_name=app_chunk_transaction.application_name))

                        else:
                            log.error('Retiring previous version of the application {application_name} failed'
                                      .format(application_name=app_chunk_transaction.application_name))

                    else:
                        log.info('Active previous version of the application {application_name} does not exist'
                                 .format(application_name=app_chunk_transaction.application_name))

                else:
                    log.info('There are no previous versions of the application {application_name}'
                             .format(application_name=app_chunk_transaction.application_name))

            else:
                log.info("Not retiring previous version. Continuing...")

            app_assignment_model = AppAssignment(assignment_group, app_chunk_transaction.push_mode)

            app_assignment_success = add_assignments(app_id, app_assignment_model)

            if app_assignment_success:
                log.info('{application_name} application assigned to {assignment_group} group successfully'
                         .format(application_name=app_chunk_transaction.application_name,
                                 assignment_group=assignment_group))

                helper.write_app_id(build_info, app_id, 0, current_app_version, assignment_group)
                return True, app_id

            else:
                log.error('{application_name} application assignment failed'
                          .format(application_name=app_chunk_transaction.application_name))
                return False, app_id

        else:
            log.error('{application_name} application save failed'
                      .format(application_name=app_chunk_transaction.application_name))
            return False, 0

    else:
        log.error('{} blob upload failed'.format(app_chunk_transaction.application_name))
        return False, 0


def get_device_type_and_models(file_extension, supported_models, sys_param):
    """
    Returns the device type and supported device models for the application
    :param file_extension: File extension that indicates the device type supported. Ex : apk - Android
    :param supported_models: List of device models supported for the application as given by the user
    :param sys_param: Command line arguments
    :return: Device Type and List of supported models
    """

    device_models = []

    if file_extension == 'apk':
        device_type = 'Android'

        if supported_models is None:
            device_models = [{'ModelName': 'Android'}]
            supported_device_models = {'Model': device_models}
            return device_type, supported_device_models

    elif file_extension == 'ipa':
        device_type = 'Apple'

        if supported_models is None:
            device_models = [{'ModelName': 'iPhone'},
                             {'ModelName': 'iPod Touch'},
                             {'ModelName': 'iPad'}]
            supported_device_models = {'Model': device_models}
            return device_type, supported_device_models

    elif file_extension == 'xap':
        device_type = 'windowsphone8'

        if supported_models is None:
            device_models = [{'ModelName': 'Windows Phone 8'},
                             {'ModelName': 'Windows Phone 10'}]
            supported_device_models = {'Model': device_models}
            return device_type, supported_device_models

    elif file_extension == 'appx':
        if len(sys_param) < 8:
            log.error('Supported Models and Device type required for Universal Windows App')
            sys.exit(1)
        device_type = sys_param[7]

    else:
        log.error('Invalid File Type. Allowed File Types are .apk, .ipa, .xap, .appx')
        sys.exit(1)

    for model in supported_models:
        device_models.append({'ModelName': model})

    supported_device_models = {'Model': device_models}
    return device_type, supported_device_models


def update_app_assignments(build_info, assignment_groups, push_mode, application_id):
    """
    Updates app assignment with the given smart groups
    :param build_info: Build Information(Build Project Name and Build Number)
    :param assignment_groups: Assignment groups to which the app has to be assigned
    :param push_mode: Push Mode
    :param application_id: Application ID
    :return: True/False indicating Success/Failure
    """

    assignment_group_for_deletion = None
    current_app_deployments = None

    try:
        # Existing assignments
        current_app_deployments = helper.get_app_details_from_json(build_info)

    except KeyError:
        log.error('App: {id} does not exist'.format(id=application_id))
        sys.exit(1)

    if current_app_deployments is not None:
        # Identify smart groups that has to be deleted from the assignment
        assignment_group_for_deletion = list(set(current_app_deployments) - set(assignment_groups))

    app_assignment_model = AppAssignment(assignment_groups, push_mode)
    assignment_update_success = edit_app_assignment(application_id, app_assignment_model, assignment_group_for_deletion)

    if assignment_update_success:
        log.info('App assignment updated successfully')
        helper.update_app_assignment_details_in_json(build_info, assignment_groups)
        return True

    log.error('Updating app assignment failed')
    return False


def get_build_information(build_info_arg):
    """
    Parses the command line argument to fetch Build information
    :param build_info_arg: Command line argument to fetch build information
    :return: Build information - Build Project Name and Build Number
    """

    build_info = []
    if config.BUILD_SERVER_URL:
        build_info.append(config.BUILD_PROJECT_NAME)

        # Runs the jenkins script to get the build number from the integrated jenkins build server
        build_info.append(str(os.system(build_info_arg)))
    else:
        build_info = str.split(build_info_arg, ',')

    return build_info


def get_assignment_groups(deployment_types):
    """
    Gets the assignment group Ids for given deployment types
    :param deployment_types: Deployment Types - Alpha, Beta, Prod
    :return: Assignment Group IDs
    """

    assignment_groups = []
    for deployment_type in deployment_types:
        if deployment_type == 'alpha':
            assignment_groups += config.ALPHA_GROUPS
        elif deployment_type == 'beta':
            assignment_groups += config.BETA_GROUPS
        elif deployment_type == 'prod':
            assignment_groups += config.PRODUCTION_GROUPS
        else:
            log.error('Invalid deployment type')
            sys.exit(1)

    return assignment_groups


def add_new_application(sys_param, version):
    """
    Uploads, creates, assigns and deploys an application to console
    :param sys_param: Command line arguments
    :param version: Application version
    :returns void
    """

    log.info('Application Deployment started...')

    source_file_path = sys_param[0]
    application_name = sys_param[1]

    build_info = get_build_information(sys_param[2])

    deployment_types = str.split(str.lower(sys_param[3]), ',')
    assignment_groups = get_assignment_groups(deployment_types)

    # Default values for push mode and retire previous version flag
    push_mode = 'Auto'
    retire_previous_version = False

    file_name = os.path.basename(source_file_path)
    file_extension = str.split(file_name, '.')[-1:][0].lower()

    supported_models = None

    if len(sys_param) > 4:
        push_mode = sys_param[4]

        if len(sys_param) >= 6:
            retire_previous_version = sys_param[5].lower()

            if len(sys_param) >= 7:
                supported_models = str.split(sys_param[6], ',')

    device_type, supported_device_models = get_device_type_and_models(file_extension, supported_models, sys_param)

    app_chunk_transaction = AppChunkTransactionData(application_name,
                                                    build_info,
                                                    file_name,
                                                    push_mode,
                                                    device_type,
                                                    supported_device_models)

    # App version is given as an input by the user
    if version > '0':
        app_chunk_transaction.app_version = version

    app_deploy_success, _ = create_application(app_chunk_transaction,
                                               source_file_path,
                                               build_info,
                                               assignment_groups,
                                               retire_previous_version)

    if app_deploy_success:
        log.info('App {app_name} deployed successfully to {deployment_type} group'
                 .format(app_name=application_name, deployment_type=deployment_types))

    else:
        log.error('Application deployment failed')
        sys.exit(1)


def edit_assignments(args, app_id):
    """
    Updates the assignments for a given application
    :param args: Command line arguments
    :param app_id: Application ID
    :return: void
    """

    build_info = get_build_information(args[0])
    deployment_types = str.split(str.lower(args[1]), ',')
    assignment_groups = get_assignment_groups(deployment_types)
    push_mode = args[2]

    app_deploy_success = update_app_assignments(build_info, assignment_groups, push_mode, app_id)

    if app_deploy_success:
        log.info('Application with AppID: {app_id} updated with new assignments Push Mode: {push_mode}, '
                 'Assignment Groups: {deployment_types}'.format(app_id=app_id, push_mode=push_mode,
                                                                deployment_types=deployment_types))

    else:
        log.error('Updating App assignment for Application with AppID: {app_id} failed'.format(app_id=app_id))
        sys.exit(1)
