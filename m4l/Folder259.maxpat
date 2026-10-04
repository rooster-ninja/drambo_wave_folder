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
         "code": "// Buchla 259-style wavefolder (gen~ codebox), stereo\n// Same model as ../../buchla259_folder.txt: five parallel folding cells\n// (Esqueda, Poentynen, Parker, Bilbao, DAFx-17) with first-order ADAA.\n\n// folding function F(x) = 5x + sum(c_k * max(|x| - g_k, 0) * sign(x))\nfoldF(x) {\n\tax = abs(x);\n\tr1 = max(ax - 0.6, 0);\n\tr2 = max(ax - 2.994, 0);\n\tr3 = max(ax - 5.46, 0);\n\tr4 = max(ax - 1.8, 0);\n\tr5 = max(ax - 4.08, 0);\n\treturn 5 * x + sign(x) * (10.1347 * r4 + 9.7198 * r5 - 9.9996 * r1 - 10.4664 * r2 - 6.062 * r3);\n}\n\n// antiderivative G(x), each cell integrates to c_k * r_k^2 / 2\nfoldG(x) {\n\tax = abs(x);\n\tr1 = max(ax - 0.6, 0);\n\tr2 = max(ax - 2.994, 0);\n\tr3 = max(ax - 5.46, 0);\n\tr4 = max(ax - 1.8, 0);\n\tr5 = max(ax - 4.08, 0);\n\treturn 2.5 * x * x + 0.5 * (10.1347 * r4 * r4 + 9.7198 * r5 * r5 - 9.9996 * r1 * r1 - 10.4664 * r2 * r2 - 6.062 * r3 * r3);\n}\n\nParam foldamt(0.4, min=0, max=1);\nParam symmetry(0.5, min=0, max=1);\nParam drywet(1, min=0, max=1);\nParam outlevel(0.5, min=0, max=1);\n\nHistory fs(0.4);\nHistory ss(0.5);\nHistory xp1(0);\nHistory gp1(0);\nHistory xp2(0);\nHistory gp2(0);\n\n// de-zipper the knobs (30 Hz one-pole)\nk = 1 - exp(-twopi * 30 / samplerate);\nfs = fs + (foldamt - fs) * k;\nss = ss + (symmetry - ss) * k;\n\n// input in \"volts\": 0.5x .. 6x drive, offset +-2 V\ndrive = 0.5 + fs * fs * 5.5;\noffset = (ss - 0.5) * 4;\n\n// left: ADAA y = (G(x) - G(x[n-1])) / (x - x[n-1]), F(x) when the step is tiny\nx1 = in1 * drive + offset;\ng1 = foldG(x1);\nd1 = x1 - xp1;\ny1 = abs(d1) < 0.00001 ? foldF(x1) : (g1 - gp1) / (abs(d1) < 0.00001 ? 1 : d1);\nxp1 = x1;\ngp1 = g1;\n\n// right\nx2 = in2 * drive + offset;\ng2 = foldG(x2);\nd2 = x2 - xp2;\ny2 = abs(d2) < 0.00001 ? foldF(x2) : (g2 - gp2) / (abs(d2) < 0.00001 ? 1 : d2);\nxp2 = x2;\ngp2 = g2;\n\n// normalise (peaks around +-3.4), remove DC from Symmetry, mix, soft limit\nw1 = dcblock(y1 * 0.3);\nw2 = dcblock(y2 * 0.3);\nout1 = tanh(mix(in1, w1, drywet) * outlevel * 2);\nout2 = tanh(mix(in2, w2, drywet) * outlevel * 2);\n",
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
     "varname": "Fold",
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
       "parameter_longname": "Fold",
       "parameter_shortname": "Fold",
       "parameter_type": 0,
       "parameter_mmin": 0.0,
       "parameter_mmax": 100.0,
       "parameter_initial": [
        40.0
       ],
       "parameter_initial_enable": 1,
       "parameter_unitstyle": 5
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-scale0",
     "maxclass": "newobj",
     "text": "* 0.01",
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
     "text": "prepend foldamt",
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
     "varname": "Symmetry",
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
       "parameter_longname": "Symmetry",
       "parameter_shortname": "Symmetry",
       "parameter_type": 0,
       "parameter_mmin": 0.0,
       "parameter_mmax": 100.0,
       "parameter_initial": [
        50.0
       ],
       "parameter_initial_enable": 1,
       "parameter_unitstyle": 5
      }
     }
    }
   },
   {
    "box": {
     "id": "obj-scale1",
     "maxclass": "newobj",
     "text": "* 0.01",
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
     "text": "prepend symmetry",
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
     "varname": "Dry/Wet",
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
       "parameter_longname": "Dry/Wet",
       "parameter_shortname": "Dry/Wet",
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
     "text": "prepend drywet",
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
     "varname": "Level",
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
       "parameter_longname": "Level",
       "parameter_shortname": "Level",
       "parameter_type": 0,
       "parameter_mmin": 0.0,
       "parameter_mmax": 100.0,
       "parameter_initial": [
        50.0
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
     "text": "prepend outlevel",
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
   }
  ]
 }
}
