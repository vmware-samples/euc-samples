"""
RequestHeader consists of api header which is a dictionary containing
aw-tenant-code - API Key
Content-Type
Accept Header and
Authorization type
"""

from base64 import b64encode
from six.moves.urllib.parse import quote

from configuration import config


class RequestHeader:
    def __init__(self, content_type='application/json', accept_header='application/json'):
        """
        Constructs request header
        :param content_type: Content Type
        :param accept_header: Accept Header
        """

        self.header: dict = {'aw-tenant-code': config.AW_TENANT_CODE,
                             'Content-Type': content_type,
                             'Accept': accept_header,
                             'Authorization': 'Basic '
                                              + b64encode('{username}:{password}'
                                                          .format(username=quote(config.API_USERNAME),
                                                                  password=quote(config.API_PASSWORD))
                                                          .encode()).decode()
                             }
