node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO', value: 'xzport'), string(name: 'DESCRIPTION', 'xz is a new general-purpose, command line data compression utility, similar to gzip and bzip2.' )]
        }
}
