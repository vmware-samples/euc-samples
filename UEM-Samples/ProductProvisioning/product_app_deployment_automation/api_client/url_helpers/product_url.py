from configuration import config

PRODUCTS_API_COMMON_PATH = '{host_url}/API/v1/mdm/products'.format(host_url=config.HOST_URL)


def get_product_activate_url(product_id):
    """
    Returns activate product api endpoint url
    :param product_id: ID of the product that has to be activated
    :return: url
    """
    return '{products_api_path}/{product_id}/activate'.format(products_api_path=PRODUCTS_API_COMMON_PATH,
                                                              product_id=product_id)


def get_create_product_url():
    """
    Returns create product api endpoint url
    :return: url
    """
    return '{products_api_path}/maintainProduct'.format(products_api_path=PRODUCTS_API_COMMON_PATH)


def get_product_application_url(application_id):
    """
    Returns api endpoint url that can get the product associated with the given application
    :param application_id: Application ID
    :return: url
    """
    return '{products_api_path}/{application_id}/assignments'.format(products_api_path=PRODUCTS_API_COMMON_PATH,
                                                                     application_id=application_id)


def get_product_deactivate_url(product_id):
    """
    Returns deactivate product api endpoint url
    :param product_id: ID of the product that has to be deactivated
    :return: url
    """
    return '{products_api_path}/{product_id}/deactivate'.format(products_api_path=PRODUCTS_API_COMMON_PATH,
                                                                product_id=product_id)


def get_product_extensive_search_url():
    """
    Returns extensive search product api endpoint url
    :return: url
    """
    return '{products_api_path}/extensivesearch'.format(products_api_path=PRODUCTS_API_COMMON_PATH)


def get_product_search_url(product_id):
    """
    Returns search product api endpoint url
    :param product_id: Product ID
    :return: url
    """
    return '{products_api_path}/{product_id}'.format(products_api_path=PRODUCTS_API_COMMON_PATH,product_id=product_id)
