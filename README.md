# <img src="./public/icon.svg" alt="Sandbox Science Icon" width="40" style="vertical-align: middle;" /> Sandbox Science

**Sandbox Science** is an interactive platform designed to make learning and exploring scientific concepts fun and accessible. The platform offers a variety of simulations, from cellular automata like Game of Life to complex particle interactions in Particle Life and Particle Brain, allowing users to dive deep into the fascinating world of science through hands-on, visual experiences.

---

## Particle Life

The classic particle simulator where simple interaction rules produce complex, emergent behaviors. Tweak forces and starting conditions to reveal stable clusters, flowing patterns, and chaotic transitions in real time.

- **CPU renderer** - fully compatible on every device
- **GPU (WebGPU) 2D renderer** - higher FPS, smoother motion, bigger particle counts
- **GPU (WebGPU) 3D renderer** - full 3D simulation with spatial binning

## Particle Brain

Particle Life extended with an emergent **Quantum / Electrical** layer. Only available in **2D GPU** mode.

On top of the usual matter colors, the engine spawns two extra particle types that act on the bodies in a more "quantum & electrical" way:

- **Urges** - goal-seeking particles that learn via Hebbian rules and recruit nearby neurons
- **Neurons** - per-color actuators driven by urge control signals (muscles, eyes, ears, nose)
- **Recurrent Brain Network** - GPU compute pass mapping urge errors to neuron modulations
- **Per-particle Evolvable Drives** - target/scale/gain parameters with GPU mutation for evolutionary dynamics
- **Magnetic (Lorentz) Forces** - per-species charge via golden-angle hash, spiral motion; muscle neurons steer matter via local Lorentz fields

> Experimental and tuned for play. Start with the defaults (60 urges / 60 neurons) and adjust *Urge Field Strength* and *Control Gain* to taste.

### How the Brain Works (Neural Network)

![Particle Brain neural network diagram](./docs/brain-network.svg)

The brain is a **small recurrent neural network running entirely on the GPU** as WebGPU compute passes. It sits on top of the local spatial wiring (urges scan nearby neurons, neurons push/pull one matter color) and adds a *global* control channel: every urge's homeostasis error is fed into one shared network whose output modulates **every** motor neuron at once.

#### The network architecture

One global network for the whole simulation (not per-creature):

```
U urge errors ──▶ [ W_down : U→H ] ──▶ H = 8 hidden units (tanh, recurrent) ──▶ G = 16 output groups ──▶ N ≤ 128 neuron modulations ∈ [−1, 1]
```

- **Input — urge errors.** Each of the U urges carries *per-particle* drive params in its own particle record: `driveTarget` (setpoint), `driveScale` (sensitivity), `driveGain` (weight into the network). Its smoothed metric `signal` (normalized density of its target color, mean 1.0) is compared against the setpoint:

  ```
  error[u] = clamp((driveTarget − signal) / driveScale, −1, 1) × driveGain
  ```

- **Hidden layer — H = 8 recurrent tanh units.** A persistent `brainState[8]` buffer holds the previous frame's activations, giving the network memory:

  ```
  h_new[i] = tanh( Σ_u W_down[i,u]·error[u] + Σ_j W_recur[i,j]·h_prev[j] + b_down[i] )
  ```

- **Output — grouped neurons.** Neurons are bucketed into G = 16 groups (`group(n) = n % 16`); all neurons in a group share one weight vector but keep an individual bias:

  ```
  mod[n] = clamp( tanh(groupW[group(n)] · h_new) + biases[n], −1, 1 )
  ```

- **Weights buffer.** A single 840-float GPU storage buffer: `W_down[512]` (H×64, urges padded), `b_down[8]`, `W_recur[64]`, `groupW[128]`, `biases[128]` (neurons padded). Randomly initialized once (`W_down ±0.3`, `W_recur ±0.05`, `groupW ±0.3`, `biases ±0.15`) and **frozen** unless learning is enabled.

#### Per-frame pipeline

The passes run in this order inside one command encoder (see `ParticleBrainGpu.vue` → `step()`):

1. **`brainStep.wgsl`** — single workgroup of 64 threads. Locates the U urge particles by type (the spatial hash keeps them sorted), computes errors, runs the recurrent network, writes `neuronMods[128]`, persists `h_new` to `brainState` and this frame's errors to `storedErrors[64]`. Runs *before* the force pass so the network output is available the same frame.
2. **`brainLearn.wgsl`** — only dispatched when the *Brain Learning Rate* slider is > 0. Hebbian update of the input weights from this frame's activations and errors:

   ```
   W_down[i,u] += learningRate · h_new[i] · error[u]      (then clamped to ±2)
   ```

   Only `W_down` is touched; biases, recurrent and group weights stay frozen. This lets the network slowly learn which urge errors should drive which hidden units.
