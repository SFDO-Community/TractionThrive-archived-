from cumulusci.tasks.salesforce import BaseSalesforceApiTask

class ngmTransform(BaseSalesforceApiTask):
    def _run_task(self):
        def getId(line):
            index1 = line.find('(') + 1
            index2 = line.find("'", index1 + 1) + 1
            return line[index1:index2]

        def createInsertLine(id, networkId, count):
            insertLine = "INSERT INTO \"NetworkMemberGroup\" VALUES("
            insertLine += str(count)
            insertLine += ','
            insertLine += id
            insertLine += ','
            insertLine += networkId
            insertLine += ');'
            return insertLine

        networkId = list()
        ids = list()
        count = 0
        extractFile = open('datasets/nmg-extract.sql')
        loadFile = open('datasets/nmg-load.sql', 'a')

        for line in extractFile:

            #To add additional names to look for: 
            #Copy paste lines 28 and 29
            #Replace 'Einstein_Analytics_Community_User' with the name you want
            if 'Einstein_Analytics_Community_User' in line:
                ids.append(getId(line=line))
            if '"Network" VALUES' in line:
                networkId.append(getId(line=line))

        loadFile.write('\n')
        for id in ids:
            count += 1
            loadFile.write( createInsertLine(id = id, networkId = networkId[0], count = count ))
            loadFile.write('\n')

        loadFile.close()