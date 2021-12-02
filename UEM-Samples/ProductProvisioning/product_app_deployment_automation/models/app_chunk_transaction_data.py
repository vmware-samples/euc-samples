"""
AppChunkTransactionData consists of
1. transaction_id (int) : Transaction ID returned after uploading the app in chunks
2. blob_id (int) : Set to 0 as we upload app as chunks
3. application_name (str) : Name of the application
4. device_type (str) : Device type supported by the application
5. supported_models (dictionary of device models) : Dictionary of device models supported by the application
6. push_mode (str) : Push mode (Auto/Ondemand)
7. description (str) : Description about the app
8. file_name (str) : File name of the application
9. enable_provisioning (bool) : Set to false by default. True - Product deployment, False - App Deployment
10. upload_via_link (bool) : If a link is provided to download the app from, then this is set to True
11. location_group_id (int) : Organization group id
12. carry_over_assignments (bool) : If set to true, assignments of previous version of the app will be copied over
13. app_version (str) : Custom App version
"""

from configuration import config


class AppChunkTransactionData:
    def __init__(self, application_name, build_info, file_name, push_mode, device_type, supported_models, blob_id):
        """
        Constructs app chunk transaction data model
        :param application_name: Application Name
        :param build_info: Build Details: Build Project Name and Build Number
        :param file_name: File Name of the application
        :param push_mode: Push Mode indicates the app delivery method(Auto/On demand)
        :param device_type: Device Type
        :param supported_models: List of supported device models
        :param blob_id: Blob ID
        """

        self.transaction_id: int = 0
        self.blob_id: int = blob_id
        self.application_name: str = application_name
        self.device_type: str = device_type
        self.supported_models: dict = supported_models
        self.push_mode: str = push_mode
        self.description: str = 'Build details: 1. Build Project Name: {name}, \n2. Build number: {number} '\
                           .format(name=build_info[0], number=build_info[1])
        self.file_name: str = file_name
        self.enable_provisioning: bool = True
        self.upload_via_link: bool = False
        self.location_group_id: int = config.TENANT_GROUP_ID
        self.carry_over_assignments: bool = False
        self.app_version: str = None