ds_file = open('ds.txt', 'r')
print ds_file
lines = ds_file.read().split('\n')
data = []
for i in range(0, len(lines)):
	data.append(lines[i].split(','))
	#print data[i]	

print data[1]


