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
struct InfiniteRenderOptions {
    start: vec2<i32>,
    numCopies: vec2<i32>,
};

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
@group(3) @binding(0) var<uniform> glowOptions: GlowOptions;
@group(3) @binding(1) var<uniform> infiniteOptions: InfiniteRenderOptions;

struct VertexOutput {
    @builtin(position) position: vec4f,
    @location(0) offset: vec2<f32>,
    @location(1) color: vec4<f32>,
    @location(2) shapeType: f32,     // 0=circle, 1=star (urge), 2=teardrop (neuron)
    @location(3) orientation: f32,   // angle in radians for teardrop
};

// 5-pointed star boundary radius
fn starRadius(angle: f32) -> f32 {
    let sectorAngle = 6.2831853 / 10.0;
    var a = (angle + 3.14159265) - (2.0 * sectorAngle) * floor((angle + 3.14159265) / (2.0 * sectorAngle));
    if (a > sectorAngle) { a = 2.0 * sectorAngle - a; }
    return mix(1.0, 0.382, a / sectorAngle);
}
// Teardrop boundary radius (point in +X local direction)
fn teardropRadius(localAngle: f32) -> f32 {
    let elongation = 0.55;
    return max(0.15, 1.0 - elongation * cos(localAngle));
}

fn vertex_main(instanceIndex: u32, vertexIndex: u32, size: f32) -> VertexOutput {
    let particleIndex = instanceIndex % options.numParticles;
    let copyInstanceIndex = instanceIndex / options.numParticles;

    let numCopiesX = u32(infiniteOptions.numCopies.x);
    let totalCopies = numCopiesX * u32(infiniteOptions.numCopies.y);
    if (copyInstanceIndex >= totalCopies) {
        return VertexOutput(vec4f(0.0), vec2f(0.0), vec4f(0.0), 0.0, 0.0);
    }
    let copyY = copyInstanceIndex / numCopiesX;
    let copyX = copyInstanceIndex - copyY * numCopiesX;

    let particle = particles[particleIndex];
    var color = colors[min(u32(particle.particleType), arrayLength(&colors) - 1u)];
    let bright = 1.0 + 0.9 * abs(particle.control) + 0.35 * min(particle.signal, 6.0);
    color = vec4f(color.rgb * bright, color.a);

    // Shape detection: matter=circle(0), urge=star(1), neuron=teardrop(2)
    let pType = u32(particle.particleType);
    let lastType = u32(arrayLength(&colors)) - 1u;
    var shapeType: f32 = 0.0;
    if (pType >= options.numTypes && pType < options.numTypes + options.numUrges) { shapeType = 1.0; }
    else if (pType >= options.numTypes + options.numUrges && pType < lastType) { shapeType = 2.0; }
    let orientation = atan2(particle.vy, particle.vx);

    let worldPos = vec2<f32>(
       fma(f32(i32(copyX) + infiniteOptions.start.x), options.simWidth, particle.x),
       fma(f32(i32(copyY) + infiniteOptions.start.y), options.simHeight, particle.y)
    );

    let cameraScale = vec2<f32>(camera.scaleX, -camera.scaleY);
    let cameraCenter = vec2<f32>(camera.centerX, camera.centerY);
    let transformedCenterPos = fma(worldPos, cameraScale, -cameraCenter * cameraScale);

    let quadOffset = QUAD_VERTICES[vertexIndex];
    let vertexOffset = quadOffset * size * cameraScale;
    let finalPos = transformedCenterPos + vertexOffset;

    return VertexOutput(
       vec4<f32>(finalPos, 0.0, 1.0),
       quadOffset,
       color,
       shapeType,
       orientation
    );
}
@vertex
fn infiniteVertex(@builtin(vertex_index) vertexIndex: u32, @builtin(instance_index) instanceIndex: u32) -> VertexOutput {
    return vertex_main(instanceIndex, vertexIndex, options.particleSize);
}
@vertex
fn infiniteVertexGlow(@builtin(instance_index) instanceIndex: u32, @builtin(vertex_index) vertexIndex: u32) -> VertexOutput {
    return vertex_main(instanceIndex, vertexIndex, options.particleSize * glowOptions.glowSize);
}
@vertex
fn infiniteVertexCircle(@builtin(instance_index) instanceIndex: u32, @builtin(vertex_index) vertexIndex: u32) -> VertexOutput {
    return vertex_main(instanceIndex, vertexIndex, options.particleSize);
}

@fragment
fn infiniteFragment(in: VertexOutput) -> @location(0) vec4f {
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

    return vec4f(in.color.rgb, in.color.a * options.particleOpacity * alpha);
}
@fragment
fn infiniteFragmentGlow(in: VertexOutput) -> @location(0) vec4f {
    let dist_sq = dot(in.offset, in.offset);
    if (dist_sq > 1.0) { discard; }

    let falloff = saturate(1.0 - dist_sq);
    let alpha = pow(falloff, glowOptions.glowSteepness) * glowOptions.glowIntensity;

    if (alpha < 0.0001) { discard; }
    return vec4<f32>(in.color.rgb * alpha, alpha);
}
@fragment
fn infiniteFragmentCircle(in: VertexOutput) -> @location(0) vec4f {
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

    let linear_color = pow(in.color.rgb, vec3<f32>(2.2));
    return vec4f(linear_color, in.color.a * options.particleOpacity * alpha);
}
