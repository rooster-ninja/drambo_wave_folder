#!/usr/bin/env python3
"""Build the Max for Live patchers (.maxpat) from the gen~ sources in src/.

Each patcher is plugin~ -> gen~ (codebox) -> plugout~, with one live.dial per
gen~ Param. Run: python3 m4l/build.py
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent

# unitstyle: 1 = float, 2 = time (ms), 5 = percent
DEVICES = {
    "Folder259": {
        "src": "folder259.genexpr",
        "dials": [
            # (Live name, gen~ param, min, max, initial, unitstyle, scale to gen~)
            ("Fold", "foldamt", 0, 100, 40, 5, 0.01),
            ("Symmetry", "symmetry", 0, 100, 50, 5, 0.01),
            ("Dry/Wet", "drywet", 0, 100, 100, 5, 0.01),
            ("Level", "outlevel", 0, 100, 50, 5, 0.01),
        ],
    },
    "VactrolLPG": {
        "src": "vactrol_lpg.genexpr",
        "dials": [
            ("Decay", "decaytime", 20, 10000, 400, 2, 0.001),
            ("Ping", "pingmode", 0, 1, 0, 0, 1),
            ("Mode", "lpgmode", 0, 100, 100, 5, 0.01),
            ("Resonance", "resonance", 0, 100, 20, 5, 0.01),
            ("Gate", "gateon", 0, 1, 0, 0, 1),
            ("Follow", "followon", 0, 1, 1, 0, 1),
            ("Threshold", "thresh", 0.1, 100, 10, 5, 0.01),
        ],
    },
}

APPVERSION = {"major": 8, "minor": 6, "revision": 0, "architecture": "x64", "modernui": 1}


def box(id_, text, rect, ninlets, noutlets, outlettype, **extra):
    b = {
        "id": id_,
        "maxclass": "newobj",
        "text": text,
        "numinlets": ninlets,
        "numoutlets": noutlets,
        "outlettype": outlettype,
        "patching_rect": rect,
    }
    b.update(extra)
    return {"box": b}


def line(src, src_out, dst, dst_in):
    return {"patchline": {"source": [src, src_out], "destination": [dst, dst_in]}}


def gen_patcher(code):
    boxes = [
        {"box": {
            "id": "obj-code", "maxclass": "codebox", "code": code,
            "fontface": 0, "fontname": "<Monospaced>", "fontsize": 12.0,
            "numinlets": 2, "numoutlets": 2, "outlettype": ["", ""],
            "patching_rect": [50.0, 60.0, 600.0, 500.0],
        }},
        box("obj-in1", "in 1", [50.0, 20.0, 30.0, 22.0], 0, 1, [""]),
        box("obj-in2", "in 2", [620.0, 20.0, 30.0, 22.0], 0, 1, [""]),
        box("obj-out1", "out 1", [50.0, 580.0, 35.0, 22.0], 1, 0, []),
        box("obj-out2", "out 2", [615.0, 580.0, 35.0, 22.0], 1, 0, []),
    ]
    lines = [
        line("obj-in1", 0, "obj-code", 0),
        line("obj-in2", 0, "obj-code", 1),
        line("obj-code", 0, "obj-out1", 0),
        line("obj-code", 1, "obj-out2", 0),
    ]
    return {
        "fileversion": 1, "appversion": APPVERSION, "classnamespace": "dsp.gen",
        "rect": [100.0, 100.0, 720.0, 640.0], "boxes": boxes, "lines": lines,
    }


def device(name, spec):
    code = (HERE / "src" / spec["src"]).read_text()
    boxes = [
        box("obj-plugin", "plugin~", [40.0, 260.0, 60.0, 22.0], 2, 2, ["signal", "signal"]),
        box("obj-gen", "gen~", [40.0, 320.0, 300.0, 22.0], 2, 2, ["signal", "signal"],
            patcher=gen_patcher(code)),
        box("obj-plugout", "plugout~", [40.0, 380.0, 60.0, 22.0], 2, 0, []),
    ]
    lines = [
        line("obj-plugin", 0, "obj-gen", 0),
        line("obj-plugin", 1, "obj-gen", 1),
        line("obj-gen", 0, "obj-plugout", 0),
        line("obj-gen", 1, "obj-plugout", 1),
    ]
    for i, (label, param, lo, hi, init, unit, scale) in enumerate(spec["dials"]):
        x = 40.0 + i * 90.0
        dial, sc, pre = f"obj-dial{i}", f"obj-scale{i}", f"obj-prepend{i}"
        boxes.append({"box": {
            "id": dial, "maxclass": "live.dial", "varname": label,
            "numinlets": 1, "numoutlets": 2, "outlettype": ["", "float"],
            "parameter_enable": 1,
            "patching_rect": [x, 40.0, 44.0, 48.0],
            "presentation": 1, "presentation_rect": [10.0 + i * 54.0, 10.0, 44.0, 48.0],
            "saved_attribute_attributes": {"valueof": {
                "parameter_longname": label,
                "parameter_shortname": label,
                "parameter_type": 1 if unit == 0 else 0,  # 1 = int (switches), 0 = float
                "parameter_mmin": float(lo),
                "parameter_mmax": float(hi),
                "parameter_initial": [float(init)],
                "parameter_initial_enable": 1,
                "parameter_unitstyle": unit,
            }},
        }})
        boxes.append(box(sc, f"* {scale}", [x, 120.0, 60.0, 22.0], 2, 1, ["float"]))
        boxes.append(box(pre, f"prepend {param}", [x, 160.0, 85.0, 22.0], 1, 1, [""]))
        lines += [line(dial, 0, sc, 0), line(sc, 0, pre, 0), line(pre, 0, "obj-gen", 0)]
    return {"patcher": {
        "fileversion": 1, "appversion": APPVERSION, "classnamespace": "box",
        "rect": [100.0, 100.0, 900.0, 520.0], "openinpresentation": 1,
        "default_fontsize": 10.0, "boxes": boxes, "lines": lines,
    }}


if __name__ == "__main__":
    for name, spec in DEVICES.items():
        out = HERE / f"{name}.maxpat"
        out.write_text(json.dumps(device(name, spec), indent=1) + "\n")
        print("wrote", out.relative_to(HERE.parent))
