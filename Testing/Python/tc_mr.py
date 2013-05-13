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

def usage():
    sys.stdout.write('*************tc_mr.py - unit test script **************\n\n')
    sys.stdout.write('Test script for testing constraints and mr determined rates for a range of Q matrices\n')
    sys.stdout.write('Uses CH82 mechanism for generating relevent Q-matrices and likelihoods as appropriate\n')
    sys.stdout.write('Writes to user specified results file for comparison with Matlab ME programs\n\n')
    sys.stdout.write('**********************************************************************\n\n')

def main(mec,opts):
    data={}
    p_rates=np.zeros((1,10))
    p_withconstraints=np.zeros((1,10))

    # PREPARE RATE CONSTANTS - this is the setup from fitdemo.py
    # Fixed rates.
    mec.update_mr()
    mec.update_constrains()
    p_withconstraints[0,] = mec.unit_rates()
    p_rates[0,] = mec.unit_rates()

    data['p_withconstraints']=p_withconstraints

    sp.savemat('TestData/constraints_mr.mat',data)
    sys.stdout.write('Function generation finished\noutput saved to TestData/contstraints_mr.mat\n\n')

