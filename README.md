# <img src="./public/icon.svg" alt="Sandbox Science Icon" width="40" style="vertical-align: middle;" /> Sandbox Science

**Sandbox Science** is an interactive platform designed to make learning and exploring scientific concepts fun and accessible. The platform offers a variety of simulations, from cellular automata like Game of Life to complex particle interactions in Particle Life, allowing users to dive deep into the fascinating world of science through hands-on, visual experiences.

---

## 🚀 Features

- **Game of Life**: Explore cellular automata and understand the basics of computational biology.
- **Particle Life**: Simulate and observe the behavior of particle systems — including an experimental **Quantum / Electrical** layer that adds *urge* and *neuron* particles on top of the classic bodies (see below).
- **More Simulations**: Dive into various scientific simulations, with more being added regularly.

## 🧬 Quantum / Electrical Layer (Particle Life)

On top of the usual matter colors, the **2D GPU** engine can spawn two extra particle types that act on the bodies in a more "quantum & electrical" way. They live in the left sidebar under the **Quantum / Electrical** panel.

- **Urges** — each urge has its own *objective*: a metric it tries to **maximize** (e.g. the local density of one specific color, the local fraction of that color, or how many other urges are nearby). Every frame it measures that metric and runs a small Hebbian learning rule on an internal `control` value: when its metric is improving it pushes harder, when it's worsening it backs off. That `control` becomes an **attract (+) / repel (−)** field applied to the surrounding matter. Because the fields of nearby urges **add up**, a clump of urges exerts a much stronger combined pull/push than any single one — so you can watch dense urge patches deform the bodies around them.

- **Neurons** — each neuron is a *kind of control*: it has a mode (**attract / repel / self-attract**) and a target color. When a neuron gets close to an urge (within its radius) it nudges that urge's `control` in real time. Crucially, **the more neurons are around an urge, the more authority they grant it** — an isolated urge is only weakly modulated, while a well-wired one can swing its field hard. Neuron "activity" (how many urges it's wired to) also drives how brightly it glows.

- **Single-pass memory** — each particle carries its `control` and `signal` state in the particle buffer, so *the next iteration reads the values written by the previous one*. No second pass is needed: the electrical state simply persists across frames as the simulation sorts and advances.

- **Live visuals** — urges glow brighter as their `|control|` grows (you can literally watch them "learn"), and neurons pulse with their activity. Toggle **Debug links** to draw light dotted lines from each urge to the neurons within its radius, so you can see which control nodes are wired to which urge.

> This layer is experimental and tuned for play. Start with the defaults (≈60 urges / ≈60 neurons) and adjust *Urge Field Strength*, *Control Gain* and *Neuron Influence/Authority* to taste — very high values can make the simulation unstable.

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