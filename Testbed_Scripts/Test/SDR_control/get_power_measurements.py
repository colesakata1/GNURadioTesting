#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#Author: UCaN Lab UMB
#Umass Boston, MA,USA

from xmlrpc.client import ServerProxy
import sys, getopt
import numpy as np
import time
import zmq
import csv

#################################################################
# Functions
#################################################################
def zmq_measure(my_socket):
	latest_msg = None  # Initialize latest_msg to None
	try:
		while my_socket.poll(0):  # As long as there are messages in the buffer
			latest_msg = my_socket.recv(flags=zmq.NOBLOCK)  # Overwrite latest_msg with the new message
	except zmq.Again:
		pass  # Buffer is now drained, and latest_msg contains the last message
	
	if latest_msg is not None:  # If we got at least one message
		measurement = np.frombuffer(latest_msg, dtype=np.float32, count=-1)
		measurement = np.average(measurement)
		#print(f"Noise Power: {P_noise}")
	else:
		measurement = 0
		print("No message received")


	return measurement



#################################################################
# MAIN
#################################################################
def main(argv):

   ############################
   # Script Configuration     #
   ############################
   node_id      = '101'
   reps         = 1
   delay        = 2
   debug = 0
   
   try:
      opts, args = getopt.getopt(argv,"hn:r:t:d",["node_id=","repetitions=","time_delay="])
   except getopt.GetoptError:
      print ('  get_power_measurements.py -n <node ID> -r <repetitions> -t <time delay> ')
      sys.exit(2)   
   for opt, arg in opts:
      if opt == '-h':
         print ('  get_power_measurements.py -n <node ID> -r <repetitions> -t <time delay> ')
         sys.exit()
      elif opt in ("-n", "--node_id"):
         node_id = arg
      elif opt in ("-r", "--repetitions"):
         reps = arg
      elif opt in ("-t", "--time_delay"):
         delay = arg
      elif opt in ("-d", "--debug"):
         debug = 1
         
   ############################
   # DEBUG                    #
   ############################
   if debug == 1:
      print ('Node ID:           ', node_id)
   

   ############################
   # Setup                    #
   ############################
   # Setup ZMQ
   context = zmq.Context()
   socket1 = context.socket(zmq.SUB)
   socket1.connect('tcp://10.1.1.'+node_id+':55555')
   socket1.setsockopt(zmq.SUBSCRIBE, b'')

   # Sleep to allow ZMQ connection to establish and data to be collected
   time.sleep(1)

   ############################
   # Measurement     #
   ############################
   for iter in range(int(reps)):
      # Power Measurements
      P_measure = zmq_measure(socket1)
      print(f"{P_measure}")
      #print(f"Power Measurement: {P_measure}")
      time.sleep(int(delay))

   
   
   

if __name__ == "__main__":
   main(sys.argv[1:])



