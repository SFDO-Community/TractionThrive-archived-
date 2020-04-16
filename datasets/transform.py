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
linesToInsert = list()
count = 0
extractFile = open('nmg-extract.sql')
loadFile = open('nmg-load.sql', 'a')

for line in extractFile:

    #To add additional names to look for: 
    #Copy paste lines 28 and 29
    #Replace 'Einstein_Analytics_Community_User' with the name you want
    if 'Einstein_Analytics_Community_User' in line:
        ids.append(getId(line=line))
    if '"Network" VALUES' in line:
        networkId.append(getId(line=line))

for id in ids:
    count += 1
    linesToInsert.append( createInsertLine(id = id, networkId = networkId[0], count = count) )

loadFile.write('\n')
for line in linesToInsert:
    loadFile.write(line)
    loadFile.write('\n')

loadFile.close()