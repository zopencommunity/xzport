node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO', value: 'xzport'), string(name: 'DESCRIPTION', 'xzport' )]
        }
}
