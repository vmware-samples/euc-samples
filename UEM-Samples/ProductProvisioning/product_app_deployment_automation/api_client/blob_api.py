import os
import requests
import json

from api_client.constant_helpers.constants import MODULE_TYPE
from api_client.url_helpers.blob_upload_url import get_blob_upload_url
from configuration import config
from Logs.log_configuration import configure_logger
from models.api_header_model import RequestHeader

log = configure_logger('default')


def blob_upload(file_source_path, file_name):
    """
    Uploads the blob to Airwatch Server
    :param file_source_path : File to be uploaded
    :param file_name : Name of the file
    :return : True/False indicating Success/Failure and Transaction ID, if successful
    """

    file_size = os.path.getsize(file_source_path)

    api_url = get_blob_upload_url()

    api_url = "{api_url}?fileName={fileName}&organizationgroupid={ogid}&moduleType={moduleType}"\
        .format(api_url=api_url, fileName=file_name, ogid=config.TENANT_GROUP_ID, moduleType=MODULE_TYPE)

    headers = RequestHeader().header

    with open(file_source_path, 'rb') as file:
        start = 0
        file.seek(start)
        chunk_data = file.read(file_size)

        try:
            response = requests.post(api_url, headers=headers, data=chunk_data)

            if not response.ok:
                log.error(f'{response.status_code}, {response.reason}')
                log.debug(f'{response.content}')
                return False, 0

            else:
                response_data = json.loads(response.content)

                if response_data['Value'] > 0:
                    blob_id = response_data['Value']
                    return True, blob_id

                else:
                    return False, 0

        except Exception as e:
            log.error('Upload blob failed for file path {} with exception: {}'.format(file_source_path, str(e)))
