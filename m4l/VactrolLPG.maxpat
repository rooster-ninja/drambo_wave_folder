{
 "patcher": {
  "fileversion": 1,
  "appversion": {
   "major": 8,
   "minor": 6,
   "revision": 0,
   "architecture": "x64",
   "modernui": 1
  },
  "classnamespace": "box",
  "rect": [
   100.0,
   100.0,
   900.0,
   520.0
  ],
  "openinpresentation": 1,
  "default_fontsize": 10.0,
  "boxes": [
   {
    "box": {
     "id": "obj-plugin",
     "maxclass": "newobj",
     "text": "plugin~",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "signal",
      "signal"
     ],
     "patching_rect": [
      40.0,
      260.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-gen",
     "maxclass": "newobj",
     "text": "gen~",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "signal",
      "signal"
     ],
     "patching_rect": [
      40.0,
      320.0,
      300.0,
      22.0
     ],
     "patcher": {
      "fileversion": 1,
      "appversion": {
       "major": 8,
       "minor": 6,
       "revision": 0,
       "architecture": "x64",
       "modernui": 1
      },
      "classnamespace": "dsp.gen",
      "rect": [
       100.0,
       100.0,
       720.0,
       640.0
      ],
      "boxes": [
       {
        "box": {
         "id": "obj-code",
         "maxclass": "codebox",
         "code": "// Vactrol low pass gate (Buchla 292-style), gen~ codebox, stereo\n// Same vactrol model as ../../vactrol_lpg.txt. A Live audio effect has no\n// note gate, so the gate comes from the Gate parameter (map or automate it)\n// and/or an envelope follower on the input (Follow on).\n\nParam decaytime(0.4, min=0.02, max=10);\nParam pingmode(0, min=0, max=1);\nParam lpgmode(1, min=0, max=1);\nParam resonance(0.2, min=0, max=1);\nParam gateon(0, min=0, max=1);\nParam followon(1, min=0, max=1);\nParam thresh(0.1, min=0.001, max=1);\n\nHistory env(0);\nHistory fgate(0);\nHistory gprev(0);\nHistory strike(0);\nHistory v(0);\nHistory l1(0);\nHistory l2(0);\nHistory r1(0);\nHistory r2(0);\n\n// envelope follower with hysteresis: open above thresh, close below thresh/2\na = max(abs(in1), abs(in2));\nenv = max(a, env * exp(-1 / (0.05 * samplerate)));\nfgate = env > thresh ? 1 : (env < thresh * 0.5 ? 0 : fgate);\ngt = max(gateon > 0.5, followon > 0.5 && fgate > 0.5);\n\n// ping: a 10 ms decaying strike on each rising edge\nstrike = (gt > 0.5 && gprev < 0.5) ? 1 : strike * exp(-1 / (0.01 * samplerate));\ngprev = gt;\nctl = pingmode > 0.5 ? strike : gt;\n\n// vactrol: 2 ms attack, release slows as the cell darkens\ntau = ctl > v ? 0.002 : decaytime * (1.5 - v);\nv = v + (ctl - v) * (1 - exp(-1 / (tau * samplerate)));\n\n// LDR response: cutoff ~30 Hz .. 18 kHz, amplitude ~ v^2\ncutoff = 30 * pow(600, v);\namp = v * v;\n\n// Mode 0 = VCA only (filter open), 1 = LPF + VCA\nfc = min(mix(18000, cutoff, lpgmode), samplerate * 0.45);\n\n// TPT state-variable low pass, shared coefficients, one state pair per channel\ng = tan(pi * fc / samplerate);\nkd = 2 - 1.8 * resonance;\na1 = 1 / (1 + g * (g + kd));\na2 = g * a1;\na3 = g * a2;\n\nv3l = in1 - l2;\nv1l = a1 * l1 + a2 * v3l;\nv2l = l2 + a2 * l1 + a3 * v3l;\nl1 = 2 * v1l - l1;\nl2 = 2 * v2l - l2;\n\nv3r = in2 - r2;\nv1r = a1 * r1 + a2 * v3r;\nv2r = r2 + a2 * r1 + a3 * v3r;\nr1 = 2 * v1r - r1;\nr2 = 2 * v2r - r2;\n\nout1 = v2l * amp;\nout2 = v2r * amp;\n",
         "fontface": 0,
         "fontname": "<Monospaced>",
         "fontsize": 12.0,
         "numinlets": 2,
         "numoutlets": 2,
         "outlettype": [
          "",
          ""
         ],
         "patching_rect": [
          50.0,
          60.0,
          600.0,
          500.0
         ]
        }
       },
       {
        "box": {
         "id": "obj-in1",
         "maxclass": "newobj",
         "text": "in 1",
         "numinlets": 0,
         "numoutlets": 1,
         "outlettype": [
          ""
         ],
         "patching_rect": [
          50.0,
          20.0,
          30.0,
          22.0
         ]
        }
       },
       {
        "box": {
         "id": "obj-in2",
         "maxclass": "newobj",
         "text": "in 2",
         "numinlets": 0,
         "numoutlets": 1,
         "outlettype": [
          ""
         ],
         "patching_rect": [
          620.0,
          20.0,
          30.0,
          22.0
         ]
        }
       },
       {
        "box": {
         "id": "obj-out1",
         "maxclass": "newobj",
         "text": "out 1",
         "numinlets": 1,
         "numoutlets": 0,
         "outlettype": [],
         "patching_rect": [
          50.0,
          580.0,
          35.0,
          22.0
         ]
        }
       },
       {
        "box": {
         "id": "obj-out2",
         "maxclass": "newobj",
         "text": "out 2",
         "numinlets": 1,
         "numoutlets": 0,
         "outlettype": [],
         "patching_rect": [
          615.0,
          580.0,
          35.0,
          22.0
         ]
        }
       }
      ],
      "lines": [
       {
        "patchline": {
         "source": [
          "obj-in1",
          0
         ],
         "destination": [
          "obj-code",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "obj-in2",
          0
         ],
         "destination": [
          "obj-code",
          1
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "obj-code",
          0
         ],
         "destination": [
          "obj-out1",
          0
         ]
        }
       },
       {
        "patchline": {
         "source": [
          "obj-code",
          1
         ],
         "destination": [
          "obj-out2",
          0
         ]
        }
       }
      ]
     }
    }
   },
   {
    "box": {
     "id": "obj-plugout",
     "maxclass": "newobj",
     "text": "plugout~",
     "numinlets": 2,
     "numoutlets": 0,
     "outlettype": [],
     "patching_rect": [
      40.0,
      380.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-dial0",
     "maxclass": "live.dial",
     "varname": "Decay",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "float"
     ],
     "parameter_enable": 1,
     "patching_rect": [
      40.0,
      40.0,
      44.0,
      48.0
     ],
     "presentation": 1,
     "presentation_rect": [
      10.0,
      10.0,
      44.0,
      48.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "Decay",
       "parameter_shortname": "Decay",
       "parameter_type": 0,
       "parameter_mmin": 20.0,
       "parameter_mmax": 10000.0,
       "parameter_initial": [
        400.0
       ],
       "parameter_initial_enable": 1,
       "parameter_unitstyle": 2
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-scale0",
     "maxclass": "newobj",
     "text": "* 0.001",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ],
     "patching_rect": [
      40.0,
      120.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-prepend0",
     "maxclass": "newobj",
     "text": "prepend decaytime",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      40.0,
      160.0,
      85.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-dial1",
     "maxclass": "live.dial",
     "varname": "Ping",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "float"
     ],
     "parameter_enable": 1,
     "patching_rect": [
      130.0,
      40.0,
      44.0,
      48.0
     ],
     "presentation": 1,
     "presentation_rect": [
      64.0,
      10.0,
      44.0,
      48.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "Ping",
       "parameter_shortname": "Ping",
       "parameter_type": 1,
       "parameter_mmin": 0.0,
       "parameter_mmax": 1.0,
       "parameter_initial": [
        0.0
       ],
       "parameter_initial_enable": 1,
       "parameter_unitstyle": 0
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-scale1",
     "maxclass": "newobj",
     "text": "* 1",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ],
     "patching_rect": [
      130.0,
      120.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-prepend1",
     "maxclass": "newobj",
     "text": "prepend pingmode",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      130.0,
      160.0,
      85.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-dial2",
     "maxclass": "live.dial",
     "varname": "Mode",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "float"
     ],
     "parameter_enable": 1,
     "patching_rect": [
      220.0,
      40.0,
      44.0,
      48.0
     ],
     "presentation": 1,
     "presentation_rect": [
      118.0,
      10.0,
      44.0,
      48.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "Mode",
       "parameter_shortname": "Mode",
       "parameter_type": 0,
       "parameter_mmin": 0.0,
       "parameter_mmax": 100.0,
       "parameter_initial": [
        100.0
       ],
       "parameter_initial_enable": 1,
       "parameter_unitstyle": 5
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-scale2",
     "maxclass": "newobj",
     "text": "* 0.01",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ],
     "patching_rect": [
      220.0,
      120.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-prepend2",
     "maxclass": "newobj",
     "text": "prepend lpgmode",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      220.0,
      160.0,
      85.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-dial3",
     "maxclass": "live.dial",
     "varname": "Resonance",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "float"
     ],
     "parameter_enable": 1,
     "patching_rect": [
      310.0,
      40.0,
      44.0,
      48.0
     ],
     "presentation": 1,
     "presentation_rect": [
      172.0,
      10.0,
      44.0,
      48.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "Resonance",
       "parameter_shortname": "Resonance",
       "parameter_type": 0,
       "parameter_mmin": 0.0,
       "parameter_mmax": 100.0,
       "parameter_initial": [
        20.0
       ],
       "parameter_initial_enable": 1,
       "parameter_unitstyle": 5
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-scale3",
     "maxclass": "newobj",
     "text": "* 0.01",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ],
     "patching_rect": [
      310.0,
      120.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-prepend3",
     "maxclass": "newobj",
     "text": "prepend resonance",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      310.0,
      160.0,
      85.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-dial4",
     "maxclass": "live.dial",
     "varname": "Gate",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "float"
     ],
     "parameter_enable": 1,
     "patching_rect": [
      400.0,
      40.0,
      44.0,
      48.0
     ],
     "presentation": 1,
     "presentation_rect": [
      226.0,
      10.0,
      44.0,
      48.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "Gate",
       "parameter_shortname": "Gate",
       "parameter_type": 1,
       "parameter_mmin": 0.0,
       "parameter_mmax": 1.0,
       "parameter_initial": [
        0.0
       ],
       "parameter_initial_enable": 1,
       "parameter_unitstyle": 0
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-scale4",
     "maxclass": "newobj",
     "text": "* 1",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ],
     "patching_rect": [
      400.0,
      120.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-prepend4",
     "maxclass": "newobj",
     "text": "prepend gateon",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      400.0,
      160.0,
      85.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-dial5",
     "maxclass": "live.dial",
     "varname": "Follow",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "float"
     ],
     "parameter_enable": 1,
     "patching_rect": [
      490.0,
      40.0,
      44.0,
      48.0
     ],
     "presentation": 1,
     "presentation_rect": [
      280.0,
      10.0,
      44.0,
      48.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "Follow",
       "parameter_shortname": "Follow",
       "parameter_type": 1,
       "parameter_mmin": 0.0,
       "parameter_mmax": 1.0,
       "parameter_initial": [
        1.0
       ],
       "parameter_initial_enable": 1,
       "parameter_unitstyle": 0
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-scale5",
     "maxclass": "newobj",
     "text": "* 1",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ],
     "patching_rect": [
      490.0,
      120.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-prepend5",
     "maxclass": "newobj",
     "text": "prepend followon",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      490.0,
      160.0,
      85.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-dial6",
     "maxclass": "live.dial",
     "varname": "Threshold",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "float"
     ],
     "parameter_enable": 1,
     "patching_rect": [
      580.0,
      40.0,
      44.0,
      48.0
     ],
     "presentation": 1,
     "presentation_rect": [
      334.0,
      10.0,
      44.0,
      48.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_longname": "Threshold",
       "parameter_shortname": "Threshold",
       "parameter_type": 0,
       "parameter_mmin": 0.1,
       "parameter_mmax": 100.0,
       "parameter_initial": [
        10.0
       ],
       "parameter_initial_enable": 1,
       "parameter_unitstyle": 5
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-scale6",
     "maxclass": "newobj",
     "text": "* 0.01",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ],
     "patching_rect": [
      580.0,
      120.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-prepend6",
     "maxclass": "newobj",
     "text": "prepend thresh",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      580.0,
      160.0,
      85.0,
      22.0
     ]
    }
   }
  ],
  "lines": [
   {
    "patchline": {
     "source": [
      "obj-plugin",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-plugin",
      1
     ],
     "destination": [
      "obj-gen",
      1
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      0
     ],
     "destination": [
      "obj-plugout",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-gen",
      1
     ],
     "destination": [
      "obj-plugout",
      1
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-dial0",
      0
     ],
     "destination": [
      "obj-scale0",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-scale0",
      0
     ],
     "destination": [
      "obj-prepend0",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-prepend0",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-dial1",
      0
     ],
     "destination": [
      "obj-scale1",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-scale1",
      0
     ],
     "destination": [
      "obj-prepend1",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-prepend1",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-dial2",
      0
     ],
     "destination": [
      "obj-scale2",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-scale2",
      0
     ],
     "destination": [
      "obj-prepend2",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-prepend2",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-dial3",
      0
     ],
     "destination": [
      "obj-scale3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-scale3",
      0
     ],
     "destination": [
      "obj-prepend3",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-prepend3",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-dial4",
      0
     ],
     "destination": [
      "obj-scale4",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-scale4",
      0
     ],
     "destination": [
      "obj-prepend4",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-prepend4",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-dial5",
      0
     ],
     "destination": [
      "obj-scale5",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-scale5",
      0
     ],
     "destination": [
      "obj-prepend5",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-prepend5",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-dial6",
      0
     ],
     "destination": [
      "obj-scale6",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-scale6",
      0
     ],
     "destination": [
      "obj-prepend6",
      0
     ]
    }
   },
   {
    "patchline": {
     "source": [
      "obj-prepend6",
      0
     ],
     "destination": [
      "obj-gen",
      0
     ]
    }
   }
  ]
 }
}
