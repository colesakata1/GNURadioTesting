#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Transmit tone
# Author: MR
# GNU Radio version: v3.8.5.0-6-g57bd109d

from gnuradio import analog
from gnuradio import gr
from gnuradio.filter import firdes
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import uhd
import time
try:
    from xmlrpc.server import SimpleXMLRPCServer
except ImportError:
    from SimpleXMLRPCServer import SimpleXMLRPCServer
import threading


class Tx_Tone(gr.top_block):

    def __init__(self, fc=915e6, node='101', tone_amp=0.5, tone_freq=0.5e6, tx_gain=40, samp_rate=3e6):
        gr.top_block.__init__(self, "Transmit tone")

        ##################################################
        # Parameters
        ##################################################
        self.fc = fc
        self.node = node
        self.tone_amp = tone_amp
        self.tone_freq = tone_freq
        self.tx_gain = tx_gain
        self.samp_rate = samp_rate

        ##################################################
        # Blocks
        ##################################################
        self.xmlrpc_server_0 = SimpleXMLRPCServer(("10.1.1." + node, 8080), allow_none=True)
        self.xmlrpc_server_0.register_instance(self)
        self.xmlrpc_server_0_thread = threading.Thread(target=self.xmlrpc_server_0.serve_forever)
        self.xmlrpc_server_0_thread.daemon = True
        self.xmlrpc_server_0_thread.start()
        self.uhd_usrp_sink_0 = uhd.usrp_sink(
            ",".join(("", "")),
            uhd.stream_args(
                cpu_format="fc32",
                args='',
                channels=list(range(0,1)),
            ),
            '',
        )
        self.uhd_usrp_sink_0.set_center_freq(fc, 0)
        self.uhd_usrp_sink_0.set_gain(tx_gain, 0)
        self.uhd_usrp_sink_0.set_antenna('TX/RX', 0)
        self.uhd_usrp_sink_0.set_samp_rate(samp_rate)
        # No synchronization enforced.
        self.analog_sig_source_x_0 = analog.sig_source_c(samp_rate, analog.GR_COS_WAVE, tone_freq, tone_amp, 0, 0)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_sig_source_x_0, 0), (self.uhd_usrp_sink_0, 0))


    def get_fc(self):
        return self.fc

    def set_fc(self, fc):
        self.fc = fc
        self.uhd_usrp_sink_0.set_center_freq(self.fc, 0)

    def get_node(self):
        return self.node

    def set_node(self, node):
        self.node = node

    def get_tone_amp(self):
        return self.tone_amp

    def set_tone_amp(self, tone_amp):
        self.tone_amp = tone_amp
        self.analog_sig_source_x_0.set_amplitude(self.tone_amp)

    def get_tone_freq(self):
        return self.tone_freq

    def set_tone_freq(self, tone_freq):
        self.tone_freq = tone_freq
        self.analog_sig_source_x_0.set_frequency(self.tone_freq)

    def get_tx_gain(self):
        return self.tx_gain

    def set_tx_gain(self, tx_gain):
        self.tx_gain = tx_gain
        self.uhd_usrp_sink_0.set_gain(self.tx_gain, 0)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.analog_sig_source_x_0.set_sampling_freq(self.samp_rate)
        self.uhd_usrp_sink_0.set_samp_rate(self.samp_rate)




def argument_parser():
    parser = ArgumentParser()
    parser.add_argument(
        "-c", "--fc", dest="fc", type=eng_float, default="915.0M",
        help="Set Center Frequency [default=%(default)r]")
    parser.add_argument(
        "-n", "--node", dest="node", type=str, default='101',
        help="Set Node Number [default=%(default)r]")
    parser.add_argument(
        "-a", "--tone-amp", dest="tone_amp", type=eng_float, default="500.0m",
        help="Set Signal Amplitude (tone) [default=%(default)r]")
    parser.add_argument(
        "-f", "--tone-freq", dest="tone_freq", type=eng_float, default="500.0k",
        help="Set Tone Frequency (Relative to fc) [default=%(default)r]")
    parser.add_argument(
        "-g", "--tx-gain", dest="tx_gain", type=eng_float, default="40.0",
        help="Set Transmitter Gain [default=%(default)r]")
    parser.add_argument(
        "-r", "--samp-rate", dest="samp_rate", type=eng_float, default="3.0M",
        help="Set Sample Rate [default=%(default)r]")
    return parser


def main(top_block_cls=Tx_Tone, options=None):
    if options is None:
        options = argument_parser().parse_args()
    tb = top_block_cls(fc=options.fc, node=options.node, tone_amp=options.tone_amp, tone_freq=options.tone_freq, tx_gain=options.tx_gain, samp_rate=options.samp_rate)

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        sys.exit(0)

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    tb.start()

    tb.wait()


if __name__ == '__main__':
    main()
