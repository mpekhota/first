def version
def project = 'bluegreen'
def gitRepo='https://github.com/mpekhota/first'
def current_branch='task10'

node ("master"){
    stage('PREPARATION') {
        git branch: current_branch, url: gitRepo
    }    
    stage('CHANGE VERSION') {    
        def jsonFile = readJSON file: "environments/${project}.json"
        jsonFile['cookbook_versions']['bluegreen'] = tags
        writeJSON json: jsonFile, pretty: 4, file: "environments/${project}.json"
        sh """ sed -i 's/.*'"'version'"'.*/'"default['${project}']['version']='${tags}'"'/' ~/workspace/${project}/attributes/default.rb"""
        sh """ sed -i 's/^version.*/'"version '${tags}'"'/' ~/workspace/${project}/metadata.rb"""
    }
    stage('CHEF IS COOKING...'){
        sh "pwd"
        sh "berks install && berks upload"
        sh "knife environment from file environments/${project}.json"
        sh "chef-client"
        
    }
    stage('PUSH TO GIT') {
        withCredentials([usernamePassword(credentialsId: "GITCreds", passwordVariable: "GITPass", usernameVariable: "GITLogin")]) {
            sh ("git config --global user.name mpekhota")
            sh ("git config --global user.email m.pekhota@gmail.com")
            sh ("git commit -am \"Update files in task10\"")
            sh ("git push https://${GITLogin}:${GITPass}@${gitRepo}}")
        } 
    }
}