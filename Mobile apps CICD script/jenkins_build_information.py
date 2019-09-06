from jenkinsapi.jenkins import Jenkins
import sys

import config.config as build_config


def get_build_info(request_url, job_name, username, password):
    """
    Returns latest jenkins build number for the given project name
    :param request_url: jenkins server url
    :param job_name: Jenkins Project Name
    :param username: Username to login to jenkins build server
    :param password: Password to login to jenkins build server
    :return: Build job number
    """

    jenkins_job = Jenkins(request_url, username, password)
    latest_job = jenkins_job[job_name]
    latest_job_info = latest_job.get_last_build()
    return latest_job_info.buildno


if __name__ == '__main__':
    build_number = get_build_info(build_config.BUILD_SERVER_URL, build_config.BUILD_PROJECT_NAME,
                                  build_config.BUILD_SERVER_USERNAME, build_config.BUILD_SERVER_PASSWORD)
    sys.exit(build_number)
