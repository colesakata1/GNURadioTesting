#!/bin/bash

#echo "Starting local flowgraph for observation..."
#python3 Test/GRC_Files/Rx_GUI.py &
#sleep 7

echo "Confirming Node Connections..."
bash Configuration/verify_nodes.sh -r 101,109
sleep 2

cd Test

echo "Initiating remote Tx nodes..."
echo "-----------------------------"
bash sdr_tx_start.sh -l 102,103,104,109 -a 0.5e6,1e6,0.5e6,0.5e6 -c 912e6,912e6,912e6,912e6 -f 1e5,1e5,1e5,1e5 -m 0.1,0.1,0.1,0.1 -g 20,30,30,40 -s 0
sleep 10

echo ""
echo "Initiating remote Rx nodes..."
echo "-----------------------------"
bash sdr_rx_start.sh -l 101,105,106,107,108 -a 1.5e6,1.5e6,1.5e6,1.5e6,1.5e6 -c 914e6,914e6,914e6,914e6,914e6 -g 40,40,40,40,40
sleep 10

echo ""
echo "Initial Measurements"
echo "-----------------------------"
bash sdr_get_data.sh -l 101,105,106,107,108 -c 912000000,915000000,917000000

echo ""
echo "OFDM Transmission Enabled, 102..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 102 -s 2 -g 40
sleep 3

bash sdr_get_data.sh -l 101,105,106,107,108 -c 912000000,915000000,917000000


echo ""
echo "OFDM Transmission Enabled, 103..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 102,103 -s 0,2
sleep 3

bash sdr_get_data.sh -l 101,105,106,107,108 -c 912000000,915000000,917000000

echo ""
echo "OFDM Transmission Enabled, 109..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 103,109 -s 0,2
sleep 3

bash sdr_get_data.sh -l 101,105,106,107,108 -c 912000000,915000000,917000000

echo ""
echo "OFDM Transmission Enabled, 109, fc=917e6..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 103,109 -s 0,2 -c 912000000,917000000
sleep 3

bash sdr_get_data.sh -l 101,105,106,107,108 -c 912000000,915000000,917000000



echo ""
echo "Disable All..."
bash sdr_tx_update.sh -l 102,103,104,109 -s 0,0,0,0 -g 0,0,0,0
sleep 2

