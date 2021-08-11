using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace NullSoftware.Effects
{
    // script for lightning test
    [RequireComponent(typeof(MeshRenderer))]
    public class Lightning : MonoBehaviour
    {
        [Header("General")]
        [SerializeField] private Transform _startPoint;
        [SerializeField] private Transform _endPoint;

        [Header("Animation")]
        [SerializeField, Min(0)] private float _appearDuration = 0.3f;
        [SerializeField, Min(0)] private float _disappearDelay = 0.2f;
        [SerializeField, Min(0)] private float _disappearDuration = 0.2f;
        [SerializeField] private float _glowRadius = 0.01f;
        [SerializeField, Range(0, 1)] private float _boltRadiusMin = 0.01f;
        [SerializeField, Range(0, 1)] private float _boltRadiusMax = 0.05f;

        [Header("Events")]
        [SerializeField] private UnityEvent _lightningStriked;

        [Header("Inner Fields")]
        [SerializeField] private MeshRenderer _renderer;

        private void OnValidate()
        {
            if (_renderer == null)
            {
                _renderer = GetComponent<MeshRenderer>();
            }

            if (_lightningStriked == null)
            {
                _lightningStriked = new UnityEvent();
            }
        }

        private void Reset()
        {
            _renderer = GetComponent<MeshRenderer>();
            _lightningStriked = new UnityEvent();
        }

        private Material _material;

        private void Awake()
        {
            _material = _renderer.material;
            _material.SetVector(LightningIds.StartPosition, _startPoint.position);
            _material.SetVector(LightningIds.EndPosition, _endPoint.position);
            _material.SetFloat(LightningIds.Progress, 0);
            _material.SetFloat(LightningIds.GlowRadius, 0);

            StartCoroutine(Animate());
        }

        private IEnumerator Animate()
        {
            while (enabled)
            {
                _material.SetFloat(LightningIds.GlowRadius, _glowRadius);
                _material.SetFloat(LightningIds.NoiseOffset, Time.time);
                _material.SetFloat(LightningIds.BoltRadius, _boltRadiusMin);
                yield return LinearAnimation(_appearDuration, t => 
                {
                    _material.SetFloat(LightningIds.Progress, t);
                    
                });
                _material.SetFloat(LightningIds.BoltRadius, _boltRadiusMax);

                _lightningStriked.Invoke();

                yield return new WaitForSeconds(_disappearDelay);
                yield return LinearAnimation(_disappearDuration, t =>
                {
                    _material.SetFloat(LightningIds.BoltRadius, Mathf.Lerp(_boltRadiusMax, 0, t));
                    _material.SetFloat(LightningIds.GlowRadius, Mathf.Lerp(_glowRadius, 0, t));
                });
                _material.SetFloat(LightningIds.Progress, 0);
                yield return new WaitForSeconds(Random.Range(0.5f, 2f));

            }
        }

        private IEnumerator LinearAnimation(float duration, System.Action<float> onUpdate)
        {
            float elapsed = 0f;
            while (elapsed < duration)
            {
                elapsed += Time.deltaTime;
                float t = Mathf.Clamp01(elapsed / duration);
                onUpdate(t);
                yield return null;
            }
            onUpdate(1);
        }
    }

}