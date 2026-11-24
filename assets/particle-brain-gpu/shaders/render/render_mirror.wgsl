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
    cellSubdivisions: u32,  // padding
    matrixStride: u32,      // padding
    numUrges: u32,          // number of urge types (for shape detection)
    neuronRadius: f32,      // padding
    isDebugConnections: u32,// padding
    numSenseNeurons: u32,   // number of sense-neuron types
};
struct Particle {
    x: f32,
    y: f32,
    vx: f32,
    vy: f32,
    particleType: f32,
    control: f32,
    signal: f32,
    goalB: f32,
    driveTarget: f32,
    driveScale: f32,
    driveGain: f32,
};
struct Camera {
    centerX: f32,
    centerY: f32,
    scaleX: f32,
    scaleY: f32,
};
struct GlowOptions {
    glowSize: f32,
    glowIntensity: f32,
    glowSteepness: f32,
};
const QUAD_VERTICES = array<vec2<f32>, 4>(
    vec2<f32>(-1.0, -1.0),
    vec2<f32>(1.0, -1.0),
    vec2<f32>(-1.0, 1.0),
    vec2<f32>(1.0, 1.0)
);
const MIRROR_OFFSETS = array<vec2<f32>, 9>(
    vec2<f32>(0.0, 0.0),
    vec2<f32>(-1.0, 0.0),
    vec2<f32>(1.0, 0.0),
    vec2<f32>(0.0, -1.0),
    vec2<f32>(0.0, 1.0),
    vec2<f32>(-1.0, -1.0),
    vec2<f32>(1.0, -1.0),
    vec2<f32>(-1.0, 1.0),
    vec2<f32>(1.0, 1.0)
);

const GRAYSCALE_WEIGHTS: vec3<f32> = vec3<f32>(0.299, 0.587, 0.114);

@group(0) @binding(0) var<storage, read> particles: array<Particle>;
@group(0) @binding(1) var<storage, read> colors: array<vec4<f32>>;
@group(1) @binding(0) var<uniform> options: SimOptions;
@group(2) @binding(0) var<uniform> camera: Camera;
@group(3) @binding(0) var<uniform> glowOptions: GlowOptions;

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) offset: vec2<f32>,
    @location(1) color: vec4<f32>,
    @location(2) @interpolate(flat) mirrorIndex: u32,
    @location(3) shapeType: f32,     // 0=circle, 1=star (urge), 2=teardrop (neuron)
    @location(4) orientation: f32,   // angle in radians for teardrop
}

// 5-pointed star boundary radius
fn starRadius(angle: f32) -> f32 {
    let sectorAngle = 6.2831853 / 10.0;
    var a = mod(angle + 3.14159265, 2.0 * sectorAngle);
    if (a > sectorAngle) { a = 2.0 * sectorAngle - a; }
    return mix(1.0, 0.382, a / sectorAngle);
}
// Teardrop boundary radius (point in +X local direction)
fn teardropRadius(localAngle: f32) -> f32 {
    let elongation = 0.55;
    return max(0.15, 1.0 - elongation * cos(localAngle));
}

fn vertex_main(instanceIndex: u32, vertexIndex: u32, size: f32) -> VertexOutput {
    let mirrorWrapCount = options.mirrorWrapCount;
    let invMWC = select(0.2, 0.11111111, mirrorWrapCount == 9u); // 1/5 or 1/9
    let particleIndex = u32(f32(instanceIndex) * invMWC);
    let mirrorIndex = instanceIndex - particleIndex * mirrorWrapCount;
    if (particleIndex >= options.numParticles) {
        return VertexOutput(vec4f(0.0), vec2f(0.0), vec4f(0.0), 0u, 0.0, 0.0);
    }

    let particle = particles[particleIndex];
    var color = colors[min(u32(particle.particleType), arrayLength(&colors) - 1u)];
    let bright = 1.0 + 0.9 * abs(particle.control) + 0.35 * min(particle.signal, 6.0);
    color = vec4f(color.rgb * bright, color.a);

    // Shape detection: matter=circle(0), urge=star(1), neuron=teardrop(2)
    let pType = u32(particle.particleType);
    let lastType = u32(arrayLength(&colors)) - 1u;
    let senseBase = lastType - options.numSenseNeurons;
    var shapeType: f32 = 0.0;
    if (pType >= options.numTypes && pType < options.numTypes + options.numUrges) { shapeType = 1.0; }
    else if (pType >= options.numTypes + options.numUrges && pType < lastType) { shapeType = 2.0; }
    let orientation = atan2(particle.vy, particle.vx);

    let particlePos = vec2f(particle.x, particle.y);
    let mirrorOffset = MIRROR_OFFSETS[mirrorIndex];
    let simSize = vec2f(options.simWidth, options.simHeight);

    let worldCenterPos = fma(mirrorOffset, simSize, particlePos);
    let cameraScale = vec2f(camera.scaleX, -camera.scaleY);
    let cameraCenter = vec2f(camera.centerX, camera.centerY);
    let transformedCenterPos = fma(worldCenterPos, cameraScale, -cameraCenter * cameraScale);

    let quadOffset = QUAD_VERTICES[vertexIndex & 3u];
    let vertexOffset = quadOffset * size * cameraScale;
    let finalPos = transformedCenterPos + vertexOffset;

    return VertexOutput(
        vec4f(finalPos, 0.0, 1.0),
        quadOffset,
        color,
        mirrorIndex,
        shapeType,
        orientation
    );
}
@vertex
fn mirrorVertex(@builtin(vertex_index) vertexIndex: u32, @builtin(instance_index) instanceIndex: u32) -> VertexOutput {
    return vertex_main(instanceIndex, vertexIndex, options.particleSize);
}
@vertex
fn mirrorVertexGlow(@builtin(instance_index) instanceIndex: u32, @builtin(vertex_index) vertexIndex: u32) -> VertexOutput {
    return vertex_main(instanceIndex, vertexIndex, options.particleSize * glowOptions.glowSize);
}
@vertex
fn mirrorVertexCircle(@builtin(instance_index) instanceIndex: u32, @builtin(vertex_index) vertexIndex: u32) -> VertexOutput {
    return vertex_main(instanceIndex, vertexIndex, options.particleSize);
}

