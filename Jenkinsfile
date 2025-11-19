pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = credentials('AWS_REGION')
    }

    triggers {
        // Run every day at 11:30 PM
        cron('59 23 * * *')
    }

    stages {
        stage('Run AWS Cleanup Script') {
            steps {
                sh '''
                    echo "Running AWS Cleanup Job..."

                    # Export AWS variables
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

                    chmod +x scripts/aws_cleanup.sh
                    ./scripts/aws_cleanup.sh
                '''
            }
        }
    }
}
