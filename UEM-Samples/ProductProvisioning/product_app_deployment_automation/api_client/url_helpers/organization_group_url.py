from configuration import config

ORGANIZATION_GROUP_API_COMMON_PATH = '{host_url}/api/system/groups'.format(host_url=config.HOST_URL)


def get_organization_group_children_url(og_id):
    """
    Returns get child organization group api endpoint
    :param og_id: organization group id
    :return: url
    """

    return '{organization_group_api_path}/{organization_group_id}/children'. \
        format(organization_group_api_path=ORGANIZATION_GROUP_API_COMMON_PATH, organization_group_id=og_id)


def get_parent_organization_group_url(organization_group_uuid):
    """
    Returns get parent organization groups api endpoint
    :param organization_group_uuid : organization group uuid
    :return: url
    """

    return '{organization_group_api_path}/{organization_group_uuid}/parents'.format \
        (organization_group_api_path=ORGANIZATION_GROUP_API_COMMON_PATH,
         organization_group_uuid=organization_group_uuid)


def get_organization_group_details_url(organization_group_uuid):
    """
    Returns get organization group details api endpoint
    :param organization_group_uuid : organization group uuid
    :return: url
    """

    return '{organization_group_api_path}/{organization_group_uuid}/tree'.format \
        (organization_group_api_path=ORGANIZATION_GROUP_API_COMMON_PATH,
         organization_group_uuid=organization_group_uuid)
