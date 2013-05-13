#!/usr/bin/python

import xml.dom.minidom as minidom
import scipy.io as sp
import numpy as np 
from optparse import OptionParser
from os import path
import sys
import xmlUtils

def usage():
	print "Generates a mat files from the TestCases file for a specific mechanism and parameter set\n"
	print "for model fitting or examinatio within the MATLAB MarkovModels suite."

def createMat(dom,projectDir, modelId,paramSetId):

    resultsDir = path.join(projectDir,"Tools/Mechanisms")
    print resultsDir
    models = dom.getElementsByTagName("Model")   
    params  = {}; 

    for model in models:
        for attrName, attrValue in model.attributes.items():
            if (attrName == "id"):
                print attrName, attrValue
                if(int(attrValue) == modelId):
                    #we have the model now lets find the param set
                    modelName=model.getElementsByTagName("name")
                    for node in modelName:
                        params['model'] = xmlUtils.getText(node.childNodes)
                    
                    params['mechanismfilepath'] = projectDir+ "/Testing" + xmlUtils.getElementText(model.getElementsByTagName("mechanismfilepath"))
                    
                    for node in model.getElementsByTagName("mechanismfilepath"):
                        #iterate through the parameter sets for the specific model
                        if node.nodeType == node.ELEMENT_NODE:                 	
                            params['mecfileid'] = float(node.getAttribute("mec_id"))
                            print "Mec file id found" + node.getAttribute("mec_id")
                    
                    #params['mecfileid'] = float(model.getElementsByTagName("mechanismfilepath").getAttribute("mec_id"))
                    parameterSweeps = model.getElementsByTagName("ParameterSweep")
                    
                    for node in parameterSweeps:
                        parameterValues = node.childNodes
                        for paramSet in parameterValues:
                            if paramSet.nodeType == paramSet.ELEMENT_NODE:
                                 if (int(paramSet.getAttribute("set")) == paramSetId):
                                     
                                     #we have found the parameter set we want
                                     params['setNumber'] = paramSetId
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

                                     mat_file = path.join(resultsDir, xmlUtils.fileString("model_params" , params['model'] , str(paramSetId) ,".mat"))
                                     sp.savemat(mat_file,params)
                                     print "Param file for model " + params['model'] + " generated\n"

def main():
    usage()
    parser = OptionParser()
    parser.add_option("-f", "--file", dest="filename",action="store", type="string",
                  help="read in test variables from xml FILENAME", metavar="FILE")

    parser.add_option("-m","--model_id",action="store", type="int",dest="model_id",help="model id to select model from xml file")
    parser.add_option("-p","--param_id",dest="param_id",action="store", type="int",help="param_id to select parameter values from xml file")
    
    (options, args) = parser.parse_args()

    xmlControlFile = options.filename 
    

    if  xmlControlFile is not None and path.isfile(xmlControlFile):
        print "XML test file specfied is " + xmlControlFile + '\n'
        print xmlControlFile + " is an existing file. Attempting to parse as XML\n\n"
        currentPath = path.abspath(path.dirname(__file__))
        projectPath = path.join(currentPath,"..")
        print projectPath,currentPath
        dom=minidom.parse(xmlControlFile)
        createMat(dom,projectPath, options.model_id,options.param_id)

    else:
        print parser.print_help()
        
        
if __name__ == "__main__":
    main()