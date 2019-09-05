"""
AppAssignment consists of
1. smart_group_ids - List of smart group ids
2. deployment_parameters - Dictionary of deployment parameters like Push mode, Remove on unenroll flag etc
"""


class AppAssignment:
    def __init__(self, assignment_groups, push_mode):
        """
        Constructs App assignment model
        :param assignment_groups: Assignment Group Ids
        :param push_mode: Push Mode that indicates the app delivery method(Auto/On demand)
        """

        self.smart_group_ids: list = assignment_groups
        self.deployment_parameters: dict = {
            'PushMode': push_mode,
            'RemoveOnUnEnroll': True
        }
