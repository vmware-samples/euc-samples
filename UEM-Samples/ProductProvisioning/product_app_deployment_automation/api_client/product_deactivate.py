import requests
import json

from Logs.log_configuration import configure_logger
from api_client.url_helpers.product_url import get_product_deactivate_url
from models.api_header_model import RequestHeader

log = configure_logger('default')


def deactivate_product(product_id):
    """
    Deactivate product based on product id
    :param product_id: application id that is being used in products
    :return : True or False Indicates Success (Product Found) or Failure (Product Not Found)
    """
    api_url = get_product_deactivate_url(product_id)

    headers = RequestHeader().header

    try:
        response = requests.post(api_url, headers=headers)

        if not response.ok:
            response_data = json.loads(response.content)
            if response_data['message'] == 'Product is already Inactive.':
                log.error(response_data['message'])
                return True
            else:
                log.info(response.status_code, response.reason,
                         response.content)  # HTTP
                return False
        else:
            return True
    except Exception as e:
        log.error('Product Deactivation failed for product id {} with exception {}'.format(product_id, str(e)))
        return False
