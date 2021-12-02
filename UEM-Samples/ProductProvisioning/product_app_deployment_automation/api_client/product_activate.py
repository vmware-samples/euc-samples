import requests

from Logs.log_configuration import configure_logger
from api_client.url_helpers.product_url import get_product_activate_url
from models.api_header_model import RequestHeader

log = configure_logger('default')


def activate_product(product_id):
    """
    Activates the product with the specified product_id
    :param product_id: Product Id of the product to be activated
    :returns bool: indicating Success or Failure
    """
    api_url = get_product_activate_url(product_id)

    headers = RequestHeader().header

    try:
        response = requests.post(api_url, headers=headers)
        if not response.ok:
            log.error(response.status_code, response.reason,
                  response.content)  # HTTP
            return False
        else:
            return True
    except Exception as e:
        log.error('Product Activation failed for product id {} with exception {}'.format(product_id, str(e)))
        return False

