#!/usr/bin/python

import xml.dom.minidom as minidom
import scipy.io as sp
import numpy as np 
import pickle
from optparse import OptionParser
from os import path,system,walk,makedirs,remove
import sys

DIRNAME=path.dirname(__file__)

def fileString(root,model,paramSet,fileFormat):
    return root + "_" + model + "_" + paramSet + fileFormat 

def getText(nodelist):
    rc = []
     
    for node in nodelist:
        if node.nodeType == node.TEXT_NODE:
            rc.append(node.data)
    return ''.join(rc)

def getElementText(elementNode):
    return getText(elementNode[0].childNodes)
    #" ".join(t.nodeValue for t in elementNode[0].childNodes if t.nodeType == t.TEXT_NODE)


def setupTests(dom,testDirectory):
    """ Clears out the test directory for previous results  """
    print "Setting up " + testDirectory + "\n"
    
    if not path.exists(testDirectory):
        makedirs(testDirectory)

    for root,dirs,files in walk(testDirectory):
        for f in files:
            print "deleting" + f +"\n"
            remove(path.join(root,f))
 
    print "Test directory setup complete\n" 
