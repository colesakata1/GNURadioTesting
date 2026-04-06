#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Pi transmitter Script
# Author: MR
# Description: Continuously running transmitter with various parameters that can be remotely configured
# GNU Radio version: v3.8.5.0-6-g57bd109d

from gnuradio import analog
from gnuradio import blocks
import numpy
from gnuradio import digital
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


class Tx_general(gr.top_block):

    def __init__(self, fc=915e6, node='101', ofdm_scale=0.1, samp_rate=3e6, sig_select=1, tone_amp=0.5, tone_freq=0.5e6, tx_gain=40):
        gr.top_block.__init__(self, "Pi transmitter Script")

        ##################################################
        # Parameters
        ##################################################
        self.fc = fc
        self.node = node
        self.ofdm_scale = ofdm_scale
        self.samp_rate = samp_rate
        self.sig_select = sig_select
        self.tone_amp = tone_amp
        self.tone_freq = tone_freq
        self.tx_gain = tx_gain

        ##################################################
        # Variables
        ##################################################
        self.packet_len = packet_len = 50
        self.sync_word2 = sync_word2 = [0j, 0j, 0j, 0j, 0j, 0j, (-1+0j), (-1+0j), (-1+0j), (-1+0j), (1+0j), (1+0j), (-1+0j), (-1+0j), (-1+0j), (1+0j), (-1+0j), (1+0j), (1+0j), (1 +0j), (1+0j), (1+0j), (-1+0j), (-1+0j), (-1+0j), (-1+0j), (-1+0j), (1+0j), (-1+0j), (-1+0j), (1+0j), (-1+0j), 0j, (1+0j), (-1+0j), (1+0j), (1+0j), (1+0j), (-1+0j), (1+0j), (1+0j), (1+0j), (-1+0j), (1+0j), (1+0j), (1+0j), (1+0j), (-1+0j), (1+0j), (-1+0j), (-1+0j), (-1+0j), (1+0j), (-1+0j), (1+0j), (-1+0j), (-1+0j), (-1+0j), (-1+0j), 0j, 0j, 0j, 0j, 0j]
        self.sync_word1 = sync_word1 = [0., 0., 0., 0., 0., 0., 0., 1.41421356, 0., -1.41421356, 0., 1.41421356, 0., -1.41421356, 0., -1.41421356, 0., -1.41421356, 0., 1.41421356, 0., -1.41421356, 0., 1.41421356, 0., -1.41421356, 0., -1.41421356, 0., -1.41421356, 0., -1.41421356, 0., 1.41421356, 0., -1.41421356, 0., 1.41421356, 0., 1.41421356, 0., 1.41421356, 0., -1.41421356, 0., 1.41421356, 0., 1.41421356, 0., 1.41421356, 0., -1.41421356, 0., 1.41421356, 0., 1.41421356, 0., 1.41421356, 0., 0., 0., 0., 0., 0.]
        self.pilot_symbols = pilot_symbols = ((-1,1,1,-1),)
        self.pilot_carriers = pilot_carriers = ((-10,-1,1,10),)
        self.occupied_carriers = occupied_carriers = (list(range(-22, -12)),list(range(13, 23)))
        self.len_tag_key = len_tag_key = packet_len
        self.fft_len = fft_len = 64

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
        self.digital_ofdm_tx_0_0 = digital.ofdm_tx(
            fft_len=64,
            cp_len=fft_len//4,
            packet_length_tag_key='packet_len',
            occupied_carriers=occupied_carriers,
            pilot_carriers=pilot_carriers,
            pilot_symbols=pilot_symbols,
            sync_word1=None,
            sync_word2=None,
            bps_header=1,
            bps_payload=1,
            rolloff=0,
            debug_log=False,
            scramble_bits=False)
        self.blocks_stream_to_tagged_stream_0 = blocks.stream_to_tagged_stream(gr.sizeof_char, 1, packet_len, "packet_len")
        self.blocks_selector_0 = blocks.selector(gr.sizeof_gr_complex*1,sig_select,0)
        self.blocks_selector_0.set_enabled(True)
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_cc(ofdm_scale)
        self.analog_sig_source_x_0 = analog.sig_source_c(samp_rate, analog.GR_COS_WAVE, tone_freq, tone_amp, 0, 0)
        self.analog_random_source_x_0 = blocks.vector_source_b(list(map(int, numpy.random.randint(0, 255, 10000))), True)
        self.analog_const_source_x_0 = analog.sig_source_c(0, analog.GR_CONST_WAVE, 0, 0, 0)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_const_source_x_0, 0), (self.blocks_selector_0, 0))
        self.connect((self.analog_random_source_x_0, 0), (self.blocks_stream_to_tagged_stream_0, 0))
        self.connect((self.analog_sig_source_x_0, 0), (self.blocks_selector_0, 1))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_selector_0, 2))
        self.connect((self.blocks_selector_0, 0), (self.uhd_usrp_sink_0, 0))
        self.connect((self.blocks_stream_to_tagged_stream_0, 0), (self.digital_ofdm_tx_0_0, 0))
        self.connect((self.digital_ofdm_tx_0_0, 0), (self.blocks_multiply_const_vxx_0, 0))


    def get_fc(self):
        return self.fc

    def set_fc(self, fc):
        self.fc = fc
        self.uhd_usrp_sink_0.set_center_freq(self.fc, 0)

    def get_node(self):
        return self.node

    def set_node(self, node):
        self.node = node

    def get_ofdm_scale(self):
        return self.ofdm_scale

    def set_ofdm_scale(self, ofdm_scale):
        self.ofdm_scale = ofdm_scale
        self.blocks_multiply_const_vxx_0.set_k(self.ofdm_scale)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.analog_sig_source_x_0.set_sampling_freq(self.samp_rate)
        self.uhd_usrp_sink_0.set_samp_rate(self.samp_rate)

    def get_sig_select(self):
        return self.sig_select

    def set_sig_select(self, sig_select):
        self.sig_select = sig_select
        self.blocks_selector_0.set_input_index(self.sig_select)

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

    def get_packet_len(self):
        return self.packet_len

    def set_packet_len(self, packet_len):
        self.packet_len = packet_len
        self.set_len_tag_key(self.packet_len)
        self.blocks_stream_to_tagged_stream_0.set_packet_len(self.packet_len)
        self.blocks_stream_to_tagged_stream_0.set_packet_len_pmt(self.packet_len)

    def get_sync_word2(self):
        return self.sync_word2

    def set_sync_word2(self, sync_word2):
        self.sync_word2 = sync_word2

    def get_sync_word1(self):
        return self.sync_word1

    def set_sync_word1(self, sync_word1):
        self.sync_word1 = sync_word1

    def get_pilot_symbols(self):
        return self.pilot_symbols

    def set_pilot_symbols(self, pilot_symbols):
        self.pilot_symbols = pilot_symbols

    def get_pilot_carriers(self):
        return self.pilot_carriers

    def set_pilot_carriers(self, pilot_carriers):
        self.pilot_carriers = pilot_carriers

    def get_occupied_carriers(self):
        return self.occupied_carriers

    def set_occupied_carriers(self, occupied_carriers):
        self.occupied_carriers = occupied_carriers

    def get_len_tag_key(self):
        return self.len_tag_key

    def set_len_tag_key(self, len_tag_key):
        self.len_tag_key = len_tag_key

    def get_fft_len(self):
        return self.fft_len

    def set_fft_len(self, fft_len):
        self.fft_len = fft_len




