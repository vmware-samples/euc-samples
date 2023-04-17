import os
import sys

from api_client.application_api import create_app
from api_client.blob_api import blob_upload
from api_client.constant_helpers.constants import get_device_type_and_models
from api_client.organization_group import get_child_organization_group_list, \
    get_parent_organization_group_uuid_list, get_parent_organization_group_details
from api_client.product_activate import activate_product
from api_client.product_api import associate_app_to_product
from api_client.product_application_search import search_product_with_application_id
from api_client.product_deactivate import deactivate_product
from api_client.product_search import search_product_with_id, get_product_id
from configuration import config
from Logs.log_configuration import configure_logger
from helper.helper_methods import search_product_from_json, get_product_associated_with_application, \
    write_product_id, get_product_data_from_json, update_current_deployment_status, get_all_prod_products
from models.app_chunk_transaction_data import AppChunkTransactionData

log = configure_logger('default')


def add_new_product(sys_param, app_version, product_name):
    """
    Adds new product and assigns it to a particular smart group
    :param sys_param: Command line arguments
    :param app_version: Application version
    :param product_name: Product Name
    :returns void
    """

    log.info('Product Deployment started...')

    source_file_path = sys_param[0]
    build_info = get_build_information(sys_param[1])
    deployment_type = str.lower((sys_param[2]))
    deactivate_old_product = bool(sys_param[3])

    # Default value for push mode
    push_mode = 'Auto'

    file_name = os.path.basename(source_file_path)
    file_extension = str.split(file_name, '.')[-1:][0].lower()
    if file_extension != 'apk':
        log.error('Invalid File Type. Allowed File Type is .apk')
        sys.exit(1)

    if deployment_type == 'alpha':
        product_deploy_success, product_id = create_product(source_file_path, file_name,
                                                            build_info, config.ALPHA_GROUPS,
                                                            deactivate_old_product,
                                                            push_mode, app_version, deployment_type,
                                                            product_name)

    elif deployment_type == 'beta':
        product_deploy_success, product_id = update_product_to_beta(source_file_path, file_name,
                                                                    build_info,
                                                                    config.BETA_GROUPS,
                                                                    deactivate_old_product,
                                                                    push_mode, app_version,
                                                                    deployment_type,
                                                                    product_name)

    elif deployment_type == 'prod':
        product_deploy_success, product_id = update_product_to_prod(build_info,
                                                                    config.PRODUCTION_GROUPS,
                                                                    deployment_type,
                                                                    deactivate_old_product,
                                                                    product_name)

    if product_deploy_success:
        activation_success = activate_product(product_id)
    else:
        log.error('** Product Creation FAILED **')
        sys.exit(1)

    if activation_success:
        log.info("Product activated successfully")
        return 0
    else:
        log.error('Error:** Activation FAILED **')
        sys.exit(1)


def get_build_information(build_info_arg):
    """
    Parses the command line argument to fetch Build information
    :param build_info_arg: Command line argument to fetch build information
    :return: Build information - Build Project Name and Build Number
    """

    build_info = []
    if config.BUILD_SERVER_URL:
        build_info.append(config.BUILD_PROJECT_NAME)

        # Runs the jenkins script to get the build number from the integrated jenkins build server
        build_info.append(str(os.system(build_info_arg)))
    else:
        build_info = str.split(build_info_arg, ',')

    return build_info


