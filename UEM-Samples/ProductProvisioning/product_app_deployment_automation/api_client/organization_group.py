import json

import requests

from Logs.log_configuration import configure_logger
from api_client.url_helpers.organization_group_url import get_organization_group_children_url, \
    get_parent_organization_group_url, get_organization_group_details_url
from models.api_header_model import RequestHeader

log = configure_logger('default')


def get_child_organization_group_list(organization_group_id):
    """
    To get the list of child organization group for particular OG
    :param organization_group_id: organization group id
    :return: list of organization groups
    """

    api_url = get_organization_group_children_url(organization_group_id)

    headers = RequestHeader().header

    try:
        response = requests.get(api_url, headers=headers)
        if not response.ok:
            log.error(response.status_code, response.reason,
                      response.content)  # HTTP
            return response
        else:
            log.info(response.content)
            response_data = json.loads(response.content)
            return response_data
    except Exception as e:
        log.error('Child Organization Group Search failed for organization group id {} with exception {}'
                  .format(organization_group_id, str(e)))
        return e


def get_parent_organization_group_uuid_list(organization_group_uuid):
    """
    To get the list of parent organization group uuid for particular OG
    :param organization_group_uuid: organization group uuid
    :return: list of parent organization group uuid
    """

    api_url = get_parent_organization_group_url(organization_group_uuid)

    headers = RequestHeader().header

    try:
        response = requests.get(api_url, headers=headers)
        if not response.ok:
            log.error(response.status_code, response.reason,
                      response.content)  # HTTP
            return response
        else:
            log.info(response.content)
            response_data = json.loads(response.content)
            return response_data
    except Exception as e:
        log.error('Parent Organization Group Search failed for organization group uuid {} with exception {}: {}'
                  .format(organization_group_uuid, str(e)))
        return e


def get_parent_organization_group_details(organization_group_uuid):
    """
    To get the list of parent organization group uuid for particular OG
    :param organization_group_uuid: organization group uuid
    :return: list of parent organization group details
    """

    api_url = get_organization_group_details_url(organization_group_uuid)

    headers = RequestHeader().header

    try:
        response = requests.get(api_url, headers=headers)
        if not response.ok:
            log.error(response.status_code, response.reason,
                      response.content)  # HTTP
            return response
        else:
            log.info(response.content)
            response_data = json.loads(response.content)
            return response_data
    except Exception as e:
        log.error('Organization Group Details Search failed for organization group uuid {} with exception {}'
                  .format(organization_group_uuid, str(e)))
        return e
