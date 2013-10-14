#!/usr/bin/python
"""
Maximum likelihood fit demo.
"""
import argparse
import sys
import time
import math
import numpy as np
import cProfile
from scipy.optimize import minimize

from dcpyps import dcio
from dcpyps import dataset
from dcpyps import scalcslib as scl
from dcpyps import mechanism

from dcprogs.likelihood import Log10Likelihood

def main(argv=None):

    if argv is None:
        argv=sys.argv[1:]

    p = argparse.ArgumentParser(description="Example of using argparse")

    p.add_argument('--filename', action='store', default='./Samples/Simulations/20000/test_1.scn', help="first word")
    p.add_argument('--tcrit', action='store', default='0.0035', help="t_crit")

    p.add_argument('--tres', action='store', default='0.000025', help="t_res")

    p.add_argument('--conc', action='store', default='3e-8', help="conc")
    # Parse command line arguments
    args = p.parse_args(argv)

    print "Running dc-pyps tests for filename = " + args.filename, "and t_crit " ,  args.tcrit, "\n"

    # LOAD MECHANISM USED IN COLQUHOUN et al 2003.
    mecfn = "./Testing/demomec.mec"

    filename = args.filename
    tcrit = float(args.tcrit)

    version, meclist, max_mecnum = dcio.mec_get_list(mecfn)
    mec = dcio.mec_load(mecfn, meclist[1][0])
    tres = float(args.tres)
    conc = float(args.conc)

    # LOAD DATA.
    ioffset, nint, calfac, header = dcio.scn_read_header(filename)
    tint, iampl, iprops = dcio.scn_read_data(filename, ioffset, nint, calfac)
    rec1 = dataset.SCRecord(filename, header, tint, iampl, iprops)
    # Impose resolution, get open/shut times and bursts.
    rec1.impose_resolution(tres)
    rec1.get_open_shut_periods()
    rec1.get_bursts(tcrit)
    print('\nNumber of resolved intervals = {0:d}'.format(len(rec1.rtint)))
    print('\nNumber of bursts = {0:d}'.format(len(rec1.bursts)))
    blength = rec1.get_burst_length_list()
    print('Average length = {0:.9f} ms'.format(np.average(blength)*1000))
    print('Range: {0:.3f}'.format(min(blength)*1000) +
            ' to {0:.3f} millisec'.format(max(blength)*1000))
    openings = rec1.get_openings_burst_list()
    print('Average number of openings= {0:.9f}'.format(np.average(openings)))

    # PREPARE RATE CONSTANTS.
    # Fixed rates.
    fixed = np.array([False, False, False, False, False, False, False, True,
        False, False, False, False, False, False])
    if fixed.size == len(mec.Rates):
        for i in range(len(mec.Rates)):
            mec.Rates[i].fixed = fixed[i]

    # Constrained rates.
    mec.Rates[6].is_constrained = True
    mec.Rates[6].constrain_func = mechanism.constrain_rate_multiple
    mec.Rates[6].constrain_args = [10, 1]
    mec.Rates[8].is_constrained = True
    mec.Rates[8].constrain_func = mechanism.constrain_rate_multiple
    mec.Rates[8].constrain_args = [12, 1]
    mec.Rates[9].is_constrained = True
    mec.Rates[9].constrain_func = mechanism.constrain_rate_multiple
    mec.Rates[9].constrain_args = [13, 1]

    mec.Rates[11].mr=True

    opts = {}
    opts['mec'] = mec
    opts['conc'] = conc
    opts['tres'] = tres
    opts['tcrit'] = tcrit
    opts['isCHS'] = True
    opts['data'] = rec1.bursts
    # Initial guesses. Now using rate constants from numerical example.
    #rates = np.log(mec.unit_rates())
    #mec.set_rateconstants(np.exp(rates))
    #use rates from Guess 1, 2003 paper
    rates = [ 1500, 50000, 13000, 50, 15000, 10, 6000,100000000, 5000, 100000000,6000,100000000, 5000, 100000000 ]
    mec.set_rateconstants(rates)
    theta = mec.theta()
    mec.update_constrains()
    mec.update_mr()
    mec.theta_unsqueeze(theta)
    mec.set_eff('c', opts['conc'])
        # Initial guesses. Now using rate constants from numerical example.l
    np.set_printoptions(precision=15)
    print("Q-matrix\n")
    print(mec.Q)

    bursts = rec1.bursts
    likelihood = Log10Likelihood(bursts, mec.kA, tres, tcrit)

    def dcprogslik1(x, args=None):
        mec.theta_unsqueeze(x)
        mec.set_eff('c', opts['conc'])
        return -likelihood(mec.Q) * math.log(10)


    print ("\nStarting likelihood = {0:.16f}".format(dcprogslik1(theta)))


if __name__=="__main__":
    sys.exit(main(sys.argv[1:]))
