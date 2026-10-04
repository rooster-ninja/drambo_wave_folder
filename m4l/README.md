# Max for Live versions

The same 259 folder and vactrol LPG as the Drambo scripts, ported to `gen~` and
wrapped as stereo Max Audio Effects. Requires Live Suite (or Live + Max for Live).

| File | What it is |
| --- | --- |
| `Folder259.maxpat` | Buchla 259-style wavefolder audio effect |
| `VactrolLPG.maxpat` | Vactrol low pass gate audio effect |
| `src/*.genexpr` | The gen~ code inside each device (edit these, then rebuild) |
| `build.py` | Regenerates the `.maxpat` files: `python3 m4l/build.py` |

## Turning a patcher into a Live device

1. In Live, drag **Max Audio Effect** (Max for Live category) onto an audio track.
2. Click the device's **Edit** button to open it in Max.
3. In that Max window, delete the default `plugin~` and `plugout~` objects.
4. Open `Folder259.maxpat` in Max (File → Open), select all, and copy.
5. Paste into the device's editor window.
6. Save. Max saves it as an `.amxd`, so name it **Folder259**. Close the editor.

Repeat the steps for `VactrolLPG.maxpat`. The dials appear on the device in
Live, and they can be automated and mapped like any Live parameter.

## Folder259

| Dial | Notes |
| --- | --- |
| Fold | Drive 0.5×–6×. Automate it or map an LFO for the timbre sweep |
| Symmetry | 50 % = symmetric; either side adds even harmonics |
| Dry/Wet | 100 % = folded only |
| Level | Output into a `tanh` soft limiter; ~50 % ≈ unity |

## VactrolLPG

A Live audio effect gets no MIDI notes, so the gate comes from two sources,
combined:

- **Follow** (on by default): an envelope follower on the input opens the gate
  when the level is above **Threshold**. This works well on drums and plucked
  material.
- **Gate**: a switch you can automate, or map to a MIDI key/pad, to open the
  gate by hand.

| Dial | Notes |
| --- | --- |
| Decay | Vactrol release 20 ms–10 s; the tail lengthens as the cell darkens |
| Ping | On: each gate opening fires a 10 ms strike instead of sustaining |
| Mode | 0 % = VCA only, 100 % = low pass + VCA (classic LPG) |
| Resonance | Filter emphasis (TPT state-variable low pass) |
| Gate / Follow / Threshold | Gate sources, see above |

## Status

These patchers were generated from code and haven't been opened in Max yet.
If gen~ reports an error, it shows in the Max console. Send me the message and
I'll fix the source.
