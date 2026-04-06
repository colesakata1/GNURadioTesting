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
bash sdr_tx_start.sh -l 102,103,104,109 -a 1e6,1e6,1e6,1e6 -c 912e6,914e6,916e6,918e6 -f 1e5,1e5,1e5,1e5 -m 0.1,0.1,0.1,0.1 -g 20,30,30,40 -s 0
sleep 10

echo ""
echo "Enable Tones..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 102,103,104,109 -s 1,1,1,1
sleep 3


echo ""
echo "Initiating remote Rx nodes..."
echo "-----------------------------"
bash sdr_rx_start.sh -l 101,105,106,107,108 -a 1.5e6,1.5e6,1.5e6,1.5e6,1.5e6 -c 912e6,912e6,912e6,912e6,912e6 -g 40,40,40,40,40
sleep 10

echo ""
echo "Disable Tones..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 102,103,104,109 -s 0,0,0,0
sleep 3



echo ""
echo "Initial Measurements"
echo "-----------------------------"
bash sdr_get_data.sh -l 101,105,106,107,108 -c 912000000,916000000

echo ""
echo "OFDM Transmission Enabled, 102, fc=912e6..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 102 -s 2 -c 912000000
sleep 3

bash sdr_get_data.sh -l 101,105,106,107,108 -c 912000000,916000000


echo ""
echo "OFDM Transmission Enabled, 103, fc=912e6..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 102,103 -s 0,2 -c 912000000,912000000
sleep 3

bash sdr_get_data.sh -l 101,105,106,107,108 -c 912000000,916000000

echo ""
echo "OFDM Transmission Enabled, 109, fc=912e6..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 103,109 -s 0,2 -c 912000000,912000000
sleep 3

bash sdr_get_data.sh -l 101,105,106,107,108 -c 912000000,916000000

echo ""
echo "OFDM Transmission Enabled, 109, fc=916e6..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 103,109 -s 0,2 -c 912000000,916000000
sleep 3

bash sdr_get_data.sh -l 101,105,106,107,108 -c 912000000,916000000



echo ""
echo "Disable All..."
bash sdr_tx_update.sh -l 102,103,104,109 -s 0,0,0,0 -g 0,0,0,0
sleep 2

