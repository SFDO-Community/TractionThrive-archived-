from cumulusci.tasks.salesforce import BaseSalesforceApiTask	

class NgmTransForm(BaseSalesforceApiTask):	
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

            # To add additional names to look for: 	
            # Copy & paste each if statement below	
            # Replace 'Customer Community - Medical Staff' with the permission set or 	
            # profile you'd like to add a network member group for	
            if 'Customer Community - Medical Staff' in line:	
                ids.append(getId(line=line))	
            if 'Customer Community - Hospital Administrator' in line:	
                ids.append(getId(line=line))	
            if 'Customer Community - Health Authority' in line:	
                ids.append(getId(line=line))	
            if '"Network" VALUES' in line:	
                networkId.append(getId(line=line))	

        loadFile.write('\n')	
        for id in ids:	
            count += 1	
            loadFile.write( createInsertLine(id = id, networkId = networkId[0], count = count ))	
            loadFile.write('\n')	

        loadFile.close() 	