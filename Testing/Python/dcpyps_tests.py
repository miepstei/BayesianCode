#!/usr/bin/python
import sys
import os
import time

import numpy as np
import scipy.io as sp

from dcpyps import qmatlib as qml
from dcpyps import scalcslib as scl
from dcpyps import optimize
from dcpyps import dcio
from dcpyps import dataset
from dcpyps import mechanism


def bursts(opts,outfile):

    test_treses = opts["TestTres"]
    test_tcrits = opts["TestTcrit"]
    test_tcrit_number=len(test_tcrits)
    test_tres_number=len(test_treses)
    
    data={}; # to be saved as mat file
    
    p_tres_tests = np.zeros(test_tres_number)
    p_tres_resolved = np.zeros(test_tres_number)
    p_tres_ave_length = np.zeros(test_tres_number)
    p_tres_ave_openings = np.zeros(test_tres_number)
    
    p_tcrit_tests = np.zeros(test_tcrit_number)
    p_tcrit_resolved = np.zeros(test_tcrit_number)
    p_tcrit_ave_length = np.zeros(test_tcrit_number)
    p_tcrit_ave_openings = np.zeros(test_tcrit_number)   

    # LOAD DATA.
    filename = opts["DataSet"]
    
    tres=test_treses[0]
    tcrit_count=0   
    # alter tcrit holding tres constant
    for tcrit in test_tcrits:
        ioffset, nint, calfac, header = dcio.scn_read_header(filename)
        tint, iampl, iprops = dcio.scn_read_data(filename, ioffset, nint, calfac)
        rec1 = dataset.TimeSeries(filename, header, tint, iampl, iprops)
        rec1.impose_resolution(tres)
        rec1.get_open_shut_periods()
        rec1.get_bursts(tcrit)
        
        #print('\nNumber of resolved intervals = {0:d}'.format(len(rec1.rtint)))
        p_tcrit_resolved[tcrit_count] = len(rec1.rtint)
        
        #print('\nNumber of bursts = {0:d}'.format(len(rec1.bursts)))
        p_tcrit_tests[tcrit_count]=len(rec1.bursts)
        
        blength = rec1.get_burst_length_list()
        #print('Average length = {0:.9f} millisec'.format(np.average(blength)))
        p_tcrit_ave_length[tcrit_count] = np.average(blength)
        
        openings = rec1.get_openings_burst_list()
        #print('Average number of openings= {0:.9f}'.format(np.average(openings)))
        p_tcrit_ave_openings[tcrit_count] = np.average(openings)

        tcrit_count=tcrit_count+1
    
    
    tcrit=test_tcrits[0]
    
    tres_count=0 
    # alter tres holding tcrit constant
    for tres in test_treses:
        ioffset, nint, calfac, header = dcio.scn_read_header(filename)
        tint, iampl, iprops = dcio.scn_read_data(filename, ioffset, nint, calfac)
        rec1 = dataset.TimeSeries(filename, header, tint, iampl, iprops)
        rec1.impose_resolution(tres)
        rec1.get_open_shut_periods()
        rec1.get_bursts(tcrit)
        
        #print('\nNumber of resolved intervals = {0:d}'.format(len(rec1.rtint)))
        p_tres_resolved[tres_count] = len(rec1.rtint)
        
        #print('\nNumber of bursts = {0:d}'.format(len(rec1.bursts)))
        p_tres_tests[tres_count]=len(rec1.bursts)
        
        blength = rec1.get_burst_length_list()
        #print('Average length = {0:.9f} millisec'.format(np.average(blength)))
        p_tres_ave_length[tres_count] = np.average(blength)
        
        openings = rec1.get_openings_burst_list()
        #print('Average number of openings= {0:.9f}'.format(np.average(openings)))
        p_tres_ave_openings[tres_count] = np.average(openings)
        
        tres_count=tres_count+1
    
    data['p_tcrit_tests']=p_tcrit_tests
    data['p_tcrit_resolved']=p_tcrit_resolved
    data['p_tcrit_ave_length']=p_tcrit_ave_length
    data['p_tcrit_ave_openings']=p_tcrit_ave_openings
                
    data['p_tres_tests']=p_tres_tests
    data['p_tres_resolved']=p_tres_resolved
    data['p_tres_ave_length']=p_tres_ave_length
    data['p_tres_ave_openings']=p_tres_ave_openings
    
    sp.savemat(outfile,data)
    sys.stdout.write('Bursts generation finished\noutput saved to ' + outfile +'\n\n')    	

