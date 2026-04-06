#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from xmlrpc.client import ServerProxy
import sys, getopt
import time



def main(argv):

   node_id      = '101'
   carrier_freq = ''
   rx_gain      = ''
   
   c_set = 0
   g_set = 0
   debug = 0
   
   try:
      opts, args = getopt.getopt(argv,"hn:c:g:d",["node_id=","carrier_freq=","rx_gain="])
   except getopt.GetoptError:
      print ('  test.py -n <node ID> -c <carrier frequency> -g <rx gain>')
      sys.exit(2)   
   for opt, arg in opts:
      if opt == '-h':
         print ('  test.py -n <node ID> -c <carrier frequency> -g <rx gain>')
         sys.exit()
      elif opt in ("-n", "--node_id"):
         node_id = arg
      elif opt in ("-c", "--carrier_freq"):
         carrier_freq = arg
         c_set = 1
      elif opt in ("-g", "--rx_gain"):
         rx_gain = arg
         g_set = 1
      elif opt in ("-d", "--debug"):
         debug = 1
         
   if debug == 1:
      print ('Node ID:           ', node_id)
      print ('Carrier Frequency: ', carrier_freq)
      print ('Rx Gain:           ', tx_gain)
   
   xmlrpc_control_client = ServerProxy('http://'+'10.1.1.'+node_id+':8081')


   if c_set == 1:
      xmlrpc_control_client.set_fc(int(carrier_freq))

   if g_set == 1:
      xmlrpc_control_client.set_rx_gain(int(rx_gain))
   
   

if __name__ == "__main__":
   main(sys.argv[1:])
