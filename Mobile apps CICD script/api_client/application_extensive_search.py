import requests
import json

from api_client.url_helpers.apps_url import get_apps_search_url
from config import config
from Logs.log_configuration import configure_logger
from models.api_header_model import RequestHeader

log = configure_logger('default')


def search_application(bundle_id):
    """
    Search for applications with the given Bundle ID
    :param bundle_id: Bundle ID (App Identifier)
    :return: True/False indicating Success/Failure and Application_list that matches the given Bundle ID
    """

    api_url = get_apps_search_url()

    headers = RequestHeader().header

    api_params = {
        'type': 'App',
        'applicationtype': 'Internal',
        'bundleid': bundle_id,
        'locationgroupid': config.TENANT_GROUP_ID,
        'productcomponentappsonly': 'False'
    }

    try:
        response = requests.get(api_url, headers=headers, params=api_params)

        if not response.ok:
            log.error(f'{response.status_code}, {response.reason}, {response.content}')  # HTTP
            return False, 0

        else:
            response_data = json.loads(response.content)
            app_list = response_data['Application']
            return True, app_list

    except Exception as e:
        log.error('Application Search failed: {}'.format(str(e)))
        return False
