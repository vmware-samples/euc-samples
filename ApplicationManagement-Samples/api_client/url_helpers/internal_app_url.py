from config import config

INTERNAL_API_COMMON_PATH = '{host_url}/api/mam/apps/internal'.format(host_url=config.HOST_URL)


def get_chunk_upload_url():
    """
    Returns chunk upload api endpoint url
    :return: url
    """

    return '{internal_api_path}/uploadchunk'.format(internal_api_path=INTERNAL_API_COMMON_PATH)


def get_create_internal_app_from_blob_url():
    """
    Returns create internal app api endpoint url
    :return: url
    """

    return '{internal_api_path}/begininstall'.format(internal_api_path=INTERNAL_API_COMMON_PATH)


def get_internal_app_assignment_url(application_id):
    """
    Returns internal app assignment api endpoint url
    :param application_id: Application ID
    :return: url
    """

    return '{internal_api_path}/{application_id}/assignments'.format(internal_api_path=INTERNAL_API_COMMON_PATH,
                                                                     application_id=application_id)


def get_retire_app_url(application_id):
    """
    Returns retire app api endpoint url
    :param application_id: Application ID
    :return: url
    """

    return '{internal_api_path}/{application_id}/retire'.format(internal_api_path=INTERNAL_API_COMMON_PATH,
                                                                application_id=application_id)


def get_edit_assignment_url(application_id):
    """
    Returns edit assignment api endpoint url
    :param application_id: Application ID
    :return: url
    """

    return '{internal_api_path}/{application_id}/assignments'.format(internal_api_path=INTERNAL_API_COMMON_PATH,
                                                                     application_id=application_id)


def get_internal_app(application_id):
    """
    Returns internal app details api endpoint url
    :param application_id: Application ID
    :return: url
    """

    return '{internal_api_path}/{application_id}'.format(internal_api_path=INTERNAL_API_COMMON_PATH,
                                                         application_id=application_id)
