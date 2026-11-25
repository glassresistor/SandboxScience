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
    cellSubdivisions: u32,  // padding (unused by render)
    matrixStride: u32,      // padding (unused by render)
    numUrges: u32,          // number of urge types (for category detection)
    neuronRadius: f32,      // world-unit radius for the debug dotted circle
    isDebugConnections: u32,// flag: draw dotted circles around urges/neurons
    numSenseNeurons: u32,   // number of sense-neuron types (splits motor vs sense in the render)
    senseRadius: f32,       // world-unit perception radius for the sense debug dotted circle
};
struct Particle {
    x : f32,
    y : f32,
    vx : f32,
    vy : f32,
    particleType : f32,
    control : f32,
    signal  : f32,
    goalB   : f32,
    driveTarget : f32, // brain: desired metric value (homeostasis setpoint)
    driveScale  : f32, // brain: error normalisation (sensitivity)
    driveGain   : f32, // brain: weight of this urge's error into the network
}
struct Camera {
    centerX: f32,
    centerY: f32,
    scaleX: f32,
    scaleY: f32,
}

const QUAD_VERTICES = array<vec2<f32>, 4>(
    vec2<f32>(-1.0, -1.0),
    vec2<f32>( 1.0, -1.0),
    vec2<f32>(-1.0,  1.0),
    vec2<f32>( 1.0,  1.0)
);

@group(0) @binding(0) var<storage, read> particles: array<Particle>;
@group(0) @binding(1) var<storage, read> colors: array<vec4<f32>>;
@group(1) @binding(0) var<uniform> options: SimOptions;
@group(2) @binding(0) var<uniform> camera: Camera;

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) offset: vec2<f32>,
    @location(1) color: vec4<f32>,
    @location(2) particleType: f32,
    @location(3) isDebugCircle: f32, // 1 = this quad is a debug radius ring (dot pattern at the edge)
    @location(4) shapeType: f32,     // 0=circle (matter), 1=star (urge), 2=diamond (motor neuron), 3=ring (sense neuron)
}

@vertex
fn vertexMain(
    @builtin(instance_index) instanceIndex: u32,
    @builtin(vertex_index) vertexIndex: u32
) -> VertexOutput {
    if (instanceIndex >= options.numParticles) {
        return VertexOutput(vec4f(0.0), vec2f(0.0), vec4f(0.0), 0.0, 0.0, 0.0);
    }
    let particle = particles[instanceIndex];
    let pType = u32(particle.particleType);
    var color = colors[min(pType, arrayLength(&colors) - 1u)];
    // Category split: [matter][urges][motor neurons][sense neurons][dormant]. The dormant entry
    // is the LAST one in the color table, so the sense band ends at arrayLength(colors)-1.
    let lastType = u32(arrayLength(&colors)) - 1u;          // dormant sentinel type code
    let senseBase = lastType - options.numSenseNeurons;      // first sense-neuron type code
    let isSenseType = pType >= senseBase && pType < lastType;
    // Brightness driven by live state (urges glow with |control|, motor neurons pulse with signal).
    // For SENSE neurons `control` holds a BEARING in radians (not a strength), so their glow is
    // driven by the perception magnitude (signal) alone — tolerating the field's new meaning.
    let bright = select(
        1.0 + 0.9 * abs(particle.control) + 0.35 * min(particle.signal, 6.0),
        1.0 + 0.9 * min(particle.signal, 1.0),
        isSenseType
    );
    color = vec4f(color.rgb * bright, color.a);

    // Determine render size + shape. Neurons are ALWAYS drawn in an unmistakable shape and
    // larger than matter: motor neurons = diamond (2x matter size), sense neurons = ring.
    let isUrge = pType >= options.numTypes && pType < options.numTypes + options.numUrges;
    let isMotor = pType >= options.numTypes + options.numUrges && pType < senseBase;
    var size: f32 = options.particleSize;
    var isDebugCircle: f32 = 0.0;
    // Shape type: matter=circle(0), urge=star(1), motor neuron=diamond(2), sense neuron=ring(3)
    var shapeType: f32 = 0.0;
    if (isUrge) { shapeType = 1.0; }
    else if (isMotor) { shapeType = 2.0; size = options.particleSize * 2.0; }
    else if (isSenseType) { shapeType = 3.0; size = options.particleSize * 2.0; }
    if (options.isDebugConnections != 0u) {
        if (isUrge) {
            // Dotted circle at Neuron Radius, star body stays visible in the center
            size = options.neuronRadius;
            isDebugCircle = 1.0;
        } else if (isMotor) {
            // Debug: clearly bigger diamond + dotted ring around it
            size = options.particleSize * 8.0;
            isDebugCircle = 1.0;
        } else if (isSenseType) {
            // Sense neurons: dotted circle at their perception radius, ring body in the center
            size = options.senseRadius;
            isDebugCircle = 1.0;
        }
    }

    let particleCenterPos = vec2f(particle.x, particle.y);
    let cameraScale = vec2f(camera.scaleX, -camera.scaleY);
    let cameraCenter = vec2f(camera.centerX, camera.centerY);
    let transformedCenterPos = fma(particleCenterPos, cameraScale, -cameraCenter * cameraScale);

    // For debug circles, size is in world units (already scaled by cameraScale).
    // For normal particles, size is in screen pixels at zoom=1.
    var vertexOffset: vec2f;
    if (isDebugCircle == 1.0) {
        vertexOffset = QUAD_VERTICES[vertexIndex] * size * cameraScale;
    } else {
        vertexOffset = QUAD_VERTICES[vertexIndex] * size * cameraScale;
    }
    let finalPos = transformedCenterPos + vertexOffset;

    return VertexOutput(
        vec4f(finalPos, 0.0, 1.0),
        QUAD_VERTICES[vertexIndex],
        color,
        f32(pType),
        isDebugCircle,
        shapeType
    );
}

