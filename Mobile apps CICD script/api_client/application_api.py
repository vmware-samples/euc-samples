import requests
import json

from config import config
from api_client.url_helpers.internal_app_url import get_create_internal_app_from_blob_url, get_edit_assignment_url
from api_client.url_helpers.internal_app_url import get_retire_app_url, get_internal_app_assignment_url
from Logs.log_configuration import configure_logger
from models.api_header_model import RequestHeader

log = configure_logger('default')


def create_app(transaction_data):
    """
    Creates a new application based on the transaction data model
    :param transaction_data: Transaction data model
    :return: Returns True/False indicating Success/Failure and Application ID(0 in case of failure)
    """

    api_url = get_create_internal_app_from_blob_url()

    headers = RequestHeader().header

    api_body = {
        'TransactionId': str(transaction_data.transaction_id),
        'Description': transaction_data.description,
        'BlobId': transaction_data.blob_id,
        'PushMode': transaction_data.push_mode,
        'ApplicationName': transaction_data.application_name,
        'FileName': transaction_data.file_name,
        'DeviceType': transaction_data.device_type,
        'EnableProvisioning': transaction_data.enable_provisioning,
        'UploadViaLink': transaction_data.upload_via_link,
        'LocationGroupId': config.TENANT_GROUP_ID,
        'SupportedModels': transaction_data.supported_models,
        'BundleId': None,
        'ActualFileVersion': None,
        'AppVersion': transaction_data.app_version,
        'SupportedProcessorArchitecture': None,
        'MsiDeploymentParamModel': {'RetryCount': None,
                                    'InstallTimeoutInMinutes': None,
                                    'CommandLineArguments': None,
                                    'RetryIntervalInMinutes': None},
        'DeploymentOptions': None,
        'IsDependencyFile': False,
        'FilesOptions': None,
        'CarryOverAssignments': transaction_data.carry_over_assignments
    }

    payload = json.dumps(api_body)

    try:
        response = requests.post(api_url, headers=headers, data=payload)

        if not response.ok:
            log.debug(f'{response.status_code}, {response.reason}, {response.content}')  # HTTP
            return False, 0, 0, ''

        else:
            response_data = json.loads(response.content)
            app_version = response_data['AppVersion']
            bundle_id = response_data['BundleId']
            log.debug('Application saved with Application ID {id}'.format(id=response_data['Id']['Value']))
            return True, response_data['Id']['Value'], app_version, bundle_id

    except Exception as e:
        log.error('Application creation failed for transactionId: {}'.format(transaction_data.transaction_id, str(e)))


def retire_app(app_id):
    """
    Retires the app based on the Application ID
    :param app_id: Application ID
    :return: True/False indicating Success/Failure
    """

    api_url = get_retire_app_url(app_id)
    headers = RequestHeader().header

    try:
        response = requests.post(api_url, headers=headers)
        log.debug(f'{response.status_code}, {response.reason}, {response.content}')

        if not response.ok:
            return False

        else:
            return True

    except Exception as e:
        log.error('Application creation failed for transactionId: {}'.format(str(e)))


def add_assignments(app_id, app_assignment_model):
    """
    Assigns the app created to specified smart groups
    :param app_id: Application ID
    :param app_assignment_model: Assignment Model
    :return: True/False indicating Success/Failure
    """

    api_url = get_internal_app_assignment_url(app_id)
    headers = RequestHeader().header

    api_body = {
        'SmartGroupIds': app_assignment_model.smart_group_ids,
        'DeploymentParameters': app_assignment_model.deployment_parameters
    }

    payload = json.dumps(api_body)

    try:
        response = requests.post(api_url, headers=headers, data=payload)
        log.debug(f'{response.status_code}, {response.reason}, {response.content}')

        if not response.ok:
            return False

        else:
            log.debug('App with ID: {id} assigned to smartgroups {groups}'
                      .format(id=app_id, groups=app_assignment_model.smart_group_ids))
            return True

    except Exception as e:
        log.error('Application assignment failed for Application : {id} with error {e}'.format(id=app_id, e=str(e)))


def edit_app_assignment(app_id, app_assignment_model, assignment_group_for_deletion):
    """
    Edits the app assignment for given Application ID
    :param app_id: Application ID
    :param app_assignment_model: App assignment model
    :param assignment_group_for_deletion: Smartgroup IDs that has to be deleted from assignment
    :return: True/False indicating Success/Failure
    """

    api_url = get_edit_assignment_url(app_id)
    headers = RequestHeader().header

    api_body = {
        'SmartGroupIds': app_assignment_model.smart_group_ids,
        'SmartGroupIdsForDeletion': assignment_group_for_deletion,
        'DeploymentParameters': app_assignment_model.deployment_parameters
    }

    payload = json.dumps(api_body)

    try:
        response = requests.put(api_url, headers=headers, data=payload)
        log.debug(f'{response.status_code}, {response.reason}')

        if not response.ok:
            return False

        else:
            log.debug('App(AppID : {id}) assignment updated with smartgroups {groups}'
                      .format(id=app_id, groups=app_assignment_model.smart_group_ids))
            return True

    except Exception as e:
        log.error('Application edit assignment failed for Application: {id} with error {e}'.format(id=app_id, e=str(e)))
