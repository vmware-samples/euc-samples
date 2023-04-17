import os
import json

JSON_FILE_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'appdetails.json')


def write_app_id(build_info, app_id, product_id, app_version, deployment_type):
    """
    Writes the app and product information to a Json file
    :param build_info: Build Information(Build Project Name and Build Number)
    :param app_id: Application ID
    :param product_id: Product ID (This is 0 for App deployment)
    :param app_version: App Version
    :param deployment_type: Type of deployment(Alpha/Beta/Prod)
    :return: void
    """

    data = {}

    if os.path.isfile(JSON_FILE_PATH):
        with open(JSON_FILE_PATH, "r") as jsonFile:
            data = json.load(jsonFile)

    product_details = {
        'app_id': app_id,
        'product_id': product_id,
        'app_version': app_version,
        'current_deployment': deployment_type
    }

    index = {build_info[1]: product_details}
    data[build_info[0]] = index

    with open(JSON_FILE_PATH, "w") as outfile:
        json.dump(data, outfile)


def get_app_details_from_json(build_info):
    """
    Get the application details from the json file given the Build information
    :param build_info: Build Project Name and Build Number details
    :return: Returns the Deployment type for the app
    """

    with open(JSON_FILE_PATH, "r") as jsonFile:
        data = json.load(jsonFile)
        return data[build_info[0]][build_info[1]]['current_deployment']


def update_app_assignment_details_in_json(build_info, deployment_type):
    """
    Updates the json file for the app with new assignment details
    :param build_info: Build Project Name and Build Number
    :param deployment_type: New deployment type for the application
    """

    with open(JSON_FILE_PATH, "r") as jsonFile:
        data = json.load(jsonFile)
        data[build_info[0]][build_info[1]]["current_deployment"] = deployment_type

    with open(JSON_FILE_PATH, "w") as outfile:
        json.dump(data, outfile)
