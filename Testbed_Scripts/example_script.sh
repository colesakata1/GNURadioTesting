#!/bin/bash

#echo "Starting local flowgraph for observation..."
#python3 Test/GRC_Files/Rx_GUI.py &
#sleep 7

echo "Confirming Node Connections..."
bash Configuration/verify_nodes.sh -r 101,103
sleep 2

cd Test

echo "Initiating remote nodes..."
bash sdr_tx_start.sh -l 101,102,103 -a 1e6,2e6,1e6 -c 913e6,915e6,917e6 -f 1e5,1e5,1e5 -g 0,0,0 -s 0
sleep 10

echo "Tone Transmission Enabled..."
bash sdr_tx_update.sh -l 101,102,103 -s 1,1,1 -g 30,30,30
sleep 3


echo "Tone Transmission Disabled..."
bash sdr_tx_update.sh -l 101,102,103 -s 0,0,0 -g 0,0,0
sleep 3

echo "OFDM Transmission Enabled, Tx 1..."
bash sdr_tx_update.sh -l 101,102,103 -s 2,0,0 -g 40,0,0
sleep 4

echo "OFDM Transmission Enabled, Tx 2..."
bash sdr_tx_update.sh -l 101,102,103 -s 0,2,0 -g 0,40,0
sleep 4

echo "OFDM Transmission Enabled, Tx 3..."
bash sdr_tx_update.sh -l 101,102,103 -s 0,0,2 -g 0,0,40
sleep 4


echo "Tx 3 Carrier Sweep..."
bash sdr_tx_update.sh -l 101,102,103 -s 0,0,2 -g 0,0,40 -c 913000000,915000000,913000000
sleep 4

bash sdr_tx_update.sh -l 101,102,103 -s 0,0,2 -g 0,0,40 -c 913000000,915000000,915000000
sleep 4

bash sdr_tx_update.sh -l 101,102,103 -s 0,0,2 -g 0,0,40 -c 913000000,915000000,917000000
sleep 4

echo "Disable All..."
bash sdr_tx_update.sh -l 101,102,103 -s 0,0,0 -g 0,0,0
sleep 2

