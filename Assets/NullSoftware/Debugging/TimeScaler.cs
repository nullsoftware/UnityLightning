using UnityEngine;
using UnityEngine.InputSystem;

namespace NullSoftware.Debugging
{
    public class TimeScaler : MonoBehaviour
    {
        private GUIStyle _labelStyle;

        private void Update()
        {
            float scrollDelta = GetInputScrollDelta();

            if (scrollDelta != 0)
            {
                Time.timeScale = Mathf.Clamp(Time.timeScale + scrollDelta * 0.1f, 0, 1f);
                scrollDelta = 0;
            }
        }

        private void OnGUI()
        {
            if (_labelStyle == null)
            {
                _labelStyle = new GUIStyle(GUI.skin.label)
                {
                    fontSize = 24,
                    normal = { textColor = Color.red }
                };
            }
            float scale = Time.timeScale * 100;
            GUI.Label(new Rect(10, 10, 400, 200), $"Time Scale: {scale:F0}%", _labelStyle);
        }

        private float GetInputScrollDelta()
        {
            if (Input.GetKeyDown(KeyCode.E))
                return 1f;
            else if (Input.GetKeyDown(KeyCode.Q))
                return -1f;
            
            return 0;
        }
    }

}
