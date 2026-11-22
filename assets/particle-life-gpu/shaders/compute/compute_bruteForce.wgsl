// Particle Life — 2D GPU BRUTE-FORCE force pass (with Urge / Neuron "quantum-electrical" layer)
// Same particle layout & electrical semantics as particleComputeForces.wgsl; O(N^2) neighbor scan.
struct InteractionMatrix { data: array<u32> };
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

fn get_interaction(index: u32, numTypes: u32) -> vec3<f32> {
    let word = interactions.data[index];
    let rule = (f32((word >> 0u) & 0xFFu) / 255.0) * 2.0 - 1.0;
    let minR = f32((word >> 8u) & 0xFFu);
    let maxR = f32((word >> 16u) & 0xFFFFu);
    return vec3<f32>(rule, minR, maxR);
}

fn cat(t: u32) -> u32 {
    if (t < options.numTypes) { return 0u; }
    if (t < options.numTypes + electrical.numUrges) { return 1u; }
    return 2u;
}

@group(0) @binding(0) var<storage, read> particles: array<Particle>;
@group(0) @binding(1) var<storage, read_write> particlesDestination : array<Particle>;
@group(0) @binding(2) var<storage, read> interactions: InteractionMatrix;
@group(1) @binding(0) var<uniform> options: SimOptions;
@group(2) @binding(0) var<uniform> deltaTime: f32;
@group(3) @binding(0) var<uniform> electrical : ElectricalOptions;

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) id: vec3<u32>) {
    let i = id.x;
    if (i >= options.numParticles) { return; }

    let half_width = options.simWidth * 0.5;
    let half_height = options.simHeight * 0.5;
    let is_wrapping = options.isWallWrap == 1u;

    var particle = particles[i];
    let typeA = u32(particle.particleType);
    let myCat = cat(typeA);
    let isMatter = myCat == 0u;
    let isUrge = myCat == 1u;
    let isNeuron = myCat == 2u;
    let urgeTarget = (typeA - options.numTypes) % options.numTypes;

    var velocitySum = vec2<f32>(0.0, 0.0);
    var metricCount: f32 = 0.0;
    var matterTotal: f32 = 0.0;
    var nearUrges: f32 = 0.0;
    var neuronBias: f32 = 0.0;
    var neuronCount: u32 = 0u;
    var cohesionForce = vec2<f32>(0.0, 0.0);

    let eOn = electrical.enabled != 0u;
    let eR = max(electrical.urgeRadius, 1.0);
    let nR = max(electrical.neuronRadius, 1.0);

    for (var j = 0u; j < options.numParticles; j = j + 1u) {
        if (i == j) { continue; }

        var other = particles[j];
        let typeB = u32(other.particleType);
        let oCat = cat(typeB);
        var dx = other.x - particle.x;
        var dy = other.y - particle.y;

        if (is_wrapping) {
            if (dx > half_width) { dx -= options.simWidth; }
            else if (dx < -half_width) { dx += options.simWidth; }
            if (dy > half_height) { dy -= options.simHeight; }
            else if (dy < -half_height) { dy += options.simHeight; }
        }

        let dist = sqrt(dx * dx + dy * dy);
        if (dist < 0.0001) { continue; }
        let dir = vec2f(dx, dy) / dist;

        // ---- classic matter <-> matter rule --------------------------------------------
        if (isMatter && oCat == 0u) {
            let index = typeA * options.numTypes + typeB;
            let params = get_interaction(index, options.numTypes);
            let maxR = params.z;
            if (dist < maxR) {
                let rule = params.x;
                let minR = params.y;
                var force = 0.0;
                if (dist < minR) {
                    force = (dist / minR - 1.0) * options.repel;
                } else {
                    let mid = (minR + maxR) / 2.0;
                    let slope = rule / (mid - minR);
                    force = -(slope * abs(dist - mid)) + rule;
                }
                if (force != 0.0) { velocitySum += dir * force; }
            }
        }

        if (!eOn) { continue; }

        // ---- urge field on matter (additive when clumped) ------------------------------
        if (isMatter && oCat == 1u && dist < eR) {
            let fall = max(0.0, 1.0 - dist / eR);
            velocitySum += dir * (other.control * fall * electrical.urgeForce);
        }

        // ---- urge metric + neuron modulation -------------------------------------------
        if (isUrge) {
            if (oCat == 0u && dist < eR) {
                matterTotal += 1.0;
                if (typeB == urgeTarget) { metricCount += 1.0; }
            }
            if (oCat == 2u && dist < nR) {
                let mIdx = typeB - options.numTypes - electrical.numUrges;
                let mode = mIdx % 3u;
                let nTarget = (mIdx / 3u) % options.numTypes;
                var s: f32 = 1.0;
                if (mode == 1u) { s = -1.0; }
                else if (mode == 2u) { s = 0.5; }
                let w = select(0.3, 1.0, nTarget == urgeTarget);
                let fall = max(0.0, 1.0 - dist / nR);
                neuronBias += s * fall * w;
                neuronCount += 1u;
            }
            if (oCat == 1u && dist < eR) { nearUrges += 1.0; }
        }

        // ---- neuron activity -----------------------------------------------------------
        if (isNeuron && oCat == 1u && dist < nR) { nearUrges += 1.0; }

        // ---- cohesion ------------------------------------------------------------------
        if (isUrge || isNeuron) {
            if (oCat == 0u && dist < eR) {
                let fall = max(0.0, 1.0 - dist / eR);
                cohesionForce += dir * (fall * electrical.cohesion);
            } else if (oCat == 1u || oCat == 2u) {
                if (dist < 8.0) { cohesionForce -= dir * (electrical.cohesion * 2.0); }
                else if (dist < eR * 0.6) { cohesionForce += dir * (electrical.cohesion * 0.3); }
            }
        }
    }

    let forceFactor = options.forceFactor * deltaTime * 60.0;

    if (isMatter) {
        particle.vx += velocitySum.x * forceFactor;
        particle.vy += velocitySum.y * forceFactor;
    } else {
        let cf = electrical.cohesion * 0.5;
        particle.vx += cohesionForce.x * forceFactor * cf;
        particle.vy += cohesionForce.y * forceFactor * cf;

        if (isUrge) {
            var M: f32;
            if (electrical.metricMode == 1u) {
                M = select(0.0, metricCount / matterTotal, matterTotal > 0.0);
            } else if (electrical.metricMode == 2u) {
                M = nearUrges;
            } else {
                M = metricCount;
            }
            let dM = M - particle.signal;
            var newControl = particle.control + electrical.controlGain * dM;
            let authority = min(1.0 + f32(neuronCount) * electrical.neuronAuthority, electrical.maxAuthority);
            newControl += neuronBias * electrical.neuronInfluence * authority;
            newControl = clamp(newControl, -electrical.controlMax, electrical.controlMax);
            particle.control = newControl;
            particle.signal = mix(particle.signal, M, 0.15);
        } else {
            particle.signal = mix(particle.signal, nearUrges, 0.2);
            particle.control = 0.0;
        }
    }

    particlesDestination[i] = particle;
};
