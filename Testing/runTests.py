#!/usr/bin/python

import xml.dom.minidom as minidom
import scipy.io as sp
import numpy as np 
import pickle
from optparse import OptionParser
from os import path,system
import sys

DIRNAME=path.dirname(__file__)
import tc_run_sweep 
import xmlUtils

def usage():
    print "The script is used to parse and execute the tests in the Markov Model Matlab/C code\n"


                                     
def runTests(dom,projectDir):

    #we want to set up paths for the relevent directories to store results and access files
    resultsDir = path.join(projectDir,xmlUtils.getElementText(dom.getElementsByTagName("TestOutputDir")))
    dataDir = path.join(projectDir,xmlUtils.getElementText(dom.getElementsByTagName("TestDataDir")))
    
    #get the local path to the MATLAB instance
    matNode=dom.getElementsByTagName("MatlabExecutable")
    matExe = xmlUtils.getText(matNode[0].childNodes)

    #iterate through the test cases in the models
    models = dom.getElementsByTagName("Model")
    for model in models:
          modelName=model.getElementsByTagName("name")
          params  = {};
          for node in modelName:
              params['model'] = xmlUtils.getText(node.childNodes)
          
          modelTestsEnabled = xmlUtils.getElementText(model.getElementsByTagName("enabled"))
          params['mechanismfilepath'] = projectDir+xmlUtils.getElementText(model.getElementsByTagName("mechanismfilepath"))
          params['epsilon'] = float(xmlUtils.getElementText(model.getElementsByTagName("epsilon")))
          if modelTestsEnabled == "True":
              print "Testing model: " + params['model'] +  "\n\n"
              testDataSet = path.join(dataDir,xmlUtils.getElementText(model.getElementsByTagName("data_set")))
              params['data_set'] = testDataSet
              parameterSweeps = model.getElementsByTagName("ParameterSweep")
              print "PARAMETER SWEEPS " + str(len (parameterSweeps))
              for node in parameterSweeps:
                  parameterValues = node.childNodes
                  for paramSet in parameterValues:
                      #iterate through the parameter sets for the specific model
                      if paramSet.nodeType == paramSet.ELEMENT_NODE:
                          # lets set up the parameters for this model
                          print paramSet
                          setNumber = paramSet.getAttribute("set")
                          print "Parameter Sweep Set " + setNumber
                          params['setNumber'] = setNumber

                         
                          #file locations for python results
                          for filename in ('AsymptoticResultsFile','MatrixResultsFile','MrResultsFile','FunctionsResultsFile','LikelihoodsResultsFile','SimplexResultsFile'):
                               params['dcp' + filename] = path.join(resultsDir,xmlUtils.fileString('dcp' + filename,params['model'],setNumber,'.mat'))
                               params['mat' + filename] = path.join(resultsDir,xmlUtils.fileString('mat' + filename    ,params['model'],setNumber,'.mat'))

                          params['matSetupResultsFile'] = path.join(resultsDir,xmlUtils.fileString('matlab_setup',params['model'],setNumber,'.mat'))

                          #model parameters
                          concentration = paramSet.getElementsByTagName("concentration")
                          params['concentration'] = float(concentration[0].firstChild.data)
                          tcrit = paramSet.getElementsByTagName("tcrit")
                          params['tcrit'] = float(tcrit[0].firstChild.data)
                          tres = paramSet.getElementsByTagName("tres")
                          params['tres'] = float(tres[0].firstChild.data)
                          parameters = paramSet.getElementsByTagName("parameter")
                          
                          for parameter in parameters:
                              p_id = 'p' + parameter.getAttribute("id")
                              p_name = parameter.getAttribute("name")
                              p_value = parameter.firstChild.data
                              params[p_id] = float(p_value)

                          #Save the parameters as pkl and mat files
                          py_file = path.join(resultsDir, xmlUtils.fileString("python_params" , params['model'] , setNumber,".pkl"))
                          pkl_handle = open(py_file,"w")
                          pickle.dump(params,pkl_handle)
                          pkl_handle.close()

                          mat_file = path.join(resultsDir, xmlUtils.fileString("matlab_params" , params['model'] , setNumber,".mat"))
                          sp.savemat(mat_file,params)

                          #runs through the dc-pyps code with the model and parameters
                          tc_run_sweep.main(py_file)

                          #run through the MATLAB scripts which generates equivilent functions and tests output 
                          for matlabTestScript in ('TestCaseAsymptoticRoots','TestCaseExactLikelihoodSetup','TestCaseConstraints','TestCaseMissedEventsPdfs','TestCaseExactLikeihood','TestCaseVectorisedLikelihood'): 
                              executable = "try %s(\'%s\',\'%s\'),quit; catch err; disp('[ERROR]: in evaluating %s'); disp(err);,quit; end" % (matlabTestScript,mat_file,'false',matlabTestScript)
                              print "Executing MATLAB test " + executable + "\n"
                              system(matExe + ' -r \"' + executable + "\"")
          else:
              print "Test cases for " + params['model'] + " are not enabled, skipping\n"

def main():
    usage()
    parser = OptionParser()
    parser.add_option("-f", "--file", dest="filename",
                  help="read in test variables from xml FILE", metavar="FILE")

    parser.add_option("-m","--model_id",dest="model_id",help="model id to select model from FILE", metavar="FILE")
    parser.add_option("-p","--param_id",dest="param_id",help="param_id to select parameter values from FILE", metavar="FILE")

    (options, args) = parser.parse_args()

    xmlControlFile = options.filename 

    if  xmlControlFile is not None and path.isfile(xmlControlFile):
        testspath = path.abspath(path.dirname(__file__))
        print xmlControlFile + " is an existing file. Attempting to parse as XML\n\n"
        dom=minidom.parse(xmlControlFile)
        #projectDirectory = xmlUtils.getElementText(dom.getElementsByTagName("AbsCodePath"))
        resultsDirectory = path.join(testspath, xmlUtils.getElementText(dom.getElementsByTagName("TestOutputDir")))
        
        #xmlUtils.setupTests(dom,resultsDirectory)
        runTests(dom,testspath) 
    else:
        print parser.print_help()

if __name__ == "__main__":
    main()

