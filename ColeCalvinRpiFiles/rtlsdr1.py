#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Not titled yet
# GNU Radio version: 3.10.12.0

from PyQt5 import Qt
from gnuradio import qtgui
from PyQt5 import QtCore
from PyQt5.QtCore import QObject, pyqtSlot
from gnuradio import analog
from gnuradio import blocks
import numpy
from gnuradio import digital
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import sys
import signal
from PyQt5 import Qt
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import iio
import sip
import threading



class rtlsdr1(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "Not titled yet", catch_exceptions=True)
        Qt.QWidget.__init__(self)
        self.setWindowTitle("Not titled yet")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except BaseException as exc:
            print(f"Qt GUI: Could not set Icon: {str(exc)}", file=sys.stderr)
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("gnuradio/flowgraphs", "rtlsdr1")

        try:
            geometry = self.settings.value("geometry")
            if geometry:
                self.restoreGeometry(geometry)
        except BaseException as exc:
            print(f"Qt GUI: Could not restore geometry: {str(exc)}", file=sys.stderr)
        self.flowgraph_started = threading.Event()

        ##################################################
        # Variables
        ##################################################
        self.txfreq = txfreq = 920e6
        self.txGain = txGain = 1
        self.theta = theta = 0
        self.sigselect = sigselect = 0
        self.samp_rate = samp_rate = 2048000
        self.rxfreq_0 = rxfreq_0 = 920e6
        self.rxGain = rxGain = 1

        ##################################################
        # Blocks
        ##################################################

        self._txfreq_range = qtgui.Range(87.7e6, 1000e6, 200e3, 920e6, 200)
        self._txfreq_win = qtgui.RangeWidget(self._txfreq_range, self.set_txfreq, "Tx Frequency", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._txfreq_win)
        self._txGain_range = qtgui.Range(0, 15, 1, 1, 200)
        self._txGain_win = qtgui.RangeWidget(self._txGain_range, self.set_txGain, "'txGain'", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._txGain_win)
        self._theta_range = qtgui.Range(0, 3, 0.1, 0, 200)
        self._theta_win = qtgui.RangeWidget(self._theta_range, self.set_theta, "'theta'", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._theta_win)
        # Create the options list
        self._sigselect_options = [0, 1]
        # Create the labels list
        self._sigselect_labels = ['BPSK', 'Cosine']
        # Create the combo box
        self._sigselect_tool_bar = Qt.QToolBar(self)
        self._sigselect_tool_bar.addWidget(Qt.QLabel("'sigselect'" + ": "))
        self._sigselect_combo_box = Qt.QComboBox()
        self._sigselect_tool_bar.addWidget(self._sigselect_combo_box)
        for _label in self._sigselect_labels: self._sigselect_combo_box.addItem(_label)
        self._sigselect_callback = lambda i: Qt.QMetaObject.invokeMethod(self._sigselect_combo_box, "setCurrentIndex", Qt.Q_ARG("int", self._sigselect_options.index(i)))
        self._sigselect_callback(self.sigselect)
        self._sigselect_combo_box.currentIndexChanged.connect(
            lambda i: self.set_sigselect(self._sigselect_options[i]))
        # Create the radio buttons
        self.top_layout.addWidget(self._sigselect_tool_bar)
        self._rxfreq_0_range = qtgui.Range(87.7e6, 1000e6, 200e3, 920e6, 200)
        self._rxfreq_0_win = qtgui.RangeWidget(self._rxfreq_0_range, self.set_rxfreq_0, "Rx Frequency", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._rxfreq_0_win)
        self._rxGain_range = qtgui.Range(0, 100, 1, 1, 200)
        self._rxGain_win = qtgui.RangeWidget(self._rxGain_range, self.set_rxGain, "'rxGain'", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._rxGain_win)
        self.qtgui_sink_x_1 = qtgui.sink_c(
            1024, #fftsize
            window.WIN_BLACKMAN_hARRIS, #wintype
            rxfreq_0, #fc
            samp_rate, #bw
            "", #name
            True, #plotfreq
            True, #plotwaterfall
            True, #plottime
            True, #plotconst
            None # parent
        )
        self.qtgui_sink_x_1.set_update_time(1.0/10)
        self._qtgui_sink_x_1_win = sip.wrapinstance(self.qtgui_sink_x_1.qwidget(), Qt.QWidget)

        self.qtgui_sink_x_1.enable_rf_freq(False)

        self.top_layout.addWidget(self._qtgui_sink_x_1_win)
        self.iio_pluto_source_0 = iio.fmcomms2_source_fc32('' if '' else iio.get_pluto_uri(), [True, True], 32768)
        self.iio_pluto_source_0.set_len_tag_key('packet_len')
        self.iio_pluto_source_0.set_frequency(int(rxfreq_0))
        self.iio_pluto_source_0.set_samplerate(samp_rate)
        self.iio_pluto_source_0.set_gain_mode(0, 'manual')
        self.iio_pluto_source_0.set_gain(0, rxGain)
        self.iio_pluto_source_0.set_quadrature(True)
        self.iio_pluto_source_0.set_rfdc(True)
        self.iio_pluto_source_0.set_bbdc(True)
        self.iio_pluto_source_0.set_filter_params('Auto', '', 0, 0)
        self.iio_pluto_sink_0 = iio.fmcomms2_sink_fc32('' if '' else iio.get_pluto_uri(), [True, True], 32768, False)
        self.iio_pluto_sink_0.set_len_tag_key('')
        self.iio_pluto_sink_0.set_bandwidth(20000000)
        self.iio_pluto_sink_0.set_frequency(int(txfreq))
        self.iio_pluto_sink_0.set_samplerate(samp_rate)
        self.iio_pluto_sink_0.set_attenuation(0, txGain)
        self.iio_pluto_sink_0.set_filter_params('Auto', '', 0, 0)
        self.digital_chunks_to_symbols_xx_0 = digital.chunks_to_symbols_ic([-0.250-0.250j, -0.250+0.250j, 0.250-0.250j, 0.250+0.250j], 2)
        self.blocks_throttle2_0 = blocks.throttle( gr.sizeof_gr_complex*1, samp_rate, True, 0 if "auto" == "auto" else max( int(float(0.1) * samp_rate) if "auto" == "time" else int(0.1), 1) )
        self.blocks_selector_0 = blocks.selector(gr.sizeof_gr_complex*1,sigselect,0)
        self.blocks_selector_0.set_enabled(True)
        self.blocks_repeat_0 = blocks.repeat(gr.sizeof_gr_complex*1, 20)
        self.analog_sig_source_x_0 = analog.sig_source_c(samp_rate, analog.GR_COS_WAVE, txfreq, 0.5, theta, 0)
        self.analog_random_source_x_0 = blocks.vector_source_i(list(map(int, numpy.random.randint(0, 4, 1000))), True)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_random_source_x_0, 0), (self.digital_chunks_to_symbols_xx_0, 0))
        self.connect((self.analog_sig_source_x_0, 0), (self.blocks_selector_0, 1))
        self.connect((self.blocks_repeat_0, 0), (self.blocks_selector_0, 0))
        self.connect((self.blocks_selector_0, 0), (self.blocks_throttle2_0, 0))
        self.connect((self.blocks_throttle2_0, 0), (self.iio_pluto_sink_0, 0))
        self.connect((self.digital_chunks_to_symbols_xx_0, 0), (self.blocks_repeat_0, 0))
        self.connect((self.iio_pluto_source_0, 0), (self.qtgui_sink_x_1, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("gnuradio/flowgraphs", "rtlsdr1")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_txfreq(self):
        return self.txfreq

    def set_txfreq(self, txfreq):
        self.txfreq = txfreq
        self.analog_sig_source_x_0.set_frequency(self.txfreq)
        self.iio_pluto_sink_0.set_frequency(int(self.txfreq))

    def get_txGain(self):
        return self.txGain

    def set_txGain(self, txGain):
        self.txGain = txGain
        self.iio_pluto_sink_0.set_attenuation(0,self.txGain)

    def get_theta(self):
        return self.theta

    def set_theta(self, theta):
        self.theta = theta
        self.analog_sig_source_x_0.set_offset(self.theta)

    def get_sigselect(self):
        return self.sigselect

    def set_sigselect(self, sigselect):
        self.sigselect = sigselect
        self._sigselect_callback(self.sigselect)
        self.blocks_selector_0.set_input_index(self.sigselect)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.analog_sig_source_x_0.set_sampling_freq(self.samp_rate)
        self.blocks_throttle2_0.set_sample_rate(self.samp_rate)
        self.iio_pluto_sink_0.set_samplerate(self.samp_rate)
        self.iio_pluto_source_0.set_samplerate(self.samp_rate)
        self.qtgui_sink_x_1.set_frequency_range(self.rxfreq_0, self.samp_rate)

    def get_rxfreq_0(self):
        return self.rxfreq_0

    def set_rxfreq_0(self, rxfreq_0):
        self.rxfreq_0 = rxfreq_0
        self.iio_pluto_source_0.set_frequency(int(self.rxfreq_0))
        self.qtgui_sink_x_1.set_frequency_range(self.rxfreq_0, self.samp_rate)

    def get_rxGain(self):
        return self.rxGain

    def set_rxGain(self, rxGain):
        self.rxGain = rxGain
        self.iio_pluto_source_0.set_gain(0, self.rxGain)




def main(top_block_cls=rtlsdr1, options=None):

    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()

    tb.start()
    tb.flowgraph_started.set()

    tb.show()

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        Qt.QApplication.quit()

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    timer = Qt.QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    qapp.exec_()

if __name__ == '__main__':
    main()