def argument_parser():
    description = 'Continuously running transmitter with various parameters that can be remotely configured'
    parser = ArgumentParser(description=description)
    parser.add_argument(
        "-c", "--fc", dest="fc", type=eng_float, default="915.0M",
        help="Set Center Frequency [default=%(default)r]")
    parser.add_argument(
        "-n", "--node", dest="node", type=str, default='101',
        help="Set Node Number [default=%(default)r]")
    parser.add_argument(
        "-m", "--ofdm-scale", dest="ofdm_scale", type=eng_float, default="100.0m",
        help="Set OFDM Scaling Factor [default=%(default)r]")
    parser.add_argument(
        "-r", "--samp-rate", dest="samp_rate", type=eng_float, default="3.0M",
        help="Set Sample Rate [default=%(default)r]")
    parser.add_argument(
        "-s", "--sig-select", dest="sig_select", type=intx, default=1,
        help="Set Signal Select [default=%(default)r]")
    parser.add_argument(
        "-a", "--tone-amp", dest="tone_amp", type=eng_float, default="500.0m",
        help="Set Signal Amplitude (tone) [default=%(default)r]")
    parser.add_argument(
        "-f", "--tone-freq", dest="tone_freq", type=eng_float, default="500.0k",
        help="Set Tone Frequency (Relative to fc) [default=%(default)r]")
    parser.add_argument(
        "-g", "--tx-gain", dest="tx_gain", type=eng_float, default="40.0",
        help="Set Transmitter Gain [default=%(default)r]")
    return parser


def main(top_block_cls=Tx_general, options=None):
    if options is None:
        options = argument_parser().parse_args()
    tb = top_block_cls(fc=options.fc, node=options.node, ofdm_scale=options.ofdm_scale, samp_rate=options.samp_rate, sig_select=options.sig_select, tone_amp=options.tone_amp, tone_freq=options.tone_freq, tx_gain=options.tx_gain)

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