def simplex(mec,opts,outfile):
    sys.stdout.write('Generation of Simplex optimisation output starting\n')

    theta = mec.theta() 

    k = np.size(theta)
    likelihoods,simplex = optimize.simplex_make(np.log(theta), 10, scl.HJClik, opts)
    stpfac=10
    reffac=1.0
    extfac=2.0
    confac=0.5,
    shrfac=0.5
    resfac=10.0
    perfac=0.1,
    errpar=1e-3
    errfunc=1e-3
    func=scl.HJClik

    data={};
    data['p_make_likelihoods']=likelihoods
    data['p_make_simplex']=simplex

    sorted_likelihoods,sorted_simplex = optimize.simplex_sort(likelihoods,simplex)
    data['p_sorted_likelihoods']=sorted_likelihoods
    data['p_sorted_simplex']=sorted_simplex
    #convergence

    if (max(np.ravel(abs(sorted_simplex[1:] - sorted_simplex[0]))) <= errpar \
                    and max(abs(sorted_likelihoods[0] - sorted_likelihoods[1:])) <= errfunc):
        data['p_converge']=True
    else:    
        data['p_converge']=False


    #centre
    centre=np.sum(sorted_simplex[:-1,:], axis=0) / float(k)
    data['p_centre_point'] = centre

    #reflect
    reflect = centre + reffac * (centre - sorted_simplex[-1])
    freflect,reflect=func(reflect, opts)
    data['p_reflect_point'] = reflect
    data['p_reflect_lik'] = freflect

    #extend

    extend = centre + extfac * (reflect - centre)
    fextend,extend = func(extend, opts)
    data['p_extend_point'] = extend
    data['p_extend_lik'] = fextend


    #contract

    contract = centre + confac * (sorted_simplex[-1] - centre)
    fcontract, contract = func(contract, opts)
    data['p_contract_point'] = contract
    data['p_contract_lik'] = fcontract

    shrunk_simplex = np.copy(sorted_simplex) #sorted_simplex gets changed and assignment is assignment of references in numpy
    shrunk_likelihoods = np.copy(sorted_likelihoods)
    #shrink

    shrunk_likelihoods, shrunk_simplex = optimize.simplex_shrink(shrunk_likelihoods, shrunk_simplex, shrfac, func, opts)
    data['p_shrink_simplex'] = shrunk_simplex
    data['p_shrink_liks']  = shrunk_likelihoods


    restart=True
    if(restart):
        xout, fout, niter, neval = optimize.simplex(scl.HJClik,
            np.log(theta), args=opts, display=False)
        print ("\nFitting finished: %4d/%02d/%02d %02d:%02d:%02d\n"
                %time.localtime()[0:6])

        restart=False
        data['p_function_value'] = fout
        data['p_min_parameters'] = xout

    sp.savemat(outfile,data)
    sys.stdout.write('Simplex optimisation generation finished\noutput saved to ' + outfile +'\n\n')


def mr(mec,opts,outfile):
    data={}
    p_rates=np.zeros((1,len(mec.Rates)))
    p_withconstraints=np.zeros((1,len(mec.Rates)))

    # PREPARE RATE CONSTANTS - this is the setup from fitdemo.py
    # Fixed rates.
    mec.update_mr()
    mec.update_constrains()
    p_withconstraints[0,] = mec.unit_rates()
    p_rates[0,] = mec.unit_rates()

    data['p_withconstraints']=p_withconstraints

    sp.savemat(outfile,data)
    sys.stdout.write('Function generation finished\noutput saved to ' + outfile +'\n\n')



def exact_likelihood_value(mec,opts,outfile):

    sys.stdout.write('Generation of exact likelihood value\n')
    #run through a simplex fit and save the values in the q_matrix
    p_sim,_ = scl.HJClik(np.log(mec.theta()),opts)
    data={}
    data['p_sim']=p_sim
    sp.savemat(outfile,data)
    sys.stdout.write(str(p_sim))
    sys.stdout.write('Exact Likelihood calculation finished\noutput saved to ' + outfile + '\n\n')




def exact_likelihood_functions(mec,opts,outfile):

    sys.stdout.write('Generation of exact likelihood function output starting\n')

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


    sp.savemat(outfile,data)
    sys.stdout.write('Exact Likelihood function generation finished\noutput saved to ' + outfile + '\n\n')


def exact_likelihood_matrices(mec,opts,matrix_outfile,asy_outfile):

    sys.stdout.write('Generation of exact likelihood matrix constant and asymptotic output starting\n')

    tcrit = opts['tcrit']
    tres = opts['tres']

    #sys.stdout.write('Spectral expansion of -Q\n\n')
    eigvals,specQ = qml.eigs(-mec.Q)

    #sys.stdout.write('Spectral expansion of Q_AA\n\n')
    eigvals,specA = qml.eigs(mec.QAA)

    #sys.stdout.write('Generating G_AF and G_FA matricies\n\n')
    GAF, GFA = qml.iGs(mec.Q, mec.kA, mec.kF)

    #sys.stdout.write('Generating exponentiated matrices\n\n')
    expQFF = qml.expQt(mec.QFF, tres)
    expQAA = qml.expQt(mec.QAA, tres)

    #sys.stdout.write('Generating eG_AF, eG_FA matrices\n\n')
    eGAF = qml.eGs(GAF, GFA, mec.kA, mec.kF, expQFF)
    eGFA = qml.eGs(GFA, GAF, mec.kF, mec.kA, expQAA)

    #sys.stdout.write('Generating phi matrices\n\n')
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
    sp.savemat(matrix_outfile,data)

    sys.stdout.write('Matrix Constants generation finished\noutput saved to ' + matrix_outfile + '\n\n')

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
    sp.savemat(asy_outfile,asymptotic_data)

    sys.stdout.write('Asymptotic density generation finished\noutput saved to ' + asy_outfile + '\n\n')