3. **Binning + force pass** (`particleComputeForces.wgsl`) — each motor neuron's local drive (sum of nearby urges' learned `control`, with linear falloff) is augmented by the global network output:

   ```
   drive_m += neuronMods[m] × brainGain        (default gain 1.5; 0 disables the brain)
   ```

   The combined drive pushes/pulls only the neuron's target-color matter (`F = drive × urgeForce × falloff`), and `firing = |drive|` feeds the local Lorentz field that spirals matter around active neuron clusters.
4. **Advance** — integrate velocities/positions (plus per-species charge × B-field for magnetic steering).
5. **`brainMutate.wgsl`** — slow evolutionary drift of the *per-urge* drive params, applied every frame with a frame-count-seeded pseudo-Gaussian:

   ```
   driveTarget += g · 0.005 · c          clamped to [0.1, 3.0]
   driveScale  *= 1 + g · 0.003 · c      clamped to [0.05, 2.0]
   driveGain   += g · 0.003 · c          clamped to [0.0, 3.0]
   ```

   where `c = 0.02 + 0.98·hash(localIndex)` is a per-urge *changeability* — low for "rigid" drives (hunger-like), high for plastic ones.

#### The two-tier genome

- **Slow tier:** per-particle drive params (`driveTarget/scale/gain`) live in the particle buffer, so they are cloned/merged/murdered with their urge and drift via `brainMutate` — an evolutionary layer.
- **Fast tier:** the shared network weights adapt online (when learning is on) via the Hebbian `brainLearn` pass — a learning layer.

Both coexist with the *local* per-urge Hebbian/homeostasis control learning that happens inside the force pass itself. Sense neurons (sight/smell/sound) are pure sensors: they read the world into `signal`/`control` but never enter this network's inputs or outputs.

#### Key files

| File | Role |
| --- | --- |
| `assets/particle-brain-gpu/shaders/compute/brainStep.wgsl` | Forward pass: errors → recurrent hidden state → neuron modulations |
| `assets/particle-brain-gpu/shaders/compute/brainLearn.wgsl` | Optional Hebbian update of `W_down` |
| `assets/particle-brain-gpu/shaders/compute/brainMutate.wgsl` | Slow drift of per-urge drive params |
| `assets/particle-brain-gpu/shaders/compute/particleComputeForces.wgsl` | Consumes `neuronMods` in the force pass |
| `components/particle-brain/ParticleBrainGpu.vue` | Pipeline setup, weight init, per-frame dispatch order |
| `stores/particleBrainGPUStore.ts` | Tunables: `brainGain`, `brainLearningRate`, counts |

## Features

- **Game of Life**: Explore cellular automata and understand the basics of computational biology.
- **Particle Life**: Simulate and observe the behavior of particle systems with CPU, GPU 2D, and GPU 3D renderers.
- **Particle Brain**: Particle Life + urges, neurons, brain networks, evolvable drives, and magnetic forces.
- **Hash Life**: Optimized Game of Life using hash-based pattern matching.
- **More Simulations**: Dive into various scientific simulations, with more being added regularly.

## Goals

Sandbox Science aims to:

- Make complex scientific concepts easier to understand through visual and interactive experiences.
- Provide an open platform where science enthusiasts can explore, learn, and contribute.
- Encourage collaboration and community-driven development.

## Installation

To run Sandbox Science locally, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/DicSo92/SandboxScience.git
   cd sandbox-science
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Run the development server:**
   ```bash
   npm run dev
   ```

4. **Open your browser:**
   Visit http://localhost:3000 to explore the site locally.

## Build

To build the project for production, use the following command:

```bash
npm run build
```

This will create an optimized version of the project in the `.output` directory, ready for deployment.

## Testing

Run the test suite:

```bash
npm test
```

Tests cover color-space conversions, palette generators, rule-matrix generators, brain drive behavior, and WGSL stride consistency.

## Contributing

Sandbox Science is open-source and we welcome contributions from the community! Here's how you can get involved:

1. **Fork the repository**
2. **Create a new branch**
   ```bash
   git checkout -b feature/YourFeatureName
   ```
3. **Make your changes**
4. **Submit a pull request**

Please ensure your changes adhere to our [contribution guidelines](CONTRIBUTING.md) and respect the project's code of conduct.

## Community & Support

Join our [Discord community](https://discord.com/invite/z5yuzkFpCA) to share feedback, suggest new features, and engage with other science enthusiasts. Your insights and contributions help us improve Sandbox Science.

## License

Copyright (C) 2024-2026 Charly Luzzi (DicSo92)

This project is licensed under the [GNU Affero General Public License v3.0 (AGPL-3.0)](LICENSE). You can use, modify, and distribute the software, but modifications must also be shared under AGPL-3.0. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

- Thanks to everyone who has contributed to this project.
- Special thanks to the open-source community for their continuous support and inspiration.
