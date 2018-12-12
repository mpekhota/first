#Run command for Task11

aws ec2 run-instances --cli-input-json file://ec2.json


aws ec2 run-instances --cli-input-json file://aws.json --user-data file://userdata.sh

