import json
import requests

from api_client.url_helpers.internal_app_url import get_create_internal_app_from_blob_url
from configuration import config
from models.api_header_model import RequestHeader
from Logs.log_configuration import configure_logger

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
        'Description': transaction_data.description,
        'BlobId': str(transaction_data.blob_id),
        'PushMode': transaction_data.push_mode,
        'ApplicationName': transaction_data.application_name,
        'FileName': transaction_data.file_name,
        'DeviceType': transaction_data.device_type,
        'EnableProvisioning': transaction_data.enable_provisioning,
        'UploadViaLink': transaction_data.upload_via_link,
        'LocationGroupId': config.TENANT_GROUP_ID,
        'SupportedModels': transaction_data.supported_models,
        'ActualFileVersion': None,
        'AppVersion': transaction_data.app_version
    }

    payload = json.dumps(api_body)

    try:
        response = requests.post(api_url, headers=headers, data=payload)

        if not response.ok:
            log.error(f'{response.status_code}, {response.reason}, {response.content}')  # HTTP
            return False, 0, 0, '', ''

        else:
            response_data = json.loads(response.content)
            app_version = response_data['AppVersion']
            app_name = response_data['ApplicationName']
            bundle_id = response_data['BundleId']
            log.info('Application saved with Application ID {id}'.format(id=response_data['Id']['Value']))
            return True, response_data['Id']['Value'], app_version, app_name, bundle_id

    except Exception as e:
        log.error('Application creation failed for transactionId: {}'.format(transaction_data.transaction_id, str(e)))