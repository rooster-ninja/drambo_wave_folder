# drambo_wave_folder

West-coast building blocks for the Drambo **Code** module (Drambo 2.49+).
Paste a script into a Code module and the knobs and inputs appear automatically.

| Script | What it is |
| --- | --- |
| `buchla259_folder.txt` | Buchla 259-style wavefolder: five parallel folding cells with antiderivative anti-aliasing (ADAA) |
| `vactrol_lpg.txt` | Buchla 292-style vactrol low pass gate with gate and ping modes |

Max for Live versions of both (gen~, stereo audio effects) are in [`m4l/`](m4l/README.md).

Classic patch: sine/triangle oscillator → **259 folder** → **vactrol LPG**, with the
note gate on the LPG and an envelope or LFO modulating **Fold**.

## buchla259_folder.txt

Audio in → audio out.

| Param | Range | Notes |
| --- | --- | --- |
| Fold | 0–1 | Input drive 0.5×–6× (square-law knob). Modulate it for the classic timbre sweep |
| Symmetry | 0–1 | DC offset before folding; 0.5 = symmetric, either side adds even harmonics |
| Mix | 0–1 | 1 = folded only, 0 = dry |
| Level | 0–1 | Output gain into a `tanh` soft limiter; ~0.5 ≈ unity |

How it works:

- **Folding function.** The function is piecewise linear:
  `F(x) = 5x + Σ cₖ·max(|x|−γₖ, 0)·sign(x)`.
  It uses five cells with thresholds γ = 0.6, 1.8, 2.994, 4.08 and 5.46. The
  thresholds and gains follow the Buchla 259 model by Esqueda, Pöntynen,
  Parker and Bilbao, *Virtual Analog Model of the Buchla 259 Wavefolder*
  (DAFx-17).
- **Anti-aliasing (ADAA).** The output is the change in the antiderivative
  divided by the change in input:
  `y = (G(x) − G(x[n−1])) / (x − x[n−1])`.
  The antiderivative is `G(x) = 2.5x² + Σ cₖ·max(|x|−γₖ, 0)²/2`.
  This uses per-sample feedback (`xp` and `gp` are read before they are
  assigned).
- **Measured in an offline re-implementation.** With a 1.2 kHz sine at 48 kHz,
  ADAA cuts aliasing by about 7–12 dB compared with naive folding. Very bright
  sources at high Fold still alias. If you need cleaner output, put a gentle
  `lpf` on the oscillator first or lower Fold.
- **DC.** A 6 dB/oct high-pass at 8 Hz removes the DC that Symmetry adds.

## vactrol_lpg.txt

Audio + gate in → audio out.

| Param | Range | Notes |
| --- | --- | --- |
| Decay | 0–20 s | Vactrol release time constant. The tail lengthens as the cell darkens, as on a real LDR |
| Ping | 0–1 | ≤0.5: follows the gate. >0.5: each note fires a 10 ms strike (bongo / plucked) |
| Mode | 0–1 | 0 = VCA only, 1 = low pass + VCA (classic LPG); in between blends the cutoff |
| Resonance | 0–1 | Filter emphasis (mapped to 0–0.7 of the SVF range) |

The vactrol is a one-pole lag with a 2 ms attack. Its release is
`Decay × (1.5 − v)`. The level `v` sets both the cutoff (≈30 Hz–18 kHz,
exponential) and the amplitude (`v²`).

## Notes on the Code module language

- No scientific notation and no leading-dot numbers: write `0.00001`, not `1e-5` or `.1`.
- There is no unary minus in these scripts. Write `0 - x` to stay safe.
- Each expression must stay on one line.
- Scripts run per voice and per channel.
