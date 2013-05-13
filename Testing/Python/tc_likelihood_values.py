#!/usr/bin/python

import sys
import os
from dcpyps import samples
from dcpyps import qmatlib as qml
from dcpyps import scalcslib as scl
import numpy as np
import scipy.io as sp
from dcpyps import optimize
from dcpyps import dcio
from dcpyps import dataset
from dcpyps import mechanism
print os.path.abspath(qml.__file__)

def usage():
    sys.stdout.write('*************tc_exact_likelihoods.py - unit test script **************\n\n')
    sys.stdout.write('Test script for generating HJC exact likelihood values for a range of Q matrices\n')
    sys.stdout.write('Uses CH82 mechanism for generating relevent Q-matrices and likelihoods as appropriate\n')
    sys.stdout.write('Writes to user specified results file for comparison with Matlab ME programs\n\n')
    sys.stdout.write('**********************************************************************\n\n')

def main(mec,opts):

    outFile = open('results.txt', 'w')
    #run through a simplex fit and save the values in the q_matrix
    xout, fout, niter, neval = optimize.simplex(scl.HJClik,
       np.log(mec.theta()), maxiter=100,args=opts, display=True,outdev=outFile)
    outFile.close()

    with open('results.txt') as f:
        for i, l in enumerate(f):
            pass
        lines = i

    lines=lines+1

    inFile = open('results.txt', 'r')
    p_sim=np.zeros((lines,11))
    line_count=0;
    for ITERATION in inFile.readlines():
        line_words = ITERATION.split(',')
        for i in range(11):
            p_sim[line_count,i]=line_words[i]
        line_count=line_count+1

    inFile.close()

    data={}
    data['p_sim']=p_sim

    sp.savemat('TestData/likelihoods.mat',data)
    sys.stdout.write('Function generation finished\noutput saved to TestData/likelihoods.mat\n\n')



