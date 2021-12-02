import requests
import json

from api_client.url_helpers.internal_app_url import get_internal_app
from Logs.log_configuration import configure_logger
from models.api_header_model import RequestHeader

log = configure_logger('default')


def get_app_details(app_id):
    """
    Get details of an internal app by using app id
    :param app_id: App ID
    :return: True/False indicating Success/Failure and app_details json that contains details of that app
    """

    api_url = get_internal_app(app_id)
    headers = RequestHeader().header

    try:
        response = requests.get(api_url, headers=headers)

        if not response.ok:
            log.error(f'{response.status_code}, {response.reason}, {response.content}')  # HTTP
            return False, 0

        else:
            app_details = json.loads(response.content)
            return True, app_details

    except Exception as e:
        log.error('Get application details failed for app_id {} with exception {}'.format(app_id, str(e)))
        return False, 0
