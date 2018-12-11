def tagsURL="http://192.168.56.10:5000/v2/first/tags/list"
def someData = new URL(tagsURL).getText()
def result = new groovy.json.JsonSlurper().parseText(someData)
return result.tags