// 5-pointed star boundary radius at a given angle (in [-1,1] quad space)
fn starRadius(angle: f32) -> f32 {
    let sectorAngle = 6.2831853 / 10.0; // π/5 — each half-sector
    var a = (angle + 3.14159265) - (2.0 * sectorAngle) * floor((angle + 3.14159265) / (2.0 * sectorAngle)); // mod without built-in
    if (a > sectorAngle) { a = 2.0 * sectorAngle - a; }
    // Linear interpolation: outer point (a=0) → inner valley (a=sectorAngle)
    let t = a / sectorAngle;
    return mix(1.0, 0.382, t); // outer radius 1.0, inner radius 0.382 (golden ratio star)
}

// Diamond boundary radius at a given angle: |x| + |y| <= 1  →  r(θ) = 1/(|cosθ| + |sinθ|)
fn diamondRadius(angle: f32) -> f32 {
    return 1.0 / (abs(cos(angle)) + abs(sin(angle)));
}

// Fill alpha for a shape, given the quad-space offset and precomputed distances.
// distSq/edge_width are in squared space (edge_width = fwidth(dist_sq)).
fn shapeAlpha(shapeType: f32, off: vec2<f32>, dist: f32, distSq: f32, edge_width: f32) -> f32 {
    let angle = atan2(off.y, off.x);
    if (shapeType == 1.0) {
        // Star (urges)
        let rStar = starRadius(angle);
        return 1.0 - smoothstep(max(0.0, rStar - edge_width), rStar, dist);
    }
    else if (shapeType == 2.0) {
        // Diamond (motor neurons) — unmistakably not a circle
        let rDia = diamondRadius(angle);
        return 1.0 - smoothstep(max(0.0, rDia - edge_width), rDia, dist);
    }
    else if (shapeType == 3.0) {
        // Ring / annulus (sense neurons): outer edge at 1.0, hollow center to ~0.45
        let outer = 1.0 - smoothstep(max(0.0, 1.0 - edge_width), 1.0, dist);
        let hole = smoothstep(0.38, 0.52, dist);
        return outer * hole;
    }
    // Circle (matter particles) — original behavior
    return 1.0 - smoothstep(max(0.0, 1.0 - edge_width), 1.0, distSq);
}

