#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from xmlrpc.client import ServerProxy
import sys, getopt
import time



def main(argv):

   node_id      = '101'
   carrier_freq = ''
   tone_freq    = ''
   ofdm_scale   = ''
   tx_gain      = ''
   sig_type     = ''
   
   c_set = 0
   f_set = 0
   m_set = 0
   g_set = 0
   s_set = 0
   debug = 0
   
   try:
      opts, args = getopt.getopt(argv,"hn:c:f:m:g:s:d",["node_id=","carrier_freq=","tone_freq=","ofdm_scale=","tx_gain=","sig_type="])
   except getopt.GetoptError:
      print ('  test.py -n <node ID> -c <carrier frequency> -f <tone freq> -m <ofdm scale> -g <tx gain> -s <sig type>')
      sys.exit(2)   
   for opt, arg in opts:
      if opt == '-h':
         print ('  test.py -n <node ID> -c <carrier frequency> -f <tone freq> -m <ofdm scale> -g <tx gain> -s <sig type>')
         sys.exit()
      elif opt in ("-n", "--node_id"):
         node_id = arg
      elif opt in ("-c", "--carrier_freq"):
         carrier_freq = arg
         c_set = 1
      elif opt in ("-f", "--tone_freq"):
         tone_freq = arg
         f_set = 1
      elif opt in ("-m", "--ofdm_scale"):
         ofdm_scale = arg
         m_set = 1
      elif opt in ("-g", "--tx_gain"):
         tx_gain = arg
         g_set = 1
      elif opt in ("-s", "--sig_type"):
         sig_type = arg
         s_set = 1
      elif opt in ("-d", "--debug"):
         debug = 1
         
   if debug == 1:
      print ('Node ID:           ', node_id)
      print ('Carrier Frequency: ', carrier_freq)
      print ('Tone Frequency:    ', tone_freq)
      print ('OFDM Scale:        ', ofdm_scale)
      print ('Tx Gain:           ', tx_gain)
      print ('Signal Type:       ', sig_type)
   
   xmlrpc_control_client = ServerProxy('http://'+'10.1.1.'+node_id+':8080')


   if c_set == 1:
      xmlrpc_control_client.set_fc(int(carrier_freq))

   if f_set == 1:
      xmlrpc_control_client.set_tone_freq(int(tone_freq))

   if m_set == 1:
      xmlrpc_control_client.set_ofdm_scale(float(ofdm_scale))

   if g_set == 1:
      xmlrpc_control_client.set_tx_gain(int(tx_gain))

   if s_set == 1:
      xmlrpc_control_client.set_sig_select(int(sig_type))
   
   
   

if __name__ == "__main__":
   main(sys.argv[1:])
