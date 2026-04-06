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
bash sdr_tx_start.sh -l 105,106 -a 1e6,1e6 -c 912e6,912e6 -f 1e5,1e5 -m 0.1,0.1 -g 30,30 -s 0
sleep 10

echo ""
echo "Initiating remote Rx nodes..."
echo "-----------------------------"
bash sdr_rx_start.sh -l 101,102,103,104,107,108,109 -a 1.5e6,1.5e6,1.5e6,1.5e6,1.5e6,1.5e6,1.5e6 -c 912e6,912e6,912e6,912e6,912e6,912e6,912e6 -g 40,40,40,40,40,40,40
sleep 10

echo ""
echo "Initial Measurements"
echo "-----------------------------"
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000

echo ""
echo "OFDM Transmission Enabled, 105..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 105,106 -s 2,0 -g 30,0
sleep 3

bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000

echo ""
echo "OFDM Transmission Enabled, 106..."
echo "---------------------------------"
bash sdr_tx_update.sh -l 105,106 -s 0,2 -g 0,30
sleep 3

bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000

echo ""
echo "OFDM Transmission Enabled, 106... fc=918MHz"
echo "---------------------------------"
bash sdr_tx_update.sh -l 105,106 -s 0,2 -g 0,30 -c 912000000,918000000
sleep 3

bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000


echo ""
echo "OFDM Transmission Enabled, 105,fc=912MHz and 106,fc=918MHz"
echo "---------------------------------"
bash sdr_tx_update.sh -l 105,106 -s 2,2 -g 30,30 -c 912000000,918000000
sleep 3

bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000
bash sdr_get_data.sh -l 101,102,103,104,107,108,109 -c 912000000,915000000,918000000

