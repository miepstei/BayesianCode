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
    sys.stdout.write('*************tc_exact_likelihoods.py - unit test script **************\n\n')
    sys.stdout.write('Test script for generating HJC exact likelihood functions\n')
    sys.stdout.write('Uses CH82 mechanism for generating relevent matrices and test data as appropriate\n')
    sys.stdout.write('Writes to user specified results file for comparison with Matlab ME program\n\n')
    sys.stdout.write('**********************************************************************\n\n')

def main(mec,opts):
    tres = opts['tres']
    tcrit = opts['tcrit']

    GAF, GFA = qml.iGs(mec.Q, mec.kA, mec.kF)
    expQFF = qml.expQt(mec.QFF, tres)
    expQAA = qml.expQt(mec.QAA, tres)
    eGAF = qml.eGs(GAF, GFA, mec.kA, mec.kF, expQFF)
    eGFA = qml.eGs(GFA, GAF, mec.kF, mec.kA, expQAA)
    phiF = qml.phiHJC(eGFA, eGAF, mec.kF)
    startB = qml.phiHJC(eGAF, eGFA, mec.kA)
    endB = np.ones((mec.kF, 1))

    Aeigvals, AZ00, AZ10, AZ11,_,_,_,_,_,_ = qml.Zxx(mec.Q, mec.kA, mec.QFF,
        mec.QAF, mec.QFA, expQFF, True)
    Aroots,_ = scl.asymptotic_roots(tres,
        mec.QAA, mec.QFF, mec.QAF, mec.QFA, mec.kA, mec.kF)
    AR = qml.AR(Aroots, tres, mec.QAA, mec.QFF, mec.QAF, mec.QFA, mec.kA, mec.kF)
    Feigvals, FZ00, FZ10, FZ11,_,_,_,_,_,_ = qml.Zxx(mec.Q, mec.kA, mec.QAA,
        mec.QFA, mec.QAF, expQAA, False)
    Froots,_ = scl.asymptotic_roots(tres,
        mec.QFF, mec.QAA, mec.QFA, mec.QAF, mec.kF, mec.kA)
    FR = qml.AR(Froots, tres, mec.QFF, mec.QAA, mec.QFA, mec.QAF, mec.kF, mec.kA)

    startB, endB = qml.CHSvec(Froots, tres, tcrit,
         mec.QFA, mec.kA, expQAA, phiF, FR)

#array of times
    times=np.linspace(0.000001, 0.01, num=50)
    p_Af0=np.empty((times.shape[0],mec.kA,mec.kF))
    p_Af1=np.empty((times.shape[0],mec.kA,mec.kF))
    p_eGAF=np.empty((times.shape[0],mec.kA,mec.kF))
    p_Ff0=np.empty((times.shape[0],mec.kF,mec.kA))
    p_Ff1=np.empty((times.shape[0],mec.kF,mec.kA))
    p_eGFA=np.empty((times.shape[0],mec.kF,mec.kA))

#generate f0,f1 and eGAF for open and closed intervals 
    for time in range(len(times)):
        p_Af0[time,:,:] = qml.f0(times[time] - tres, Aeigvals, AZ00)
        p_Af1[time,:,:] = qml.f1(times[time] - (2 * tres), Aeigvals, AZ10, AZ11)
        p_eGAF[time,:,:] = qml.eGAF(times[time], tres, Aeigvals, AZ00, AZ10, AZ11, Aroots, AR, mec.QAF, expQFF)
        p_Ff0[time,:,:]=qml.f0(times[time] - tres,Feigvals,FZ00)
        p_Ff1[time,:,:]=qml.f1(times[time]-(2*tres),Feigvals,FZ10,FZ11)
        p_eGFA[time,:,:]=qml.eGAF(times[time], tres, Aeigvals, FZ00, FZ10, FZ11, Froots, FR, mec.QFA, expQAA)

    data={}
    data['p_Af0']=p_Af0
    data['p_Af1']=p_Af1
    data['p_eGAF']=p_eGAF
    data['p_Ff0']=p_Ff0
    data['p_Ff1']=p_Ff1
    data['p_eGFA']=p_eGFA

    sp.savemat('TestData/functions.mat',data)
    sys.stdout.write('Function generation finished\noutput saved to test_data/functions.mat\n\n')
