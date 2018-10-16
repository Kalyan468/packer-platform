pipeline {
    agent {
        label 'master'
    }
    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
    }

    parameters {
        choice(
            name: 'type',
            choices: 'rhel6.7\nrhel7.4\ncentos6.7\ncentos7.4',
            description: 'Type of base image to build.'
        )
        credentials(
            name: 'subscription_id',
            description: 'The subscription id where the image will be built and stored on',
            credentialType: 'org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl',
            required: true
        )
        string(
            name: 'resource_group_name',
            defaultValue: 'base-images',
            description: "The resulting image will be stored in this resource group. Will be created in specified location if it doesn't exist."
        )
        choice(
            name: 'location',
            choices: 'North Europe\nWest Europe',
            description: 'Which Azure location to use when building the image and, when necessary, creating a resource group for the resulting image.'
        )
        string(
            name: 'virtual_network_name',
            description: "If specified, use an existing virtual network to build the image on. Communication with the VM will be done privately, so private connectivity to this network must be in place."
        )
        string(
            name: 'virtual_network_resource_group_name',
            description: "Required if specifying a virtual_network_name that is ambiguous in the selected subscription"
        )
        string(
            name: 'virtual_network_subnet_name',
            description: "Required if specifying a virtual_network_name that has more than one subnet"
        )
    }

    environment {
        ARM_SUBSCRIPTION_ID = credentials("${params.subscription_id}")
        ARM_CLIENT_ID = credentials("arm_client_id")
        ARM_CLIENT_SECRET = credentials("arm_client_secret")
        ARM_TENANT_ID = credentials("arm_tenant_id")
    }

    stages {
        stage('Build') {
            environment {
                ARM_LOCATION = "${params.location}"
                ARM_RESOURCE_GROUP = "${params.resource_group_name}"
                ARM_VIRTUAL_NETWORK_NAME = "${params.virtual_network_name}"
                ARM_VIRTUAL_NETWORK_RESOURCE_GROUP_NAME = "${params.virtual_network_resource_group_name}"
                ARM_VIRTUAL_NETWORK_SUBNET_NAME = "${params.virtual_network_subnet_name}"
                CI_BUILD_ID = "Jenkins"
                CI_BUILD_LINK = "${BUILD_URL}"
            }
            steps {
                ansiColor('xterm') {
                    sh "echo $ARM_CLIENT_ID > ./output.txt"
                    sh "docker-compose build image-maker && docker-compose run --rm image-maker make azure-base-image OS_FLAVOUR=${params.type}"
                }
            }
            post {
                success {
                    publishHTML target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'test/reports',
                        reportFiles: 'cis-report.html',
                        reportName: 'CIS report'
                      ]
                }
            }
        }
        stage('List the base images in the subscription') {
            steps {
                ansiColor('xterm') {
                    sh "docker-compose build image-maker && docker-compose run --rm image-maker make azure-base-image-list | tee ./base-image-list.txt"
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'base-image-list.txt'
                }
            }
        }
    }
}
