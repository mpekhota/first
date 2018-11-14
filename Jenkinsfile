def version
def branch = "task7"
def nexusRepo = "http://192.168.56.10:8081/nexus/content/repositories"
def dockerRegistry = "192.168.56.10:5000"
node ('master') {
    stage ('PREPARING'){
        cleanWs ()
        git branch: "${branch}", credentialsId: "GITCreds", url: "https://github.com/mpekhota/first.git"
    }
    stage ('BUILD WAR') {
        
        sh "./gradlew task ChangeCurrentVersion"
        sh "./gradlew build"
    }
    stage ('UPLOAD ARTIFACTORY') {
        version = readFile("${env.WORKSPACE}/build/resources/main/greeting.txt")
        withCredentials([usernamePassword(credentialsId: "NexusCreds", passwordVariable: "NexusPass", usernameVariable: "NexusLogin")]) {
            sh "curl -X PUT -u ${NexusLogin}:${NexusPass} -T ${env.WORKSPACE}/build/libs/first.war \"${nexusRepo}/snapshots/test/${version}/first.war\""
        }
        println "NEXUS ARTIFACTORY VERSION ${version}" 
    }
    stage('BUILD DOCKER TO REGISTRY') {
        sh "docker build -t first:${version} --build-arg version=${version} ."
        sh "docker tag first:${version} ${dockerRegistry}/first:${version}"
        sh "docker push ${dockerRegistry}/first:${version}"
    }
    stage('RUN DOCKER SWARM'){
        def status = sh(returnStdout: true, script: 'docker service ls | grep -c "tomcatweb" || true')
        println status.dump()
        if (status.trim().equals("1")) {
            sh "docker service update --image ${dockerRegistry}/first:${version} tomcatweb"
        }
        else {
            sh "docker service create --name tomcatweb --replicas 2  --update-delay 30s --publish 8089:8080 ${dockerRegistry}/first:${version}"
        }
        def releaseVersion = sh (returnStdout: true, script: 'curl http://192.168.56.10:8089/first/')
        releaseVersion = releaseVersion.replaceAll(/<!--.*?-->/, '').replaceAll(/<.*?>/, '')
        releaseVersion = releaseVersion.trim()
        if (releaseVersion.equals(version)) {
            println "UPDATE SUCCESS! NEW VERSION ${version}"
        }
    }
    stage('PUSH TO GIT') {
        withCredentials([usernamePassword(credentialsId: "GITCreds", passwordVariable: "GITPass", usernameVariable: "GITLogin")]) {
            sh ("git config --global user.name mpekhota")
            sh ("git config --global user.email m.pekhota@gmail.com")
            sh ("git add gradle.properties")
            sh ("git tag ${version}")
            sh ("git commit -am \"BUILD - ${version}\"")
            sh ("git push https://${GITLogin}:${GITPass}@github.com/mpekhota/first.git")
            sh ("git checkout master")
            sh ("git merge ${branch} --strategy-option theirs")
            sh ("git push --tags https://${GITLogin}:${GITPass}@github.com/mpekhota/first.git master")
        } 
    }
}