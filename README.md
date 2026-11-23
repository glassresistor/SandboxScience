# <img src="./public/icon.svg" alt="Sandbox Science Icon" width="40" style="vertical-align: middle;" /> Sandbox Science

**Sandbox Science**  ***DEMIURGE EDITION*** is an interactive platform designed to make learning and exploring scientific concepts fun and accessible. The platform offers a variety of simulations, from cellular automata like Game of Life to complex particle interactions in Particle Life, allowing users to dive deep into the fascinating world of science through hands-on, visual experiences.
It alos gives urgs and neurons to some matter and sees what happens!

---

Check it out here: https://glassresistor.github.io/SandboxScience/particle-life

## 🧬 Quantum / Electrical Layer (Particle Life)

* Only shows up in 2D mode with GPU *

On top of the usual matter colors, the **2D GPU** engine can spawn two extra particle types that act on the bodies in a more "quantum & electrical" way. They live in the left sidebar under the **Quantum / Electrical** panel.

- **Urges** — each urge has its own *goal*, derived deterministically from its index (so the population is diverse, with no extra state): a target color and an objective polarity. Every frame it measures that goal's metric and runs a small Hebbian learning rule on an internal `control` value: when the metric moves in the direction it wants it pushes harder, otherwise it backs off. That `control` becomes a signed **attract (+) / repel (−)** intent — but urges do **not** push matter directly. Instead they *recruit* nearby neurons.

- **Neurons** — each neuron is an *actuator* for exactly one color (`m % numTypes`, fixed for its lifetime). In its own step it scans for the urges within `neuronRadius` **of the neuron**, sums their previous-frame signed `control` (falloff-weighted) into a `drive`, then pulls or pushes **only** matter of that single color by that drive. So an urge's effect on matter is always mediated through neurons: it drives them, and they do the pushing/pulling on a per-color basis. A neuron's activity (the magnitude of its drive) also drives how brightly it glows.

- **Single-pass memory** — each particle carries its `control` and `signal` state in the particle buffer, so *the next iteration reads the values written by the previous one*. No second pass is needed: the electrical state simply persists across frames as the simulation sorts and advances.

- **Live visuals** — urges glow brighter as their `|control|` grows (you can literally watch them "learn"), and neurons pulse with their activity. Toggle **Debug links** to draw light dotted lines from each neuron to the urges within its radius, so you can see which urges are driving it.

> This layer is experimental and tuned for play. Start with the defaults (≈60 urges / ≈60 neurons) and adjust *Urge Field Strength* and *Control Gain* to taste — very high values can make the simulation unstable. (*Neuron Influence/Authority* are legacy knobs kept for compat

## 🚀 Features

- **Game of Life**: Explore cellular automata and understand the basics of computational biology.
- **Particle Life**: Simulate and observe the behavior of particle systems — including an experimental **Quantum / Electrical** layer that adds *urge* and *neuron* particles on top of the classic bodies (see below).
- **More Simulations**: Dive into various scientific simulations, with more being added regularly.
ibility and no longer affect the model.*)

## 🎯 Goals

Sandbox Science aims to:

- Make complex scientific concepts easier to understand through visual and interactive experiences.
- Provide an open platform where science enthusiasts can explore, learn, and contribute.
- Encourage collaboration and community-driven development.

## 🛠 Installation

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

## 📦 Build

To build the project for production, use the following command:

```bash
npm run build
```

This will create an optimized version of the project in the \`dist\` directory, ready for deployment.

## 🤝 Contributing

Sandbox Science is open-source and we welcome contributions from the community! Here's how you can get involved:

1. **Fork the repository**
2. **Create a new branch**
   ```bash
   git checkout -b feature/YourFeatureName
   ```
3. **Make your changes**
4. **Submit a pull request**

Please ensure your changes adhere to our [contribution guidelines](CONTRIBUTING.md) and respect the project's code of conduct.

## 💬 Community & Support

Join our [Discord community](https://discord.com/invite/z5yuzkFpCA) to share feedback, suggest new features, and engage with other science enthusiasts. Your insights and contributions help us improve Sandbox Science.

## 📜 License

Copyright (C) 2024-2026 Charly Luzzi (DicSo92)

This project is licensed under the [GNU Affero General Public License v3.0 (AGPL-3.0)](LICENSE). You can use, modify, and distribute the software, but modifications must also be shared under AGPL-3.0. See the [LICENSE](LICENSE) file for more details.

## 🌟 Acknowledgments

- Thanks to everyone who has contributed to this project.
- Special thanks to the open-source community for their continuous support and inspiration.