// Shape boundary radius at the fragment's angle (for the electrical border ring).
fn shapeBoundaryR(shapeType: f32, off: vec2<f32>) -> f32 {
    let angle = atan2(off.y, off.x);
    if (shapeType == 1.0) { return starRadius(angle); }
    if (shapeType == 2.0) { return diamondRadius(angle); }
    return 1.0;
}

// Final color for a particle body: shape fill + optional electrical border ring.
fn drawBody(in: VertexOutput, dist: f32, distSq: f32, edge_width: f32) -> vec4f {
    let isElectrical = in.particleType >= f32(options.numTypes);
    let senseBaseF = f32(u32(arrayLength(&colors)) - 1u) - f32(options.numSenseNeurons);
    let isSenseBorder = in.particleType >= senseBaseF && in.particleType < f32(u32(arrayLength(&colors)) - 1u);

    let alpha = shapeAlpha(in.shapeType, in.offset, dist, distSq, edge_width);

    // Draw a thin border ring for electrical particles (follows the shape boundary).
    // Ring-shaped sense neurons skip it — the annulus itself is their outline.
    if (isElectrical && alpha > 0.0 && in.shapeType != 3.0) {
        let boundaryR = shapeBoundaryR(in.shapeType, in.offset);
        let borderDist = boundaryR * 0.85;
        let borderWidth = 0.06;
        if (abs(dist - borderDist) < borderWidth) {
            let borderFade = 1.0 - smoothstep(borderWidth * 0.5, borderWidth, abs(dist - borderDist));
            let borderAlpha = borderFade * options.particleOpacity * alpha;
            let borderColor = select(vec3f(1.0, 1.0, 1.0), vec3f(0.30, 0.95, 1.0), isSenseBorder); // white vs cyan
            return vec4f(borderColor, max(in.color.a * options.particleOpacity * alpha, borderAlpha));
        }
    }

    return vec4f(in.color.rgb, in.color.a * options.particleOpacity * alpha);
}

// Debug radius quads draw the particle body at this fraction of the quad size, centered.
const DEBUG_BODY_SCALE: f32 = 0.16;

@fragment
fn fragmentMain(in: VertexOutput) -> @location(0) vec4f {
    let dist_sq = dot(in.offset, in.offset);
    // fwidth must be called from uniform control flow — compute BOTH before any per-fragment branch.
    let edge_width = fwidth(dist_sq);
    let bodyDistSq = dist_sq / (DEBUG_BODY_SCALE * DEBUG_BODY_SCALE);
    let bodyEdgeWidth = fwidth(bodyDistSq);
    let dist = sqrt(dist_sq);

    // ---- Debug radius-ring mode (urges/neurons when isDebugConnections is on) ----
    if (in.isDebugCircle == 1.0) {
        // The particle body stays visible in the center of the big radius quad, so you can see
        // WHAT the ring belongs to (star urge / diamond motor neuron / ring sense neuron).
        if (dist < DEBUG_BODY_SCALE * 1.4) {
            return drawBody(in, sqrt(bodyDistSq), bodyDistSq, bodyEdgeWidth);
        }

        // Black-and-white dotted ring at the edge of the quad (radius indicator).
        let ringRadius = 0.92;
        let ringWidth = 0.06;
        if (abs(dist - ringRadius) >= ringWidth) { discard; }

        // 16 dots around the circle, alternating black and white
        let angle = atan2(in.offset.y, in.offset.x);
        let segAngle = 6.2831853 * 2.0 / 16.0;
        let segIdx = i32(floor((angle + 3.14159265) / segAngle));
        let localAngle = (angle + 3.14159265) - f32(segIdx) * segAngle;
        if (localAngle >= segAngle * 0.5) { discard; } // every other segment is a gap

        // Soft edge on the dot
        let edgeFade = 1.0 - smoothstep(ringWidth * 0.5, ringWidth, abs(dist - ringRadius));
        if ((segIdx % 2) == 0) {
            return vec4f(1.0, 1.0, 1.0, 0.9 * edgeFade);
        }
        return vec4f(0.0, 0.0, 0.0, 0.9 * edgeFade);
    }

    // ---- Normal particle body (shape-aware) ----
    return drawBody(in, dist, dist_sq, edge_width);
}
