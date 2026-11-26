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
    goalB   : f32, // secondary goal index (local k), -1 if none
    driveTarget : f32, // brain: desired metric value (homeostasis setpoint)
    driveScale  : f32, // brain: error normalisation (sensitivity)
    driveGain   : f32, // brain: weight of this urge's error into the network
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

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) offset: vec2<f32>,
    @location(1) color: vec4<f32>,
    @location(2) particleType: f32,
    @location(3) isDebugCircle: f32, // offscreen pass never draws debug radius rings
    @location(4) shapeType: f32,     // 0=circle — the tiled background layer renders bodies as circles
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
    let offset = QUAD_VERTICES[vertexIndex];
    // Clamp to the color-table length so out-of-range/stale types render as the last entry
    // (the invisible dormant slot) instead of reading past the buffer.
    let color = colors[min(pType, arrayLength(&colors) - 1u)];

    let worldPos = vec2f(particle.x, particle.y) + offset * options.particleSize;
    let normalizedPos = (worldPos / vec2f(options.simWidth, options.simHeight)) * 2.0 - 1.0;

    // Must emit the SAME interface as render_normal.wgsl's fragmentMain expects
    // (this vertex is paired with that fragment in renderOffscreenPipeline).
    return VertexOutput(
        vec4f(normalizedPos.x, -normalizedPos.y, 0.0, 1.0),
        offset,
        color,
        f32(pType), // location 2: particleType — fragment uses it for the electrical border ring
        0.0,        // location 3: isDebugCircle — offscreen pass never draws debug radius rings
        0.0         // location 4: shapeType — circle; bodies render as circles in the tiled layer
    );
}