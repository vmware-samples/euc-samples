import requests
import json

from Logs.log_configuration import configure_logger
from api_client.url_helpers.product_url import get_product_search_url, \
    get_product_extensive_search_url
from models.api_header_model import RequestHeader

log = configure_logger('default')


def search_product_with_id(product_id):
    """
    Searches for Product based on product id
    :param product_id: Product ID
    :returns : True or False indicating Success or Failure and  product associated with id
    """

    api_url = get_product_search_url(product_id)

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
            return True, response_data
    except Exception as e:
        log.error('Product Search failed for product id {} with exception {}'.format(product_id, str(e)))
        return False, e


def search_product(params):
    """
    Searches for Products based on the filter criteria
    :param params: Search Parameters
    :returns: True or False indicating Success or Failure and list of products
    """

    api_url = get_product_extensive_search_url()

    headers = RequestHeader().header

    api_params = params

    try:
        response = requests.get(api_url, headers=headers, params=api_params)
        if not response.ok:
            log.error(response.status_code, response.reason,
                      response.content)  # HTTP
            return False, response
        else:
            log.info(response.content)
            response_data = json.loads(response.content)
            return True, response_data
    except Exception as e:
        log.error('Product Search failed for params {} with exception {}'.format(params, str(e)))
        return False, e


def get_product_id(product_name, organization_group_id):
    """
    Gets product ID
    :param product_name: Product name
    :param organization_group_id: organization group id
    :returns: True or False indicating Success or Failure and list of products
    """
    api_params = {'name': product_name, 'managedbyorganizationgroupid': organization_group_id}
    _, products = search_product(api_params)
    return products['Product'][0]['ID']['Value']
