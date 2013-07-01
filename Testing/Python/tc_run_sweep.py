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
import pickle

dirname=os.path.dirname(__file__)
fn = os.path.join(dirname, 'dcPyps')
sys.path.insert(0, fn)
print dirname
import dcpyps_tests as dcp

def usage():
    sys.stdout.write('*************tc_exact_likelihoods.py - unit test script **************\n\n')

def main(py_file):
   
    params = pickle.load(open(py_file,"rb"))
    print "Loading " + py_file + "\n"
    
    if params['model'] in ("CH82","CS 1985"): 
        #setup parametersi and mechanism
        tres = params['tres']
        tcrit = params['tcrit'] #separation of time between bursts is 4000 \mus or 4ms

        #setup data
        filename = params['DataSet']
        ioffset, nint, calfac, header = dcio.scn_read_header(filename)
        tint, iampl, iprops = dcio.scn_read_data(filename, ioffset, nint, calfac)
        rec1 = dataset.SCRecord(filename, header, tint, iampl, iprops)

        # Impose resolution, get open/shut times and bursts.
        rec1.impose_resolution(tres*1000)
        rec1.get_open_shut_periods()
        rec1.get_bursts(tcrit*1000)
 
        #print burst infoi
        print('\nNumber of resolved intervals = {0:d}'.format(len(rec1.rtint)))
        print('\nNumber of bursts = {0:d}'.format(len(rec1.bursts)))

        opts = {}
        opts['conc'] = params['concentration']
        opts['tres'] = tres
        opts['tcrit'] = tcrit
        opts['isCHS'] = True
        opts['data'] = rec1.bursts
        opts['TestTres'] = params['TestTres']
        opts['TestTcrit'] = params['TestTcrit']
        opts['DataSet'] = params['DataSet']

        if params['model'] == "CH82":

            rates = np.log([params['p1'], params['p2'], params['p3'], params['p4'], params['p5'], params['p6'], params['p7'], params['p8'], params['p9'], params['p10']])
        
            mec = samples.CH82()
            mec.set_eff('c', params['concentration'])
            mec.set_rateconstants(np.exp(rates))
            #this needs to be called explicitly to update the Q-matrix
            mec.update_submat()
        
            #tc_likelihood_values.main(mec,opts,params['dcpLikelihoodValuesFile'])
            #setup mechanism to test enforcement of contraints
            fixed = np.array([False, False, False, False, False, False, False, True, False, False])
 
            if fixed.size == len(mec.Rates):
                for i in range(len(mec.Rates)):
                    mec.Rates[i].fixed = fixed[i]
        
            # Constrained rates.
            mec.Rates[5].is_constrained = True
            mec.Rates[5].constrain_func = mechanism.constrain_rate_multiple
            mec.Rates[5].constrain_args = [4, 2]
            mec.Rates[6].is_constrained = True
            mec.Rates[6].constrain_func = mechanism.constrain_rate_multiple
            mec.Rates[6].constrain_args = [8, 2]
            mec.update_constrains()
            mec.update_mr()
  
            opts['mec'] = mec
        elif params['model'] == "CS 1985":
            rates = np.log([params['p1'], params['p2'], params['p3'], params['p4'], params['p5'], params['p6'], params['p7'], params['p8'], params['p9'], params['p10'],params['p11'],params['p12'],params['p13'],params['p14']])
            version, meclist, max_mecnum = dcio.mec_get_list(params['mechanismfilepath'])
            mec = dcio.mec_load(params['mechanismfilepath'], meclist[1][0])
            mec.set_eff('c', params['concentration'])
            mec.set_rateconstants(np.exp(rates))
            fixed = np.array([False, False, False, False, False, False, False, False, False, False, False, False, False,False])
            if fixed.size == len(mec.Rates):
                for i in range(len(mec.Rates)):
                    mec.Rates[i].fixed = fixed[i]

            # Constrained rates.
            mec.Rates[6].is_constrained = True
            mec.Rates[6].constrain_func = mechanism.constrain_rate_multiple
            mec.Rates[6].constrain_args = [10, 1]

            mec.Rates[7].is_constrained = True
            mec.Rates[7].constrain_func = mechanism.constrain_rate_multiple
            mec.Rates[7].constrain_args = [11, 1]

            mec.Rates[8].is_constrained = True
            mec.Rates[8].constrain_func = mechanism.constrain_rate_multiple
            mec.Rates[8].constrain_args = [12, 1]
    
            mec.Rates[9].is_constrained = True
            mec.Rates[9].constrain_func = mechanism.constrain_rate_multiple
            mec.Rates[9].constrain_args = [13, 1]

            mec.update_submat()
            opts['mec']=mec
    else:
        print "Unknown model \"" + params['model'] + "\" Test Case Yet to be implemented\n"


    dcp.exact_likelihood_functions(mec,opts,params['dcpFunctionsResultsFile'])
    dcp.exact_likelihood_matrices(mec,opts,params['dcpMatrixResultsFile'],params['dcpAsymptoticResultsFile'])
    dcp.mr(mec,opts,params['dcpMrResultsFile'])
    dcp.exact_likelihood_value(mec,opts,params['dcpLikelihoodsResultsFile'])
    dcp.bursts(opts,params['dcpBurstsResultsFile'])
    #dcp.simplex(mec,opts,params['dcpSimplexResultsFile'])
    sys.stdout.write('Test for model ' + params['model'] + ' with parameters finished\n\n')

