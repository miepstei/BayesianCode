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
    sys.stdout.write('Test script for generating HJC exact likelihood matrices\n')
    sys.stdout.write('Uses CH82 mechanism for generating relevent matrices and test data as appropriate\n')
    sys.stdout.write('Writes to user specified results file for comparison with Matlab ME program\n\n')
    sys.stdout.write('**********************************************************************\n\n')

def main(mec,opts):

    tcrit = opts['tcrit']
    tres = opts['tres']

    sys.stdout.write('Spectral expansion of -Q\n\n')
    eigvals,specQ = qml.eigs(-mec.Q)

    sys.stdout.write('Spectral expansion of Q_AA\n\n')
    eigvals,specA = qml.eigs(mec.QAA)

    sys.stdout.write('Generating G_AF and G_FA matricies\n\n')
    GAF, GFA = qml.iGs(mec.Q, mec.kA, mec.kF)

    sys.stdout.write('Generating exponentiated matrices\n\n')
    expQFF = qml.expQt(mec.QFF, tres)
    expQAA = qml.expQt(mec.QAA, tres)

    sys.stdout.write('Generating eG_AF, eG_FA matrices\n\n')
    eGAF = qml.eGs(GAF, GFA, mec.kA, mec.kF, expQFF)
    eGFA = qml.eGs(GFA, GAF, mec.kF, mec.kA, expQAA)

    sys.stdout.write('Generating phi matrices\n\n')
    phiA = qml.phiHJC(eGAF, eGFA, mec.kA)
    phiF = qml.phiHJC(eGFA, eGAF, mec.kF)
    Aeigvals, AZ00, AZ10, AZ11,AC00,AC10,AC11,AA1,AD,spec_A = qml.Zxx(mec.Q, mec.kA, mec.QFF,
            mec.QAF, mec.QFA, expQFF, True)

#eigen, Z00, Z10, Z11,C00,A1,D,A
    Feigvals, FZ00, FZ10, FZ11,FC00,FC10,FC11,FA1,FD,spec_F = qml.Zxx(mec.Q, mec.kA, mec.QAA,
            mec.QFA, mec.QAF, expQAA, False)

    data = {}
    data['p_GAF']=GAF
    data['p_GFA']=GFA
    data['p_expQAA']=expQAA
    data['p_expQFF']=expQFF
    data['p_eGAF']=eGAF
    data['p_eGFA']=eGFA
    data['p_Q']=mec.Q
    data['p_tres']=tres
    data['p_QAA']=mec.QAA
    data['p_QFF']=mec.QFF
    data['p_phiA']=phiA
    data['p_phiF']=phiF
    data['p_AZ00']=AZ00
    data['p_AZ10']=AZ10
    data['p_AZ11']=AZ11
    data['p_FZ00']=FZ00
    data['p_FZ10']=FZ10
    data['p_FZ11']=FZ11
    data['p_A_eigenvals'] = Aeigvals
    data['p_F_eigenvals'] = Feigvals
    data['p_specA']=spec_A
    data['p_specF']=spec_F
    data['p_AC00']=AC00
    data['p_AC10']=AC10
    data['p_AC11']=AC11
    data['p_AA1']=AA1
    data['p_AD']=AD
    data['p_FC00']=FC00
    data['p_FC10']=FC10
    data['p_FC11']=FC11
    data['p_FA1']=FA1
    data['p_FD']=FD
    data['p_specA']=specA
    data['p_specQ']=specQ
    sp.savemat('TestData/matrices.mat',data)

    sys.stdout.write('Matrix generation finished\noutput saved to TestData/matrices.mat\n\n')

    asymptotic_data={}
    s=-10
    H_AA = qml.H(s, tres, mec.QAA, mec.QFF, mec.QAF, mec.QFA, mec.kF)
    H_FF = qml.H(s, tres, mec.QFF, mec.QAA, mec.QFA, mec.QAF, mec.kA)

    W_AA=qml.W(s, tres, mec.QAA, mec.QFF, mec.QAF, mec.QFA, mec.kA, mec.kF)
    W_FF=qml.W(s, tres, mec.QFF, mec.QAA, mec.QFA, mec.QAF, mec.kF, mec.kA)

    asymptotic_data['p_HAA'] = H_AA
    asymptotic_data['p_HFF'] = H_FF
    asymptotic_data['p_WAA']=W_AA
    asymptotic_data['p_WFF']=W_FF

#roots
    Aroots,a_initial = scl.asymptotic_roots(tres,
            mec.QAA, mec.QFF, mec.QAF, mec.QFA, mec.kA, mec.kF)

    Froots,f_initial = scl.asymptotic_roots(tres,
            mec.QFF, mec.QAA, mec.QFA, mec.QAF, mec.kF, mec.kA)

    asymptotic_data['p_a_initial']=a_initial
    asymptotic_data['p_f_initial']=f_initial
    asymptotic_data['p_Aroots']=Aroots
    asymptotic_data['p_Froots']=Froots

    A_dW = qml.dW(Aroots[0], tres, mec.QAF, mec.QFF, mec.QFA, mec.kA, mec.kF)
    F_dW = qml.dW(Froots[0], tres, mec.QFA, mec.QAA, mec.QAF, mec.kF, mec.kA)

    asymptotic_data['p_A_dW']=A_dW
    asymptotic_data['p_F_dW']=F_dW

    a_AR=qml.AR(Aroots, tres, mec.QAA, mec.QFF, mec.QAF, mec.QFA, mec.kA, mec.kF)
    f_AR=qml.AR(Froots, tres, mec.QFF, mec.QAA, mec.QFA, mec.QAF, mec.kF, mec.kA)

    asymptotic_data['p_a_AR']=a_AR
    asymptotic_data['p_f_AR']=f_AR

#CHS vectors
    p_start,p_finish = qml.CHSvec(Froots, tres, tcrit, mec.QFA, mec.kA, expQAA, phiF, f_AR)
    asymptotic_data['p_start']=p_start
    asymptotic_data['p_finish']=p_finish

    sp.savemat('TestData/asymptotic.mat',asymptotic_data)

    sys.stdout.write('Asymptotic generation finished\noutput saved to TestData/asymptotic.mat\n\n')
