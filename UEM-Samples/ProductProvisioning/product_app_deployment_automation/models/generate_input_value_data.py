"""
GenerateInputValueData consists of
1. location_group_id (int) : Organization group ID
2. insert_only (bool) : Insert Only
"""

from configuration import config


class GenerateInputValueData:
    def __init__(self):
        """
        Constructs general input value data model
        """
        self.location_group_id: int = config.TENANT_GROUP_ID
        self.insert_only: bool = False