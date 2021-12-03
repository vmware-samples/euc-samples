import requests
import json

from models.api_header_model import RequestHeader
from Logs.log_configuration import configure_logger
from api_client.url_helpers.product_url import get_product_application_url

log = configure_logger('default')


def search_product_with_application_id(app_id):
    """
    Searches for Products based on application id association
    :param app_id: application id that is being used in products
    :return : True or False Indicates Success (Product Found) or Failure (Product Not Found) and ProductID
    """

    api_url = get_product_application_url(app_id)

    headers = RequestHeader().header

    try:
        response = requests.get(api_url, headers=headers)
        if not response.ok:
            log.error(response.status_code, response.reason,
                      response.content)  # HTTP
            return False, response
        else:
            log.info(response.content)
            response_data = json.loads(response.content)
            return True, response_data[0]['ProductID']
    except Exception as e:
        log.error('Product Search failed for app id {} with exception {}'.format(app_id, str(e)))
        return False, response
