#!/usr/bin/env python3
#Author: UCaN Lab UMB
#Umass Boston, MA,USA

import zmq
import time
import numpy as np

#################################################################
# Functions
#################################################################
def zmq_measure(my_socket,print_measurements):
	latest_msg = None  # Initialize latest_msg to None
	try:
		while my_socket.poll(0):  # As long as there are messages in the buffer
			latest_msg = my_socket.recv(flags=zmq.NOBLOCK)  # Overwrite latest_msg with the new message
	except zmq.Again:
		pass  # Buffer is now drained, and latest_msg contains the last message
	
	if latest_msg is not None:  # If we got at least one message
		measurement = np.frombuffer(latest_msg, dtype=np.float32, count=-1)		
		if print_measurements == 1: 
			print(f"  Measurements: {measurement}")
		measurement = np.average(measurement)
	else:
		measurement = 0
		print("No message received")


	return measurement
	
#################################################################
# Script Configuration
#################################################################
PRINT_MEASUREMENTS = 0

zmq_address = '127.0.0.1'
zmq_port = '55555'

# Simulation Parameters
n_iter     = 3    # Number of iterations per scenario
t_pause    = 2    # Delay time (sec) between iterations
init_pause = 1    # Delay time (sec) to allow for ZMQ setup


#################################################################
# Setup
#################################################################
# Setup ZMQ
context = zmq.Context()
socket1 = context.socket(zmq.SUB)

socket1.connect('tcp://' + zmq_address + ':' + zmq_port)
socket1.setsockopt(zmq.SUBSCRIBE, b'')



#################################################################
# Execution (MAIN)
#################################################################

# Initial pause to make sure ZMQ is setup
time.sleep(init_pause)

for iter in range(n_iter):
	print("Iteration ", iter)
	P_avg = zmq_measure(socket1,PRINT_MEASUREMENTS)
	print(f"  Average Power: {P_avg:.4}")
	time.sleep(t_pause)


