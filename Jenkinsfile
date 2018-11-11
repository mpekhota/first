def nexusRepo = "http://192.168.56.10:8081/nexus/content/repositories"
def version
node ('master') {
    stage ('PREPARING'){
        cleanWs ()
        git branch: 'task7', credentialsId: 'GITCreds', url: 'https://github.com/mpekhota/first.git'
    }
    stage ('BUILD') {
        sh 'chmod 777 ./gradlew'
        sh './gradlew task ChangeCurrentVersion'
        sh './gradlew build'
    }
    stage ('UPLOAD ARTIFACTORY') {
        version = readFile("${env.WORKSPACE}/build/resources/main/greeting.txt")
        withCredentials([usernamePassword(credentialsId: 'NexusCreds', passwordVariable: 'NexusPass', usernameVariable: 'NexusLogin')]) {
            sh "curl -X PUT -u ${NexusLogin}:${NexusPass} -T ${env.WORKSPACE}/build/libs/first.war \"${nexusRepo}/snapshots/test/${version}/first.war\""
        }
        println "NEXUS ARTIFACTORY VERSION ${version}" 
    }
}
node ('master') {
    stage('BUIL DOCKER TO REGISTRY') {
        mkdir /home/vagrant/containers && cd /home/vagrant/containers
        wget https://github.com/mpekhota/first/blob/task7/Dockersfile
        docker build -t localhost:5000/task7/tomcatcontainer:${version} /home/vagrant/containers
    }
}
node ('master') {
    stage('PUSH TO GIT') {
        withCredentials([usernamePassword(credentialsId: 'GITCreds', passwordVariable: 'GITPass', usernameVariable: 'GITLogin')]) {
            sh ("git config --global user.name mpekhota")
            sh ("git config --global user.email m.pekhota@gmail.com")
            sh ("git add gradle.properties")
            sh ("git tag ${version}")
            sh ("git commit -am \"BUILD - ${version}\"")
            sh ("git push https://${GITLogin}:${GITPass}@github.com/mpekhota/first.git")
            sh ("git push --tags https://${GITLogin}:${GITPass}@github.com/mpekhota/first.git master")
        } 
    }
}