#!/usr/bin/python

import sys
import os
import time
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
    sys.stdout.write('Test script for testing Simplex fitting\n')
    sys.stdout.write('Uses CH82 mechanism for generating relevent Q-matrices and likelihoods as appropriate\n')
    sys.stdout.write('Writes to user specified results file for comparison with Matlab ME programs\n\n')
    sys.stdout.write('**********************************************************************\n\n')



def main(mec,opts):
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

    sp.savemat('TestData/simplex.mat',data)
    sys.stdout.write('Simplex generation finished\noutput saved to TestData/simplex.mat\n\n')
