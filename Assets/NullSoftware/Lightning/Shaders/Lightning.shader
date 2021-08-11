// Lightning shader for Unity URP, single bolt with 3D noise
// Renders a single animated lightning bolt with glow effect, defined by start and end positions
// The bolt itself rendered using ray marching algorithm

Shader "NullSoftware/URP/Lightning"
{
    Properties
    {
        _BoltColor ("Bolt Color", Color) = (0.3, 0.6, 1.0, 1.0)
        _StartPos ("Start Position", Vector) = (0, 10, 0)
        _EndPos ("End Position", Vector) = (0, 0, 0)
        _Progress ("Animation Progress (0-1)", Range(0, 1)) = 1.0
        _BoltRadius ("Bolt Radius", Float) = 0.01
        _GlowRadius ("Glow Radius", Float) = 0.01
        _GlowIntensity ("Glow Intensity", Float) = 0.8
        _NoiseScale ("Noise Scale", Float) = 0.5
        _NoiseOffset ("Noise Offset", Float) = 15.2
        _NoiseAmplitude ("Noise Amplitude", Float) = 0.5
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        LOD 100
        Blend One One
        ZWrite Off
        Cull Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BoltColor;
                float3 _StartPos;
                float3 _EndPos;
                float _Progress;
                float _BoltRadius;
                float _GlowRadius;
                float _GlowIntensity;
                float _NoiseScale;
                float _NoiseOffset;
                float _NoiseAmplitude;
            CBUFFER_END

            // Constants
            #define MAX_STEPS 64
            #define MIN_DIST 0.1
            #define MAX_DIST 1000.0
            #define EPSILON 0.0001

            // Perlin noise functions (adapted from Shadertoy)
            float hash(float p)
            {
                float3 p3 = frac(float3(p, p, p) * 0.1031);
                p3 += dot(p3, p3.yzx + 19.19);
                return frac((p3.x + p3.y) * p3.z);
            }

            float fade(float t)
            {
                return t * t * t * (t * (6.0 * t - 15.0) + 10.0);
            }

            float grad(float hash, float p)
            {
                int i = int(10000.0 * hash);
                return (i & 1) == 0 ? p : -p;
            }

            float perlinNoise1D(float p)
            {
                float pi = floor(p);
                float pf = p - pi;
                float w = fade(pf);
                return lerp(grad(hash(pi), pf), grad(hash(pi + 1.0), pf - 1.0), w) * 2.0;
            }

            float fbm(float pos, int octaves)
            {
                if (pos < 0.0) return 0.0;
                float total = 0.0;
                float frequency = 0.2;
                float amplitude = 1.0;
                for (int i = 0; i < octaves; i++)
                {
                    total += perlinNoise1D(pos * frequency) * amplitude;
                    amplitude *= 0.5;
                    frequency *= 2.0;
                }
                return total;
            }

            float sdCappedCylinder(float3 p, float3 a, float3 b, float r)
            {
                float3 ba = b - a;
                float3 pa = p - a;
                float baba = dot(ba, ba);
                float paba = dot(pa, ba);
                float t = clamp(paba / baba, 0.0, 1.0);
                float3 c = a + t * ba;
                float3 d = p - c;
                return length(d) - r;
            }

            float getGlow(float dist, float radius, float intensity)
            {
                dist = max(dist, 1e-6);
                return pow(radius / dist, intensity);
            }

            void computeLocalFrame(float3 dir, out float3 u, out float3 v)
            {
                float3 arbitrary = abs(dir.y) < 0.999 ? float3(0, 1, 0) : float3(1, 0, 0);
                u = normalize(cross(dir, arbitrary));
                v = normalize(cross(dir, u));
            }

            // signed distance function for the lightning bolt
            float getSDF(float3 p)
            {
                float dist = 1e10;
                float progress = clamp(_Progress, 0.0, 1.0);
                float radius = _BoltRadius;

                // increase radius briefly at contact
                //if (progress > 0.95)
                //    radius = _BoltRadius * 10.0;
                if (progress == 0)
                    return dist;

                // calculate bolt direction and length
                float3 boltDir = normalize(_EndPos - _StartPos);
                float boltLength = length(_EndPos - _StartPos);
                float3 currentEnd = _StartPos + boltDir * boltLength * progress;

                float3 u, v;
                computeLocalFrame(boltDir, u, v);

                // project point onto bolt axis
                float3 pa = p - _StartPos;
                float t = dot(pa, boltDir) / boltLength;
                float param = t * boltLength * _NoiseScale;

                // apply Perlin noise in the plane perpendicular to boltDir
                float3 offset = u * fbm(_NoiseOffset + param, 4) + v * fbm(_NoiseOffset + 0.12 + param, 4);
                offset *= _NoiseAmplitude;

                dist = sdCappedCylinder(p + offset, _StartPos, currentEnd, radius);
                return dist;
            }

            // Raymarching function
            float distanceToScene(float3 cameraPos, float3 rayDir, float start, float end, out float3 glow)
            {
                float depth = start;
                glow = float3(0, 0, 0);
                float dist;

                for (int i = 0; i < MAX_STEPS; i++)
                {
                    float3 p = cameraPos + depth * rayDir;
                    dist = 0.5 * getSDF(p);
                    glow += getGlow(dist, _GlowRadius, _GlowIntensity) * _BoltColor.rgb;

                    if (dist < EPSILON)
                        return depth;

                    depth += dist;

                    if (depth >= end)
                        return end;
                }
                return end;
            }

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.worldPos = TransformObjectToWorld(input.positionOS.xyz);
                output.viewDir = GetWorldSpaceViewDir(output.worldPos);
                output.uv = input.uv;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // Camera position and ray direction
                float3 cameraPos = _WorldSpaceCameraPos;
                float3 rayDir = normalize(-input.viewDir);

                // Raymarch to get glow
                float3 glow = 0;
                float dist = distanceToScene(cameraPos, rayDir, MIN_DIST, MAX_DIST, glow);

                // Output glow with alpha for additive blending
                return half4(glow, 1.0);
            }
            ENDHLSL
        }
    }
}