def create_product(source_file_path, file_name, build_info, assignment_groups, deactivate_old_product, push_mode,
                   application_version, deployment_type, product_name_by_user):
    """
    Creates a new product for the specified file and assignment groups
    :param source_file_path : Full path for the file.
    :param file_name : Name of the product.
    :param build_info : Build Project Name and Build Number
    :param assignment_groups : AirWatch Assignment groups that contains users or devices to which product needs to be
    deployed.
    :param deactivate_old_product : Deactivate old product
    :param push_mode : Push Mode
    :param application_version : Application Version
    :param deployment_type : Deployment Type
    :param product_name_by_user : Product Name given by user
    :return: True/False indicating Success/Failure and ProductID
    """

    if deployment_type.lower() == 'alpha':
        app_id = get_product_data_from_json(build_info, config.TENANT_GROUP_ID, 'app_id')

        if app_id != 0:
            return update_alpha_product_assignment(app_id, build_info, assignment_groups, deployment_type,
                                                   product_name_by_user)

    product_exists = search_product_from_json(product_name_by_user, config.TENANT_GROUP_ID, deployment_type)
    if product_exists:
        log.error('Product name invalid. Product already exists with name {product_name} in organization group '
                  '{organization_group}'.format(product_name=product_name_by_user,
                                                organization_group=config.TENANT_GROUP_ID))
        sys.exit(1)

    # BaseName gives FileName with extension. SplitText [0] filters for file name
    file_name_without_extension = os.path.splitext(os.path.basename(source_file_path))[0]

    blob_upload_success, blob_id = blob_upload(source_file_path, file_name)

    if blob_upload_success:
        log.info('Application {application_name} uploaded successfully with blob ID {id}'
                 .format(application_name=file_name_without_extension,
                         id=blob_id))

        device_type, supported_device_models = get_device_type_and_models()

        app_chunk_transaction = AppChunkTransactionData(file_name_without_extension,
                                                        build_info,
                                                        file_name,
                                                        push_mode,
                                                        device_type,
                                                        supported_device_models,
                                                        blob_id)
        if application_version > '0':
            app_chunk_transaction.app_version = application_version

        app_create_success, application_id, application_version, application_name, bundle_id = \
            create_app(app_chunk_transaction)

        if app_create_success and application_id != 0:
            log.info('App {app_name} created successfully'.format(app_name=application_name))

            if deactivate_old_product:
                product_list = get_product_associated_with_application(bundle_id)

                if len(product_list) > 0:
                    child_organization_group_list = get_child_organization_group_list(int(config.TENANT_GROUP_ID))
                    organization_group_uuid = child_organization_group_list[0]['Uuid']

                    # get_parent_organization_group_uuid_list returns list of uuid of parent OGs
                    parent_organization_group_uuid_list = get_parent_organization_group_uuid_list(
                        organization_group_uuid)

                    # To get details of parent OGs
                    parent_organization_group_list = []
                    for parent_organization_group_uuid in parent_organization_group_uuid_list['items'][1:]:
                        parent_organization_group_details = get_parent_organization_group_details \
                            (parent_organization_group_uuid)
                        parent_organization_group_list.append(parent_organization_group_details)

                    for product in product_list:
                        status, result_product_details = search_product_with_id(product['product_id'])
                        for child_organization_group in child_organization_group_list:
                            if int(result_product_details['ManagedByOrganizationGroupID']) == \
                                    child_organization_group['Id']['Value']:
                                if result_product_details['Active']:
                                    deactivation_success = deactivate_product(product['product_id'])
                                    if not deactivation_success:
                                        return False, 0
                        for parent_organization_group in parent_organization_group_list:
                            if int(result_product_details['ManagedByOrganizationGroupID']) == \
                                    parent_organization_group['id']:
                                if result_product_details['Active']:
                                    deactivation_success = deactivate_product(product['product_id'])
                                    if not deactivation_success:
                                        return False, 0

            else:
                log.info("Deactivate old products associated with previous version of application in child organization"
                         " groups")

            # Associate App Component to product.
            if product_name_by_user == '':
                product_name = 'Apps_' + file_name_without_extension + '_v' + application_version
            else:
                product_name = product_name_by_user

            product_upload_success = associate_app_to_product(product_name, application_id, assignment_groups,
                                                              deployment_type)

            if product_upload_success:
                product_id = get_product_id(product_name, int(config.TENANT_GROUP_ID))
                write_product_id(build_info, file_name_without_extension, application_id, product_id, product_name,
                                 application_version, deployment_type, config.TENANT_GROUP_ID, bundle_id)
                print('Product created with product ID : {}'.format(product_id))
                log.info('Product {product_name} created successfully for {deployment_type} group'
                         .format(product_name=product_name, deployment_type=deployment_type))
                return True, product_id

            else:
                return False, 0

        else:
            log.error('Application deployment failed')
            sys.exit(1)

    else:
        log.error('{} blob upload failed'.format(file_name_without_extension))
        return False, 0


def update_alpha_product_assignment(app_id, build_info, assignment_groups, deployment_type, product_name_by_user):
    """
    Updates existing product for the specified assignment groups
    :param product_name_by_user: Product Name given
    :param app_id : Application ID
    :param build_info : Build Project Name and Build Number
    :param assignment_groups : AirWatch Assignment groups that contains users or devices to which product needs to be
    deployed.
    :param deployment_type: Deployment Type
    :return: True/False indicating Success/Failure and ProductID
    """

    # Search Relevant App from the product json file
    product_name = get_product_data_from_json(build_info, config.TENANT_GROUP_ID, 'product_name')
    if product_name_by_user != '':
        if product_name != product_name_by_user:
            log.error("Invalid product name {product_name}. Provide correct product name for updating assignment of "
                      "alpha product".format(product_name=product_name_by_user))
            return False, 0

    # Get Product Id from app assignment api
    product_search_status, product_id = search_product_with_application_id(app_id)

    # Currently the MaintainProduct API is just using the name of the product to update the product -
    # API issue open to also validate product id
    if product_search_status:

        product_upload_success = associate_app_to_product(product_name, app_id, assignment_groups, 'alpha',
                                                          optional_id=product_id)
        if product_upload_success:
            log.info('Product {product_name} updated successfully to {deployment_type} group'
                     .format(product_name=product_name, deployment_type=deployment_type))

        else:
            log.error('Product {product_name} upload failed'.format(product_name=product_name))
            return False, 0

    else:
        log.error("Product search failed for assignment updating of Alpha Product")
        return False, 0

    return product_upload_success, product_id


