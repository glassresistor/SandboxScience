// Quick benchmark: how long does one full generation take at various sizes?
const sizes = [
    { np: 200, nu: 10, nn: 30, h: 6, g: 6, ticks: 80, pop: 10 },
    { np: 300, nu: 20, nn: 60, h: 8, g: 8, ticks: 150, pop: 15 },
];

for (const s of sizes) {
    const t0 = performance.now();
    // Simulate one individual for `ticks` ticks
    let totalOps = 0;
    for (let t = 0; t < s.ticks; t++) {
        // Approximate cost: np * avg_neighbors distance checks
        totalOps += s.np * 50 + s.nn * 40; // rough estimate
    }
    const elapsed = performance.now() - t0;
    console.log(`Config np=${s.np} nu=${s.nu} nn=${s.nn}: estimated ${totalOps} ops, would take ~${(elapsed / s.ticks).toFixed(2)}ms/tick (measuring overhead only)`);
}

// Real test: time 100 ticks of the actual physics
import { World } from './world.ts';
console.log('Done');
