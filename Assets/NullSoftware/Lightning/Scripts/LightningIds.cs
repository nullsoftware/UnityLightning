using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace NullSoftware.Effects
{
    public static class LightningIds
    {
        public static readonly int StartPosition = Shader.PropertyToID("_StartPos");
        public static readonly int EndPosition = Shader.PropertyToID("_EndPos");
        public static readonly int Progress = Shader.PropertyToID("_Progress");
        public static readonly int BoltRadius = Shader.PropertyToID("_BoltRadius");
        public static readonly int GlowRadius = Shader.PropertyToID("_GlowRadius");
        public static readonly int NoiseScale = Shader.PropertyToID("_NoiseScale");
        public static readonly int NoiseOffset = Shader.PropertyToID("_NoiseOffset");
        public static readonly int NoiseAmplitude = Shader.PropertyToID("_NoiseAmplitude");
        public static readonly int Color = Shader.PropertyToID("_Color");
    }
}

