#this script calculates the average CPI of curent version CPU base on log files

def cal(filename):
	content = open(filename)
	cycle = 0
	ICount = 0
	for line in content:
		if 'SUCCESS' in line:
			c_pos = line.find('CYCLES:')
			ic_pos = line.find('ICOUNT:')
			ih_pos = line.find('IHITRATE:')
			cycle = cycle + int(line[c_pos + 7 : ic_pos - 1])
			ICount = ICount + int(line[ic_pos + 7 : ih_pos - 1])
	return cycle, ICount

file = ['complex_demo1.summary.log', 
		'rand_final.summary.log',
		'complex_demo2.summary.log',
		'rand_icache.summary.log',
		'complex_demofinal.summary.log',
		'rand_idcache.summary.log',
		'inst_tests.summary.log',
		'rand_ldst.summary.log',
		'perf.summary.log',
		'rand_complex.summary.log',
		'rand_ctrl.summary.log',
		'rand_dcache.summary.log']

cycles = 0
instrs = 0

for name in file:
	c_cnt, i_cnt = cal(name)
	cycles = cycles + c_cnt
	instrs = instrs + i_cnt

print('Average CPI is:', '%.2f' % (float(cycles) / float(instrs)))
