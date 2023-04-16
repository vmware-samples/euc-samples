import json
import os

import requests

from api_client.url_helpers.product_url import get_create_product_url
from models.api_header_model import RequestHeader
from models.generate_input_value_data import GenerateInputValueData
from models.product_payload_data import ProductPayloadData
from Logs.log_configuration import configure_logger
from models.product_step_data import ProductStepData

log = configure_logger('default')

PLATFORM = 5
PRODUCT_TYPE = 0


def associate_app_to_product(product_name, app_id, assignment_groups, deployment_type, optional_id=0):
    """
    Creates a new product for specified application component and assignment groups
    :param product_name: product name
    :param app_id: application id to be associated with new product
    :param assignment_groups: Assignment groups
    :param deployment_type: Deployment Type(Alpha, Beta, Prod)
    :param optional_id: optional id
    :return: True/False to indicate Success/Failure and Product ID
    """
    api_url = get_create_product_url()

    headers = RequestHeader().header

    generate_input_value = GenerateInputValueData()
    maintain_general_input = {
        'LocationGroupId': generate_input_value.location_group_id,
        'InsertOnly': generate_input_value.insert_only
    }
    product_steps = []
    product_step = ProductStepData(3, 0, app_id, False)
    product_step1 = {
        'StepType': product_step.step_type,
        'SequenceNumber': product_step.sequence_number,
        'ApplicationID': product_step.application_id,
        'Persist': product_step.persist
    }
    product_steps.append(product_step1)

    smart_group_array = []
    for assignment in assignment_groups:
        smart_group_array.append({'SmartGroupID': assignment})

    product_payload_data = ProductPayloadData(product_name, product_steps, deployment_type, app_id, smart_group_array)

    if optional_id == 0:
        product = {
            'Name': product_payload_data.product_name,
            'Description': product_payload_data.description,
            'PauseResume': False,
            'Platform': PLATFORM,
            'ProductType': PRODUCT_TYPE,
            'Steps': product_payload_data.product_steps,
            'SmartGroups': product_payload_data.smart_group_array
        }

    else:
        product = {
            'ProductID': optional_id,
            'Name': product_payload_data.product_name,
            'Description': product_payload_data.description,
            'PauseResume': False,
            'Platform': PLATFORM,
            'ProductType': PRODUCT_TYPE,
            'Steps': product_payload_data.product_steps,
            'SmartGroups': product_payload_data.smart_group_array
        }

    api_body = {
        'MaintainGeneralInput': maintain_general_input,
        'Product': product
    }

    try:
        payload = json.dumps(api_body)
        response = requests.post(api_url, headers=headers, data=payload)

        if not response.ok:
            log.error(f'{response.status_code}, {response.reason}, {response.content}')  # HTTP
            return False

        else:
            response_data = json.loads(response.content)
            log.info('Product associated with Application : {}'.format(str(response_data)))
            return True

    except Exception as e:
        log.error('Product creation failed: {}'.format(str(e)))
        return False
