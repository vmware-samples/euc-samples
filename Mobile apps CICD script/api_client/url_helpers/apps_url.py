from config import config

APPS_API_COMMON_PATH = '{host_url}/api/mam/apps'.format(host_url=config.HOST_URL)


def get_apps_search_url():
    """
    Returns the url of Apps search api endpoint
    :return: url
    """

    return '{apps_api_common_path}/search'.format(apps_api_common_path=APPS_API_COMMON_PATH)
