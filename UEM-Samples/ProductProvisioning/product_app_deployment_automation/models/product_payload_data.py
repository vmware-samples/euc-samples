"""
ProductPayloadData consists of
1. product_name (str) : Product Name
2. application_id (int) : Application ID
3. product_steps (array) : Product Steps : Step Type, Sequence Number, Application ID, Persist
4. smart_group_array (int) : Organization group id
5. deployment_type (str) : Assignment Groups
"""


class ProductPayloadData:
    def __init__(self, product_name, product_steps, deployment_type, app_id, smart_group_array):
        """
        Constructs product payload data model
        :param product_name: Product Name
        :param product_steps: Product Steps : Step Type, Sequence Number, Application ID, Persist
        :param deployment_type: Deployment Type
        :param app_id: Application ID
        :param smart_group_array: Assignment Groups
        """

        self.product_name: str = product_name
        self.product_steps: list = product_steps
        self.deployment_type: str = deployment_type
        self.app_id: int = app_id
        self.description: str = '{deployment_type} Group Product'.format(deployment_type=deployment_type)
        self.smart_group_array: dict = smart_group_array
