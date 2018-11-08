def nodeName = ['tomcat1', 'tomcat2']
def nexusRepo = "http://192.168.56.10:8081/nexus/content/repositories"
def version
node ('master') {
    stage ('PREPARING'){
        cleanWs ()
        git branch: 'task6', credentialsId: 'GITCreds', url: 'https://github.com/mpekhota/first.git'
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
node () {
    if(nodeName.size()>0){
        int i = 0
        for (tomcat in nodeName){
            stage("DEPLOY TO ${nodeName[i]}"){
                sh 'sudo chmod 775 /var/lib/tomcat/webapps'
                sh "curl ${nexusRepo}/snapshots/test/${version}/first.war  -o /var/lib/tomcat/webapps/first.war"
                sh 'sudo chmod 777 /var/lib/tomcat/webapps/first.war'
                sh 'curl -X POST "http://192.168.56.10/jkmanager?cmd=update&from=list&w=lb&sw=${nodeName[i]}&vwa=1"'
                sleep(3)
                def ReleaseVersion = sh (returnStdout: true, script: 'curl http://localhost:8080/first/')
                ReleaseVersion = ReleaseVersion.replaceAll(/<!--.*?-->/, '').replaceAll(/<.*?>/, '')
                sh 'curl -X POST "http://192.168.56.10/jkmanager?cmd=update&from=list&w=lb&sw=${nodeName[i]}&vwa=0"'
                ReleaseVersion = ReleaseVersion.trim()
                if (ReleaseVersion.equals(version)) {
                    println "UPDATE SUCCESS! NEW VERSION ${version}"
                }
                else {
                    error "ERROR DEPLOY TO ${NODE_NAME}. TRY AGAIN."
                }
                i++
            }
        }
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
            sh ("git checkout master")
            sh ("git merge task6")
            sh ("git push --tags https://${GITLogin}:${GITPass}@github.com/mpekhota/first.git master")
        } 
    }
}