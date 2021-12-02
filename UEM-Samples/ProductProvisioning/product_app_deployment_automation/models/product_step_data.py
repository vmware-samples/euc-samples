"""
ProductStepData consists of
1. step_type (int) : Step type
2. sequence_number (int) : Sequence Number
3. application_id (int) : Application ID
4. persist (bool) : Persist
"""


class ProductStepData:
    def __init__(self, step_type, sequence_number, app_id, persist):
        """
        Constructs product step data model
        :param step_type : Step type
        :param sequence_number : Sequence number
        :param app_id : Application ID
        :param persist : Persist
        """
        self.step_type: int = step_type
        self.sequence_number: int = sequence_number
        self.application_id: int = app_id
        self.persist: bool = persist
