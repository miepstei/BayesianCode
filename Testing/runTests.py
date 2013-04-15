#!/usr/bin/python

from xml.dom.minidom import parse,parseString
from optparse import OptionParser
from os import path

def usage():
    print "The script is used to parse and execute the tests in the Markov Model Matlab/C code\n"
    print 

def printTests(dom):
    slides = dom.getElementsByTagName("slide")


usage()
parser = OptionParser()
parser.add_option("-f", "--file", dest="filename",
                  help="read in test variables from xml FILE", metavar="FILE")

(options, args) = parser.parse_args()

xmlControlFile = options.filename 
print "XML test file specfied is " + xmlControlFile + '\n'

if path.isfile(xmlControlFile):
    print xmlControlFile + " is an existing file. Attempting to parse as XML\n\n"
    dom=parse(xmlControlFile)
    print dom
    handleSlideshow(dom) 

else:
    print parser.help()



