// =============================================================================
// Debug: emit "dotted line" dots connecting each URGE to every NEURON within
// electrical.neuronRadius. One work item per urge; the inner loop scans neurons.
// Dots are written to a grow-only buffer (guarded by an atomic counter) and drawn
// by render_connections.wgsl as small additive billboards -> a light dotted line.
// =============================================================================
struct SimOptions {
    simWidth: f32,
    simHeight: f32,
    gridWidth: u32,
    gridHeight: u32,
    cellSize: f32,
    numParticles: u32,
    numTypes: u32,
    particleSize: f32,
    particleOpacity: f32,
    isWallRepel: u32,
    isWallWrap: u32,
    forceFactor: f32,
    frictionFactor: f32,
    repel: f32,
    extendedGridWidth: u32,
    extendedGridHeight: u32,
    gridOffsetX: u32,
    gridOffsetY: u32,
    mirrorWrapCount: u32,
    cellSubdivisions: u32,
};
struct ElectricalOptions {
    enabled: u32,
    metricMode: u32,
    numUrges: u32,
    numNeurons: u32,
    urgeRadius: f32,
    neuronRadius: f32,
    urgeForce: f32,
    controlGain: f32,
    controlMax: f32,
    neuronInfluence: f32,
    neuronAuthority: f32,
    maxAuthority: f32,
    cohesion: f32,
};
struct Particle {
    x : f32,
    y : f32,
    vx : f32,
    vy : f32,
    particleType : f32,
    control : f32,
    signal  : f32,
}
struct ConnDot {
    pos: vec2<f32>,
    col: vec3<f32>,
};

const MAX_CONN_DOTS: u32 = 32768u;
const DOTS_PER_SEG: u32 = 8u;

@group(0) @binding(0) var<storage, read> particles: array<Particle>;
@group(0) @binding(1) var<storage, read_write> connDots: array<ConnDot>;
@group(0) @binding(2) var<storage, read_write> connCount: atomic<u32>;

@group(1) @binding(0) var<uniform> options: SimOptions;
@group(2) @binding(0) var<uniform> electrical: ElectricalOptions;

const URGE_COL = vec3<f32>(0.45, 0.90, 1.0);   // cyan (matches urges)
const NEURON_COL = vec3<f32>(1.0, 0.62, 0.20); // warm orange (matches neurons)

@compute @workgroup_size(64)
fn emitConnections(@builtin(global_invocation_id) id: vec3u) {
    if (id.x >= electrical.numUrges) { return; }

    let matterCount = options.numParticles - electrical.numUrges - electrical.numNeurons;
    let urgeIdx = matterCount + id.x;
    let neuronStart = matterCount + electrical.numUrges;

    let a = particles[urgeIdx];
    let ax = a.x;
    let ay = a.y;

    let halfW = options.simWidth * 0.5;
    let halfH = options.simHeight * 0.5;
    let wrapping = options.isWallWrap == 1u;
    let nR = max(electrical.neuronRadius, 1.0);
    let nR2 = nR * nR;

    for (var n = neuronStart; n < options.numParticles; n += 1u) {
        let b = particles[n];
        var dx = b.x - ax;
        var dy = b.y - ay;
        if (wrapping) {
            if (dx > halfW) { dx -= options.simWidth; }
            else if (dx < -halfW) { dx += options.simWidth; }
            if (dy > halfH) { dy -= options.simHeight; }
            else if (dy < -halfH) { dy += options.simHeight; }
        }
        let d2 = dx * dx + dy * dy;
        if (d2 >= nR2 || d2 < 0.0001) { continue; }

        // Emit a dotted line from the urge to this neuron.
        for (var k = 0u; k < DOTS_PER_SEG; k += 1u) {
            let t = f32(k) / f32(DOTS_PER_SEG - 1u);
            var px = ax + dx * t;
            var py = ay + dy * t;
            // keep dots inside the sim box when wrapping (the segment may cross a seam)
            if (wrapping) {
                if (px < 0.0) { px += options.simWidth; } else if (px >= options.simWidth) { px -= options.simWidth; }
                if (py < 0.0) { py += options.simHeight; } else if (py >= options.simHeight) { py -= options.simHeight; }
            }
            let idx = atomicAdd(&connCount, 1u);
            if (idx >= MAX_CONN_DOTS) { break; } // buffer full -> stop emitting
            connDots[idx] = ConnDot(vec2<f32>(px, py), mix(URGE_COL, NEURON_COL, t));
        }
    }
}
