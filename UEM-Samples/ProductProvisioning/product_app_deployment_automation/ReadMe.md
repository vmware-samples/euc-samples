# **Workspace ONE ProductManagement-Samples**

## **Overview**
* **Author(s)** : Krati Gupta, Madhushree Nayak M
* **Email** : krgupta@vmware.com, mnayakm@vmware.com
* **Date Created** : 06 March 2020

## **Purpose**
The tool provides an example of how the product deployment APIs of Workspace ONE UEM can be used for Android app deployment. This script can be used to automate product delivery to your end-user devices in the following cases:
1. Create product with app manifest and appropriate smartgroup assignments
2. Update assignment for existing product

## **Requirements**
To execute the script, dependencies have to be installed.
This tool uses Python's PIP installation system.
Dependencies can be installed by executing the following command:
` pip install -r requirements.txt `

## **How to execute the script**
config.py file has to be updated with appropriate values before executing the script. This file has settings like the environment URL, WS1 tenant, smart group, etc.

### **Command to execute the script**
#### 1. Adding a new product
` python deployment.py <options> <File Path> <Build Information> <Deployment Type> <Deactivate Old Product>`

Product Deployment workflow needs the following required parameters:
1. File Path - Absolute file path of the application.
2. Build Information - Comma separated Build Project Name and Build Number. (Ex: "My App Build Project,1")
3. Deployment Type - Supported values are Alpha, Beta, or Prod. These are the assignment groups. One value can be given at a time. (Ex: "Alpha")
4. Deactivate Old Product - Supported values are True or False. 
                            In case of product creation it indicates whether to deactivate old products associated with application with same bundle-id. (Ex: "True")
                            In case of prod deployment it indicates whether to deactivate all prod products.

Build Information is used to track which Products and builds are being uploaded and promoted.

Optional parameters:
options - Two options are available.
1. -h/ -- Help: Gives the details on how to use the script.

2. -v {Value}/ --Version {Value} : Use this option to provide a custom numeric version(Up to 3 digits), if the actual file version is a alpha numeric version or it is a 4 or more digits version (Ex: python deployment.py -v "1.0.0" "app.apk" "App Build Project,1" "Alpha" "True")

3. -p {Value}/ --ProductName {Value} : Use this option to provide a custom product name (Ex: python deployment.py -p "demo_product" "app.apk" "App Build Project,1" "Alpha" "True")

Currently, the first time when a product is published with Alpha deployment mode a productdetails.json file is created in the working directory and has the app id, app name, product name, product id, build information, version, deployment type, organization group, bundle id details.
This is being used in the script to decide what state the product deployment is for a particular build.

Example: {"new": {"45": {"app_id": 483, "app_name": "demo", "product_id": 0, "product_name": "Apps_demo_v1.0.0", "app_version": "1.0.0", "current_deployment": "Prod", "organization_group":"7", "bundle_id": "com.one97.hero"}}

#### 2. Updating assignments for an existing product
`` python deployment.py <options> <File Path> <Build Information> <Deployment Type> <Deactivate Old Product>``

Updating assignments can only be performed for the products which have been created and uploaded using the same script.

Updating assignment for an existing product needs the following required parameters:
1. File Path - Absolute file path of the application.
2. Build Information - Comma separated Build Project Name and Build Number. (Ex: "My App Build Project,1")
3. Deployment Type - Supported values are Alpha, Beta, or Prod. These are the assignment groups. One value can be given at a time. (Ex: "Alpha")
4. Deactivate Old Product - Supported values are True or False. 
                            In case of product creation it indicates whether to deactivate old products associated with application with same bundle-id. (Ex: "True")
                            In case of prod deployment it indicates whether to deactivate all prod products.
                            
When updating assignment of an existing product, the build information needs to be same as it was given when the product was created. 

Optional parameters:
options - Two options are available.
1. -h/ -- Help: Gives the details on how to use the script.

2. -v {Value}/ --Version {Value} : Use this option to provide a custom numeric version(Up to 3 digits), if the actual file version is a alpha numeric version or it is a 4 or more digits version (Ex: python deployment.py -v "1.0.0" "app.apk" "App Build Project,1" "Alpha" "True")

3. -p {Value}/ --ProductName {Value} : Use this option to provide a custom product name (Ex: python deployment.py -p "demo_product" "app.apk" "App Build Project,1" "Alpha" "True")

If product name is given in parameters, it has to be same as it was given when the product was created.


## **Integrating with Jenkins**
jenkins_build_information.py is a python script that has been written to fetch jenkins build information.

This script can be integrated with jenkins as follows:
1. Download and install jenkinsapi library by executing the command 
`pip install jenkinsapi`
2. Fill in the Build server details in config.py
3. Configure the post build action in the build pipeline
4. Provide the absolute path of jenkins_build_information.py for Build Information argument.

## **Integrating the Script with a Build Server**
The script can be integrated with any build server as follows:
1. To integrate the script, fill in the Build server details in config.py
2. Write a Python script to call an appropriate Build Server API to get the build information.
3. Add a post build action in the build pipeline
4. Provide the absolute file path of the Build Server API client written in place of <Build Information> argument.

## **Testing**
End to End test cases have been added under the folder 'testing'. Please refer ReadMe file under testing folder for more details on how to run the test cases.

## **EndPoints Used**
1. BLOB_UPLOAD_URL = '/api/mam/apps/blobs/uploadblob'
2. APP_UPLOAD_URL = '/api/mam/apps/internal/begininstall'
3. APPLICATION_SEARCH_URL = '/API/v1/mam/apps/search'
4. APPLICATION_DETAILS_URL = '/api/mam/apps/internal/{application_id}
5. PRODUCT_ACTIVATE_URL = '/api/v1/mdm/products/{product_id}/activate'
6. CREATE_PRODUCT_URL = '/api/v1/mdm/products/maintainProduct'
7. PRODUCT_APPLICATION_URL = '/api/v1/mdm/products/{application_id}/assignments'
8. PRODUCT_DEACTIVATE_URL = '/api/v1/mdm/products/{product_id}/deactivate'
9. PRODUCT_SEARCH_URL = '/api/v1/mdm/products/extensivesearch'
10. CHILD_ORGANIZATION_GROUP_SEARCH_URL = '/api/system/groups/{organizationgroup_id}/children'
11. PARENT_ORGANIZATION_GROUP_SEARCH_URL = '/api/system/groups/{organizationgroup_uuid}/parents'
12. ORGANIZATION_GROUP_DETAILS_URL = '/api/system/groups/{organizationgroup_uuid}/tree'