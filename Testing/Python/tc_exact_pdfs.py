#!/usr/bin/python

import sys
from dcpyps import samples
from dcpyps import qmatlib as qml
from dcpyps import scalcslib as scl
import numpy


variable = numpy.logspace(numpy.log10(0.00001), numpy.log10(10))

f= numpy.zeros([variable.size,2])
g= numpy.zeros([variable.size,2])

count=0;
for i in variable.flat:
    f [count,0] = i
    f [count,1] = scl.ideal_dwell_time_pdf(i, mec1.QAA,qml.phiA(mec1))
    g [count,1] = scl.ideal_dwell_time_pdf(i, mec1.QFF,qml.phiF(mec1))
    g [count,0] = i

    count=count+1    
#sys.stdout.write('%s' % f)

#sys.stdout.write('\n\nt=1,pdf =')
#sys.stdout.write('%s' % f)
#sys.stdout.write('%s' % g)

print qml.phiF(mec1)

numpy.savetxt('open_pdf.csv', f, delimiter=",")
numpy.savetxt('closed_pdf.csv', g, delimiter=",")

