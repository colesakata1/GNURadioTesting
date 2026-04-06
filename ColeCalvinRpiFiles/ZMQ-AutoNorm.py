import xmlrpc.client
from xmlrpc.client import ServerProxy
import time
import zmq
import numpy as np


rpc_addr = 'localhost'
rpc_port = '8080'
zmq_addr = '127.0.0.1'
zmq_port = '55555'

t_setup = 1
t_pause = 2
init_pause = 1

REAL_SINE = 0
COMPLEX_SINE = 1

FILTER_ENABLE = 0
FILTER_BYPASS = 1

NOISE_ENABLE = 0
NOISE_BYPASS = 1

COSINE_WAVE = 102
SQUARE_WAVE = 103

##XMLRPC SETUP
xc = ServerProxy('http://' + rpc_addr + ':' + rpc_port)

#ZMQ SETUP
context = zmq.Context()
socket1 = context.socket(zmq.SUB)

socket1.connect('tcp://' + zmq_addr + ':' + zmq_port)
socket1.setsockopt(zmq.SUBSCRIBE, b'')


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


PRINT_MEASUREMENTS = 0

#setup
xc.set_cmplx_select(REAL_SINE)
xc.set_sig_freq(100000)
xc.set_filter_select(NOISE_ENABLE)
xc.set_filter_select(FILTER_ENABLE)
xc.set_Sig_Type(COSINE_WAVE)

sigamp = 1

while True:
    P_avg = zmq_measure(socket1,PRINT_MEASUREMENTS)
    print(f"	Average Power: {P_avg:.4}")
    if (P_avg > 1.0):
        sigamp = sigamp * 0.9
        xc.set_sig_amp(sigamp)
        print(f"	Signal Amplitude Adjusted to: {sigamp:.4}")
    elif (P_avg < 0.5):
        sigamp = sigamp * 1.2
        xc.set_sig_amp(sigamp)
        print(f"	Signal Amplitude Adjusted to: {sigamp:.4}")
    time.sleep(t_pause)



