DEVICE_TYPE = 'Android'
DEVICE_MODEL = 'Android'

MODULE_TYPE = 'ProductProvisioning'


def get_device_type_and_models():
    """
    Returns the device type and supported device models for the application
    :return: Device Type and List of supported models
    """

    device_models = [{'ModelName': DEVICE_MODEL}]
    supported_device_models = {'Model': device_models}
    return DEVICE_TYPE, supported_device_models
