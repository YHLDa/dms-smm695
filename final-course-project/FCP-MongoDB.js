cd final-course-project\Data

mongoimport --host ac-onu183r-shard-00-01.oeklur0.mongodb.net:27017 --db fcp --collection gitData --type json --file gitData.json --jsonArray --authenticationDatabase admin --ssl  --username smm695-yihsuanliu
mongoimport --host ac-onu183r-shard-00-01.oeklur0.mongodb.net:27017 --db fcp --collection gitIssues --type json --file gitIssues.json --jsonArray --authenticationDatabase admin --ssl  --username smm695-yihsuanliu


mongoimport --db=fcp --collection=gitData  --file=gitData.json
mongoimport --db=fcp --collection=gitIssues  --file=gitIssues.json