def update_product_to_beta(source_file_path, file_name, build_info, assignment_groups, deactivate_old_product,
                           push_mode,
                           application_version, deployment_type, product_name_by_user):
    """
    Creates a new product or updates existing product for the specified file and assignment groups
    :param source_file_path : Full path for the file.
    :param file_name : Name of the application.
    :param build_info : Build Project Name and Build Number
    :param assignment_groups : AirWatch Assignment groups that contains users or devices to which product needs to be
    deployed.
    :param product_name_by_user : Product Name given
    :param push_mode : Push Mode
    :param application_version : Application Version
    :param deployment_type: Deployment Type
    :param deactivate_old_product : Deactivate old product
    :return: True/False indicating Success/Failure and ProductID
    """

    # Search Relevant App from the product json file
    app_id = get_product_data_from_json(build_info, config.TENANT_GROUP_ID, 'app_id')
    if app_id == 0:
        return create_product(source_file_path, file_name, build_info, assignment_groups, deactivate_old_product,
                              push_mode,
                              application_version, deployment_type, product_name_by_user)

    product_name = get_product_data_from_json(build_info, config.TENANT_GROUP_ID, 'product_name')
    if product_name_by_user != '':
        if product_name != product_name_by_user:
            log.error("Invalid product name {product_name}. Provide correct product name for updating product to beta "
                      "deployment".format(product_name=product_name_by_user))
            return False, 0

    # Get Product Id from app assignment api
    product_search_status, product_id = search_product_with_application_id(app_id)

    # Currently the MaintainProduct API is just using the name of the product to update the product -
    # API issue open to also validate product id
    if product_search_status:

        product_upload_success = associate_app_to_product(product_name, app_id, assignment_groups, 'beta',
                                                          optional_id=product_id)
        if product_upload_success:
            update_current_deployment_status('beta', build_info=build_info, product_id=product_id)
            log.info('Product {product_name} updated successfully to {deployment_type} group'
                     .format(product_name=product_name, deployment_type=deployment_type))

        else:
            log.error('Product {product_name} upload failed'.format(product_name=product_name))
            return False, 0

    else:
        log.error("Product search failed for Beta deployment")
        return False, 0

    return product_upload_success, product_id


def update_product_to_prod(build_info, assignment_groups, deployment_type, deactivate_old_product,
                           product_name_by_user):
    """
    updates a product for the specified file and assignment groups
    :param build_info : Build Project Name and Build Number
    :param product_name_by_user : Product Name Given
    :param assignment_groups : AirWatch Assignment groups that contains users or devices to which
                               product needs to be deployed.
    :param deployment_type: Deployment Type
    :param deactivate_old_product : Deactivate old product
    :return: True/False indicating Success/Failure and ProductID
    """

    # Search Relevant App from the application json file
    app_id = get_product_data_from_json(build_info, config.TENANT_GROUP_ID, 'app_id')
    if app_id == 0:
        log.error("No direct creation of product allowed for prod deployment")
        sys.exit(1)

    product_name = get_product_data_from_json(build_info, config.TENANT_GROUP_ID, 'product_name')
    if product_name_by_user != '':
        if product_name != product_name_by_user:
            log.error("Invalid product name {product_name}. Provide correct product name for updating product to prod "
                      "deployment".format(product_name=product_name_by_user))
            return False, 0

    # Get Product Id from app assignment api
    # Currently only one product has that app assigned, if multiple products have the same app use product name
    # to filter
    product_search_status, product_id = search_product_with_application_id(app_id)

    if product_search_status:
        if deactivate_old_product:
            prod_product_ids = get_all_prod_products()
            for current_product_id in prod_product_ids:
                deactivation_success = deactivate_product(current_product_id)
                if deactivation_success:
                    update_current_deployment_status('NA', product_id=current_product_id)
                else:
                    print("Error: Deactivation of a prod product failed "
                          "- new product would not be promoted to prod")
                    sys.exit(1)
        else:
            print("Deactivate prod products and update the status in product details JSON file")

        product_upload_success = associate_app_to_product(product_name, app_id, assignment_groups, 'prod',
                                                          optional_id=product_id)
        if product_upload_success:
            update_current_deployment_status('prod', build_info=build_info, product_id=product_id)
            log.info('Product {product_name} updated successfully to {deployment_type} group'
                     .format(product_name=product_name, deployment_type=deployment_type))

        else:
            log.error('Product {product_name} upgrade to deployment type prod failed'.format(product_name=product_name))
            return False, 0

    else:
        log.error("Product search failed for Prod deployment")
        return False, 0

    return product_upload_success, product_id
