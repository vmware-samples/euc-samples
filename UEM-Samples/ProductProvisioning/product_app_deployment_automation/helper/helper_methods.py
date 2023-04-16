import os
import json

from Logs.log_configuration import configure_logger

log = configure_logger('default')

JSON_FILE_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'productdetails.json')


def write_product_id(build_info, app_name, app_id, product_id, product_name, app_version, deployment_type,
                     organization_group, bundle_id):
    """
    Writes the app and product information to a Json file
    :param build_info : Build Information(Build Project Name and Build Number)
    :param app_name : Application Name
    :param app_id : Application ID
    :param product_id : Product ID (This is 0 for App deployment)
    :param product_name : Product name
    :param app_version : App Version
    :param deployment_type : Type of deployment(Alpha/Beta/Prod)
    :param organization_group : Organization Group ID
    :param bundle_id : Bundle ID of application
    :return : void
    """
    data = {}
    product_list = []

    if os.path.isfile(JSON_FILE_PATH):
        with open(JSON_FILE_PATH, "r") as jsonFile:
            data = json.load(jsonFile)

    product_details = {
        'app_id': app_id,
        'app_name': app_name,
        'product_id': product_id,
        'product_name': product_name,
        'app_version': app_version,
        'current_deployment': deployment_type,
        'organization_group': organization_group,
        'bundle_id': bundle_id
    }

    try:
        product_list = data[build_info[0]][build_info[1]]

        for product in data[build_info[0]][build_info[1]]:
            if product['product_id'] == product_id:
                product_list.remove(product)
                break

    except KeyError:
        log.info("Build information not present. Creating a new entry.")

    product_list.append(product_details)
    index = {build_info[1]: product_list}
    data[build_info[0]] = index

    with open(JSON_FILE_PATH, "w") as outfile:
        json.dump(data, outfile)


def get_product_data_from_json(build_info, organization_group_id, parameter):
    """
    Gets the product information from Json file
    :param build_info : Build Information(Build Project Name and Build Number)
    :param organization_group_id : Application Name
    :param parameter : Parameter to be searched
    :return : Value of the parameter
    """

    if os.path.isfile(JSON_FILE_PATH):
        with open(JSON_FILE_PATH, "r") as jsonFile:
            data = json.load(jsonFile)
        try:
            for product in data[build_info[0]][build_info[1]]:
                if product['organization_group'] == organization_group_id:
                    return product[parameter]
            return 0
        except KeyError:
            return 0
    else:
        return 0


def update_current_deployment_status(deployment_type, product_id, build_info=None):
    """
    Updates deployment status of the product in Json file
    :param build_info : Build Information(Build Project Name and Build Number)
    :param deployment_type : Deployment Type
    :param product_id : Product ID
    :return void:
    """

    if build_info is None:
        with open(JSON_FILE_PATH, "r") as jsonFile:
            data = json.load(jsonFile)
        for key in data:
            for product in data[key]:
                if product['product_id'] == product_id:
                    product['current_deployment'] = deployment_type
    else:
        with open(JSON_FILE_PATH, "r") as jsonFile:
            data = json.load(jsonFile)
            for product in data[build_info[0]][build_info[1]]:
                if product['product_id'] == product_id:
                    product['current_deployment'] = deployment_type

    with open(JSON_FILE_PATH, "w") as outfile:
        json.dump(data, outfile)


def get_all_prod_products():
    """
    Gets all prod products from Json file
    :return list: List of Prod products
    """

    prod_products = []
    with open(JSON_FILE_PATH, "r") as jsonFile:
        data = json.load(jsonFile)
    for key in data:
        for value in data[key]:
            for product in data[key][value]:
                if product['current_deployment'] == 'Prod':
                    prod_products.append(product['product_id'])

    return prod_products


def search_product_from_json(product_name, organization_group, deployment_type):
    """
   Searches the product information in a Json file with name, organization group and deployment type
   :param product_name: Product name
   :param deployment_type: Type of deployment(Alpha/Beta/Prod)
   :param organization_group: Organization Group
   :return: True or False based on product search
   """

    if os.path.isfile(JSON_FILE_PATH):
        with open(JSON_FILE_PATH, "r") as jsonFile:
            data = json.load(jsonFile)

        for key in data:
            for value in data[key]:
                for product in data[key][value]:
                    if product['product_name'] == product_name and product['organization_group'] == organization_group \
                            and product['current_deployment'] == deployment_type:
                        return True

        return False

    else:
        return False


def get_product_associated_with_application(bundle_id):
    """
    :param bundle_id: Bundle ID of Application
    :returns product_id: Product ID
    """

    products = []
    if os.path.isfile(JSON_FILE_PATH):
        with open(JSON_FILE_PATH) as f:
            result_product_deployment = json.load(f)
            for key in result_product_deployment:
                for value in result_product_deployment[key]:
                    for product in result_product_deployment[key][value]:
                        if product['bundle_id'] == bundle_id:
                            products.append(product)
    return products
