#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Not titled yet
# Author: colesakata
# GNU Radio version: 3.10.12.0

from PyQt5 import Qt
from gnuradio import qtgui
from PyQt5 import QtCore
from PyQt5.QtCore import QObject, pyqtSlot
from gnuradio import analog
from gnuradio import blocks
from gnuradio import filter
from gnuradio.filter import firdes
from gnuradio import gr
from gnuradio.fft import window
import sys
import signal
from PyQt5 import Qt
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import zeromq
from xmlrpc.server import SimpleXMLRPCServer
import threading
import sip



class XMLRPC(gr.top_block, Qt.QWidget):

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

        self.settings = Qt.QSettings("gnuradio/flowgraphs", "XMLRPC")

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
        self.sig_freq = sig_freq = 1e5
        self.sig_amp = sig_amp = 1
        self.samp_rate = samp_rate = 2000000
        self.noise_select = noise_select = 0
        self.gain = gain = 1
        self.filter_select = filter_select = 0
        self.cmplx_select = cmplx_select = 0
        self.bandpass_highend_cutoff = bandpass_highend_cutoff = 0
        self.Sig_Type = Sig_Type = 102

        ##################################################
        # Blocks
        ##################################################

        self._sig_freq_range = qtgui.Range(5e4, 5e5, 5e4, 1e5, 200)
        self._sig_freq_win = qtgui.RangeWidget(self._sig_freq_range, self.set_sig_freq, "Signal Frequency", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_grid_layout.addWidget(self._sig_freq_win, 0, 0, 1, 2)
        for r in range(0, 1):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 2):
            self.top_grid_layout.setColumnStretch(c, 1)
        # Create the options list
        self._noise_select_options = [0, 1]
        # Create the labels list
        self._noise_select_labels = ['Disabled', 'Enabled']
        # Create the combo box
        self._noise_select_tool_bar = Qt.QToolBar(self)
        self._noise_select_tool_bar.addWidget(Qt.QLabel("'noise_select'" + ": "))
        self._noise_select_combo_box = Qt.QComboBox()
        self._noise_select_tool_bar.addWidget(self._noise_select_combo_box)
        for _label in self._noise_select_labels: self._noise_select_combo_box.addItem(_label)
        self._noise_select_callback = lambda i: Qt.QMetaObject.invokeMethod(self._noise_select_combo_box, "setCurrentIndex", Qt.Q_ARG("int", self._noise_select_options.index(i)))
        self._noise_select_callback(self.noise_select)
        self._noise_select_combo_box.currentIndexChanged.connect(
            lambda i: self.set_noise_select(self._noise_select_options[i]))
        # Create the radio buttons
        self.top_layout.addWidget(self._noise_select_tool_bar)
        # Create the options list
        self._filter_select_options = [0, 1]
        # Create the labels list
        self._filter_select_labels = ['Enable', 'Bypass']
        # Create the combo box
        self._filter_select_tool_bar = Qt.QToolBar(self)
        self._filter_select_tool_bar.addWidget(Qt.QLabel("Filter Selection" + ": "))
        self._filter_select_combo_box = Qt.QComboBox()
        self._filter_select_tool_bar.addWidget(self._filter_select_combo_box)
        for _label in self._filter_select_labels: self._filter_select_combo_box.addItem(_label)
        self._filter_select_callback = lambda i: Qt.QMetaObject.invokeMethod(self._filter_select_combo_box, "setCurrentIndex", Qt.Q_ARG("int", self._filter_select_options.index(i)))
        self._filter_select_callback(self.filter_select)
        self._filter_select_combo_box.currentIndexChanged.connect(
            lambda i: self.set_filter_select(self._filter_select_options[i]))
        # Create the radio buttons
        self.top_grid_layout.addWidget(self._filter_select_tool_bar, 0, 3, 1, 1)
        for r in range(0, 1):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(3, 4):
            self.top_grid_layout.setColumnStretch(c, 1)
        # Create the options list
        self._cmplx_select_options = [0, 1]
        # Create the labels list
        self._cmplx_select_labels = ['Real Sine', 'Complex Sine']
        # Create the combo box
        self._cmplx_select_tool_bar = Qt.QToolBar(self)
        self._cmplx_select_tool_bar.addWidget(Qt.QLabel("Source Signal" + ": "))
        self._cmplx_select_combo_box = Qt.QComboBox()
        self._cmplx_select_tool_bar.addWidget(self._cmplx_select_combo_box)
        for _label in self._cmplx_select_labels: self._cmplx_select_combo_box.addItem(_label)
        self._cmplx_select_callback = lambda i: Qt.QMetaObject.invokeMethod(self._cmplx_select_combo_box, "setCurrentIndex", Qt.Q_ARG("int", self._cmplx_select_options.index(i)))
        self._cmplx_select_callback(self.cmplx_select)
        self._cmplx_select_combo_box.currentIndexChanged.connect(
            lambda i: self.set_cmplx_select(self._cmplx_select_options[i]))
        # Create the radio buttons
        self.top_grid_layout.addWidget(self._cmplx_select_tool_bar, 0, 2, 1, 1)
        for r in range(0, 1):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(2, 3):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._bandpass_highend_cutoff_range = qtgui.Range(0, 100000, 10000, 0, 200)
        self._bandpass_highend_cutoff_win = qtgui.RangeWidget(self._bandpass_highend_cutoff_range, self.set_bandpass_highend_cutoff, "Filter High-End Freq.", "eng_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._bandpass_highend_cutoff_win)
        # Create the options list
        self._Sig_Type_options = [102, 103]
        # Create the labels list
        self._Sig_Type_labels = ['Cosine', 'Square']
        # Create the combo box
        self._Sig_Type_tool_bar = Qt.QToolBar(self)
        self._Sig_Type_tool_bar.addWidget(Qt.QLabel("Waveform" + ": "))
        self._Sig_Type_combo_box = Qt.QComboBox()
        self._Sig_Type_tool_bar.addWidget(self._Sig_Type_combo_box)
        for _label in self._Sig_Type_labels: self._Sig_Type_combo_box.addItem(_label)
        self._Sig_Type_callback = lambda i: Qt.QMetaObject.invokeMethod(self._Sig_Type_combo_box, "setCurrentIndex", Qt.Q_ARG("int", self._Sig_Type_options.index(i)))
        self._Sig_Type_callback(self.Sig_Type)
        self._Sig_Type_combo_box.currentIndexChanged.connect(
            lambda i: self.set_Sig_Type(self._Sig_Type_options[i]))
        # Create the radio buttons
        self.top_grid_layout.addWidget(self._Sig_Type_tool_bar, 0, 4, 1, 1)
        for r in range(0, 1):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(4, 5):
            self.top_grid_layout.setColumnStretch(c, 1)
        self.zeromq_pub_sink_0 = zeromq.pub_sink(gr.sizeof_float, 1, 'tcp://127.0.0.1:55555', 100, False, 1, '', True, True)
        self.xmlrpc_server_0 = SimpleXMLRPCServer(('localhost', 8080), allow_none=True)
        self.xmlrpc_server_0.register_instance(self)
        self.xmlrpc_server_0_thread = threading.Thread(target=self.xmlrpc_server_0.serve_forever)
        self.xmlrpc_server_0_thread.daemon = True
        self.xmlrpc_server_0_thread.start()
        self.qtgui_sink_x_0 = qtgui.sink_c(
            1024, #fftsize
            window.WIN_BLACKMAN_hARRIS, #wintype
            915000000, #fc
            samp_rate, #bw
            "", #name
            True, #plotfreq
            True, #plotwaterfall
            True, #plottime
            True, #plotconst
            None # parent
        )
        self.qtgui_sink_x_0.set_update_time(1.0/10)
        self._qtgui_sink_x_0_win = sip.wrapinstance(self.qtgui_sink_x_0.qwidget(), Qt.QWidget)

        self.qtgui_sink_x_0.enable_rf_freq(False)

        self.top_layout.addWidget(self._qtgui_sink_x_0_win)
        self._gain_range = qtgui.Range(0, 100, 1, 1, 200)
        self._gain_win = qtgui.RangeWidget(self._gain_range, self.set_gain, "'gain'", "counter_slider", float, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._gain_win)
        self.blocks_throttle2_2 = blocks.throttle( gr.sizeof_gr_complex*1, samp_rate, True, 0 if "auto" == "auto" else max( int(float(0.1) * samp_rate) if "auto" == "time" else int(0.1), 1) )
        self.blocks_selector_1 = blocks.selector(gr.sizeof_gr_complex*1,noise_select,0)
        self.blocks_selector_1.set_enabled(True)
        self.blocks_selector_0_0 = blocks.selector(gr.sizeof_gr_complex*1,filter_select,0)
        self.blocks_selector_0_0.set_enabled(True)
        self.blocks_selector_0 = blocks.selector(gr.sizeof_gr_complex*1,cmplx_select,0)
        self.blocks_selector_0.set_enabled(True)
        self.blocks_moving_average_xx_0 = blocks.moving_average_ff(2500, (1/2500), 500, 1)
        self.blocks_float_to_complex_0 = blocks.float_to_complex(1)
        self.blocks_complex_to_mag_squared_0 = blocks.complex_to_mag_squared(1)
        self.blocks_add_xx_0 = blocks.add_vcc(1)
        self.band_pass_filter_0 = filter.fir_filter_ccf(
            1,
            firdes.band_pass(
                1,
                samp_rate,
                (sig_freq - 25000),
                (sig_freq + 25000 +bandpass_highend_cutoff),
                5e3,
                window.WIN_HAMMING,
                6.76))
        self.avg_power_1 = qtgui.number_sink(
            gr.sizeof_float,
            0,
            qtgui.NUM_GRAPH_HORIZ,
            1,
            None # parent
        )
        self.avg_power_1.set_update_time(0.10)
        self.avg_power_1.set_title('Average Power 1')

        labels = ['', '', '', '', '',
            '', '', '', '', '']
        units = ['', '', '', '', '',
            '', '', '', '', '']
        colors = [("black", "black"), ("black", "black"), ("black", "black"), ("black", "black"), ("black", "black"),
            ("black", "black"), ("black", "black"), ("black", "black"), ("black", "black"), ("black", "black")]
        factor = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]

        for i in range(1):
            self.avg_power_1.set_min(i, -1)
            self.avg_power_1.set_max(i, 1)
            self.avg_power_1.set_color(i, colors[i][0], colors[i][1])
            if len(labels[i]) == 0:
                self.avg_power_1.set_label(i, "Data {0}".format(i))
            else:
                self.avg_power_1.set_label(i, labels[i])
            self.avg_power_1.set_unit(i, units[i])
            self.avg_power_1.set_factor(i, factor[i])

        self.avg_power_1.enable_autoscale(True)
        self._avg_power_1_win = sip.wrapinstance(self.avg_power_1.qwidget(), Qt.QWidget)
        self.top_layout.addWidget(self._avg_power_1_win)
        self.analog_sig_source_x_1 = analog.sig_source_f(samp_rate, Sig_Type, sig_freq, sig_amp, 0, 0)
        self.analog_sig_source_x_0 = analog.sig_source_c(samp_rate, Sig_Type, sig_freq, 1, 0, 0)
        self.analog_noise_source_x_0 = analog.noise_source_c(analog.GR_GAUSSIAN, 0.5, 0)
        self.analog_const_source_x_0 = analog.sig_source_f(0, analog.GR_CONST_WAVE, 0, 0, 0)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_const_source_x_0, 0), (self.blocks_float_to_complex_0, 1))
        self.connect((self.analog_noise_source_x_0, 0), (self.blocks_add_xx_0, 1))
        self.connect((self.analog_sig_source_x_0, 0), (self.blocks_selector_0, 1))
        self.connect((self.analog_sig_source_x_1, 0), (self.blocks_float_to_complex_0, 0))
        self.connect((self.band_pass_filter_0, 0), (self.blocks_selector_0_0, 0))
        self.connect((self.blocks_add_xx_0, 0), (self.blocks_selector_1, 1))
        self.connect((self.blocks_complex_to_mag_squared_0, 0), (self.blocks_moving_average_xx_0, 0))
        self.connect((self.blocks_float_to_complex_0, 0), (self.blocks_selector_0, 0))
        self.connect((self.blocks_moving_average_xx_0, 0), (self.avg_power_1, 0))
        self.connect((self.blocks_moving_average_xx_0, 0), (self.zeromq_pub_sink_0, 0))
        self.connect((self.blocks_selector_0, 0), (self.blocks_add_xx_0, 0))
        self.connect((self.blocks_selector_0, 0), (self.blocks_selector_1, 0))
        self.connect((self.blocks_selector_0_0, 0), (self.blocks_complex_to_mag_squared_0, 0))
        self.connect((self.blocks_selector_0_0, 0), (self.qtgui_sink_x_0, 0))
        self.connect((self.blocks_selector_1, 0), (self.blocks_throttle2_2, 0))
        self.connect((self.blocks_throttle2_2, 0), (self.band_pass_filter_0, 0))
        self.connect((self.blocks_throttle2_2, 0), (self.blocks_selector_0_0, 1))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("gnuradio/flowgraphs", "XMLRPC")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_sig_freq(self):
        return self.sig_freq

    def set_sig_freq(self, sig_freq):
        self.sig_freq = sig_freq
        self.analog_sig_source_x_0.set_frequency(self.sig_freq)
        self.analog_sig_source_x_1.set_frequency(self.sig_freq)
        self.band_pass_filter_0.set_taps(firdes.band_pass(1, self.samp_rate, (self.sig_freq - 25000), (self.sig_freq + 25000 +self.bandpass_highend_cutoff), 5e3, window.WIN_HAMMING, 6.76))

    def get_sig_amp(self):
        return self.sig_amp

    def set_sig_amp(self, sig_amp):
        self.sig_amp = sig_amp
        self.analog_sig_source_x_1.set_amplitude(self.sig_amp)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.analog_sig_source_x_0.set_sampling_freq(self.samp_rate)
        self.analog_sig_source_x_1.set_sampling_freq(self.samp_rate)
        self.band_pass_filter_0.set_taps(firdes.band_pass(1, self.samp_rate, (self.sig_freq - 25000), (self.sig_freq + 25000 +self.bandpass_highend_cutoff), 5e3, window.WIN_HAMMING, 6.76))
        self.blocks_throttle2_2.set_sample_rate(self.samp_rate)
        self.qtgui_sink_x_0.set_frequency_range(915000000, self.samp_rate)

    def get_noise_select(self):
        return self.noise_select

    def set_noise_select(self, noise_select):
        self.noise_select = noise_select
        self._noise_select_callback(self.noise_select)
        self.blocks_selector_1.set_input_index(self.noise_select)

    def get_gain(self):
        return self.gain

    def set_gain(self, gain):
        self.gain = gain

    def get_filter_select(self):
        return self.filter_select

    def set_filter_select(self, filter_select):
        self.filter_select = filter_select
        self._filter_select_callback(self.filter_select)
        self.blocks_selector_0_0.set_input_index(self.filter_select)

    def get_cmplx_select(self):
        return self.cmplx_select

    def set_cmplx_select(self, cmplx_select):
        self.cmplx_select = cmplx_select
        self._cmplx_select_callback(self.cmplx_select)
        self.blocks_selector_0.set_input_index(self.cmplx_select)

    def get_bandpass_highend_cutoff(self):
        return self.bandpass_highend_cutoff

    def set_bandpass_highend_cutoff(self, bandpass_highend_cutoff):
        self.bandpass_highend_cutoff = bandpass_highend_cutoff
        self.band_pass_filter_0.set_taps(firdes.band_pass(1, self.samp_rate, (self.sig_freq - 25000), (self.sig_freq + 25000 +self.bandpass_highend_cutoff), 5e3, window.WIN_HAMMING, 6.76))

    def get_Sig_Type(self):
        return self.Sig_Type

    def set_Sig_Type(self, Sig_Type):
        self.Sig_Type = Sig_Type
        self._Sig_Type_callback(self.Sig_Type)
        self.analog_sig_source_x_0.set_waveform(self.Sig_Type)
        self.analog_sig_source_x_1.set_waveform(self.Sig_Type)




def main(top_block_cls=XMLRPC, options=None):

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
