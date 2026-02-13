#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

// 桶形失真 (Barrel Distortion) - 模擬 CRT 螢幕曲面
float2 barrelDistort(float2 uv, float strength) {
    float2 center = uv - float2(0.5);
    float r2 = dot(center, center);
    uv = uv + center * r2 * strength;
    return uv;
}

// 主要 CRT 效果 shader
// 包含：桶形失真、掃描線、色差、暗角、閃爍
[[stitchable]]
half4 crtEffect(float2 position, SwiftUI::Layer layer, float time, float2 size) {
    float2 uv = position / size;

    // === 桶形失真 ===
    uv = barrelDistort(uv, 0.25);

    // 邊界檢查：超出範圍顯示黑色
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return half4(0.0, 0.0, 0.0, 1.0);
    }

    // === 色差 (Chromatic Aberration) ===
    float aberration = 0.0008;
    float2 samplePos = uv * size;

    half4 col;
    col.r = layer.sample(float2(uv.x + aberration, uv.y) * size).r;
    col.g = layer.sample(samplePos).g;
    col.b = layer.sample(float2(uv.x - aberration, uv.y) * size).b;
    col.a = layer.sample(samplePos).a;

    // === 掃描線 (Scanlines) ===
    float scanlineFreq = size.y * 0.75;
    float scanline = sin(uv.y * scanlineFreq * 3.14159) * 0.5 + 0.5;
    scanline = pow(scanline, 0.8);
    col.rgb *= half3(0.65 + 0.35 * scanline);

    // === 滾動掃描線 (Rolling Scanline) ===
    float rollLine = fract(time * 0.05);
    float rollDist = abs(uv.y - rollLine);
    float rollEffect = 1.0 - smoothstep(0.0, 0.03, rollDist) * 0.06;
    col.rgb *= half3(rollEffect);

    // === 閃爍 (Flicker) ===
    float flicker = 1.0 + 0.008 * sin(time * 120.0);
    col.rgb *= half3(flicker);

    // === 暗角 (Vignette) ===
    float2 vigUV = uv * (1.0 - uv);
    float vig = vigUV.x * vigUV.y * 20.0;
    vig = pow(clamp(vig, 0.0, 1.0), 0.35);
    col.rgb *= half3(vig);

    // === 磷光殘影 (Phosphor Persistence) ===
    // 輕微的綠色偏移，模擬磷光
    col.g *= 1.05;

    return col;
}

// 磷光發光效果 (用於文字發光)
[[stitchable]]
half4 phosphorGlow(float2 position, SwiftUI::Layer layer, float2 size, float intensity) {
    half4 original = layer.sample(position);

    // 對周圍像素取樣，製造發光效果
    half4 bloom = half4(0);
    float radius = 2.0;
    float samples = 0.0;

    for (float x = -radius; x <= radius; x += 1.0) {
        for (float y = -radius; y <= radius; y += 1.0) {
            float2 offset = float2(x, y);
            float weight = 1.0 / (1.0 + length(offset));
            bloom += layer.sample(position + offset) * half4(weight);
            samples += weight;
        }
    }
    bloom /= half4(samples);

    return original + bloom * half4(intensity);
}
