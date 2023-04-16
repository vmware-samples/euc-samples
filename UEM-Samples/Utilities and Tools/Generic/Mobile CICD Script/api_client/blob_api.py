import base64
import os
import math
import time
import requests
import json

from config import config
from api_client.url_helpers.internal_app_url import get_chunk_upload_url
from Logs.log_configuration import configure_logger
from models.api_header_model import RequestHeader

log = configure_logger('default')


def chunk_upload(file_source_path):
    """
    Uploads the file in chunks to Airwatch Server
    :param file_source_path: File to be uploaded
    :return: True/False indicating Success/Failure and Transaction ID, if successful
    """

    file_size = os.path.getsize(file_source_path)

    api_url = get_chunk_upload_url()

    headers = RequestHeader().header

    with open(file_source_path, 'rb') as file:
        start = 0
        chunk_count = math.ceil(file_size / config.MAX_UPLOAD_BYTE_LENGTH)
        retry_timeout = 0.300  # milliseconds
        sent_chunk_count = 0
        transaction_id = ''

        log.debug('File {} Total chunk count:{count} with transaction {id}'.format(file_source_path,
                                                                                   count=chunk_count,
                                                                                   id=transaction_id))

        while True:
            current_chunk_count = sent_chunk_count + 1
            log.debug('Uploading chunk number: {}'.format(current_chunk_count))
            end = min(file_size, start + config.MAX_UPLOAD_BYTE_LENGTH)
            file.seek(start)
            chunk_data = file.read(end)
            base64_file = str(base64.b64encode(chunk_data))[2:-1]
            internal_app_chunk_value = {
                'TransactionId': str(transaction_id),
                'ChunkData': base64_file,
                'ChunkSize': end - start,
                'ChunkSequenceNumber': current_chunk_count,
                'TotalApplicationSize': file_size
            }

            payload = json.dumps(internal_app_chunk_value)
            start = start + end

            try:
                response = requests.post(api_url, headers=headers, data=payload)

                if not response.ok:
                    log.error(f'{response.status_code}, {response.reason}')
                    log.debug(f'{response.content}')
                    return False, 0

                else:
                    response_data = json.loads(response.content)

                    if response_data['UploadSuccess']:
                        log.debug('{}. chunk sent to server'.format(
                            current_chunk_count))
                        sent_chunk_count = current_chunk_count
                        transaction_id = response_data['TranscationId']

                    else:
                        return False, 0

            except Exception as e:
                log.error('Upload chunk failed with exception: {}'.format(str(e)))

            # Sleep
            time.sleep(retry_timeout)

            if sent_chunk_count >= chunk_count:
                return True, transaction_id
