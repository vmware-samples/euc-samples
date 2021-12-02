from configuration import config

BLOB_API_COMMON_PATH = '{host_url}/api/mam/blobs'.format(host_url=config.HOST_URL)


def get_blob_upload_url():
    """
    Returns blob upload api endpoint url
    :return: url
    """

    return '{blob_api_path}/uploadblob'.format(blob_api_path=BLOB_API_COMMON_PATH)

