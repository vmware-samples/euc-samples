# **Workspace ONE ProductManagement-Samples**

## **Overview**
* **Author(s)** : Krati Gupta
* **Email** : krgupta@vmware.com
* **Date Created** : 06 March 2020

## **Testing ProductManagement-Samples Script**
There are 2 different approaches for testing of this Sample:
### **1. Post-script Validation** (/testing/validate_product_script_execution.py)
*Post-script validation is recommended every time the python script is executed for Product deployment.*
There is a feature flag in the config file: 'POST_SCRIPT_VALIDATION' which can be set to 0 if the user does not want these validations to run. When the 'POST_SCRIPT_VALIDATION' flag is set to 1, the validations will be executed automatically after the main script completes execution.

As of now, the following validations are done once the product is deployed:

1.	Name of the product uploaded on the console.
2.	The newly uploaded product should be in the 'Active' state.
3.	The product should be uploaded under the same organization group, as mentioned in the config file.
4.	The product should be assigned to the correct smart groups, same as the ones mentioned in the config file.

Post-script validation script can be extended to validate additional data like App version etc.

### **2. Test Cases** (/testing/product_deployment_tests.py)
Apart from the post-script validation, there are some test cases which can be used to test the tool at any time.
Executing these test cases will deploy the sample product to a test environment mentioned in the config/config.py file. These tests are used to validate end to end script execution.
####
*Executing test cases is recommended when the script has to be executed for the first time or if any changes are made to the script.*

#### Executing the Test Cases
Follow these steps to test the tool:
1. Place some sample application files in the testing/Sample_Apps folder.
2. Update the testing/test_config.py file with the corresponding details.
3. Update the config/config.py file with the test environment details.
4. Execute the following command in the command prompt:
python -m pytest testing/product_deployment_tests.py --html={name of the report file.html}

Once the test execution is completed, a HTML report will be generated with all the details.

**Note**: pytest-html package is required for exporting the reports to HTML. It can be installed by executing the command:
`pip install pytest-html`

Alternatively, the following command can be used to display the test results on the command prompt itself:
`python -m pytest testing/product_deployment_tests.py`
