# API host url to make the call against
HOST_URL = ''
PORT = 443
# Represents WS1 _numeric_ organization group-ID
TENANT_GROUP_ID = ''
# The WS1 REST API tenant code
AW_TENANT_CODE = ''
# Username and Password to access WS1 REST APIs
API_USERNAME = ''
API_PASSWORD = ''
# List of assignment groups in WS1 UEM for Alpha deployment
ALPHA_GROUPS = []
# List of assignment groups in WS1 UEM for Beta deployment
BETA_GROUPS = []
# List of assignment groups in WS1 UEM for Production deployment
PRODUCTION_GROUPS = []

# POST_SCRIPT_VALIDATION : 1 => When set to 1, after uploading and publishing the product, the script will fetch
#                               the details of the uploaded product and validate:
#                               Product is in Active State
#                               Product is uploaded in the same OG as mentioned in the config file
#                               Product is assigned to the same Smart Groups as mentioned in the config file
#                        : 0 => When set to 0. It will just upload and publish the product. Validations will not be
#                               done.
POST_SCRIPT_VALIDATION = 1

# ----------------------------------------------------------------------------------------------------------------------
# Build Server Details
# Fill in the following details if this python script needs to be integrated with the build server.
# If the build pipeline used is Jenkins, pass the script name "jenkins_build_information.py 1" in place of build number

# Build server url where the app build is run
BUILD_SERVER_URL = ''
# Build project name
BUILD_PROJECT_NAME = ''
# Username to login to the build server
BUILD_SERVER_USERNAME = ''
# Password to login to the build server
BUILD_SERVER_PASSWORD = ''