@fragment
fn mirrorFragment(in: VertexOutput) -> @location(0) vec4<f32> {
    let dist_sq = dot(in.offset, in.offset);
    let edge_width = fwidth(dist_sq);
    let dist = sqrt(dist_sq);

    // Shape-aware alpha
    var alpha: f32;
    if (in.shapeType == 1.0) {
        let angle = atan2(in.offset.y, in.offset.x);
        let rStar = starRadius(angle);
        alpha = 1.0 - smoothstep(max(0.0, rStar - edge_width), rStar, dist);
    } else if (in.shapeType == 2.0) {
        let cosA = cos(in.orientation);
        let sinA = sin(in.orientation);
        let localX =  in.offset.x * cosA + in.offset.y * sinA;
        let localY = -in.offset.x * sinA + in.offset.y * cosA;
        let localAngle = atan2(localY, localX);
        let rDrop = teardropRadius(localAngle);
        alpha = 1.0 - smoothstep(max(0.0, rDrop - edge_width), rDrop, dist);
    } else {
        alpha = 1.0 - smoothstep(max(0.0, 1.0 - edge_width), 1.0, dist_sq);
    }

    let isMirror = f32(in.mirrorIndex != 0u);
    let grayscale = dot(in.color.rgb, GRAYSCALE_WEIGHTS);
    let finalColor = mix(in.color.rgb, vec3f(grayscale), isMirror);
    let particleOpacity = mix(options.particleOpacity, options.particleOpacity * 0.75, isMirror);

    return vec4f(finalColor, in.color.a * particleOpacity * alpha);
}
@fragment
fn mirrorFragmentGlow(in: VertexOutput) -> @location(0) vec4<f32> {
    let dist_sq = dot(in.offset, in.offset);
    if (dist_sq > 1.0) { discard; }

    let isMirror = f32(in.mirrorIndex != 0u);
    let grayscale = dot(in.color.rgb, GRAYSCALE_WEIGHTS);
    let finalColor = mix(in.color.rgb, vec3f(grayscale), isMirror);

    let falloff = saturate(1.0 - dist_sq);
    var alpha = pow(falloff, glowOptions.glowSteepness) * glowOptions.glowIntensity;
    alpha = alpha * mix(1.0, 0.75, isMirror);

    if (alpha < 0.0001) { discard; }
    return vec4<f32>(finalColor * alpha, alpha);
}
@fragment
fn mirrorFragmentCircle(in: VertexOutput) -> @location(0) vec4<f32> {
    let dist_sq = dot(in.offset, in.offset);
    let edge_width = fwidth(dist_sq);
    let dist = sqrt(dist_sq);

    var alpha: f32;
    if (in.shapeType == 1.0) {
        let angle = atan2(in.offset.y, in.offset.x);
        let rStar = starRadius(angle);
        alpha = 1.0 - smoothstep(max(0.0, rStar - edge_width), rStar, dist);
    } else if (in.shapeType == 2.0) {
        let cosA = cos(in.orientation);
        let sinA = sin(in.orientation);
        let localX =  in.offset.x * cosA + in.offset.y * sinA;
        let localY = -in.offset.x * sinA + in.offset.y * cosA;
        let localAngle = atan2(localY, localX);
        let rDrop = teardropRadius(localAngle);
        alpha = 1.0 - smoothstep(max(0.0, rDrop - edge_width), rDrop, dist);
    } else {
        alpha = 1.0 - smoothstep(max(0.0, 1.0 - edge_width), 1.0, dist_sq);
    }

    let isMirror = f32(in.mirrorIndex != 0u);
    let grayscale = dot(in.color.rgb, GRAYSCALE_WEIGHTS);
    let finalColor = mix(in.color.rgb, vec3f(grayscale), isMirror);
    let linear_color = pow(finalColor, vec3<f32>(2.2));
    let particleOpacity = mix(options.particleOpacity, options.particleOpacity * 0.75, isMirror);

    return vec4f(linear_color, in.color.a * particleOpacity * alpha);
}
