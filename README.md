# Unity URP 3D Lightning shader

Lightning shader for Unity URP, single bolt with 3D noise  
Renders a single animated lightning bolt with glow effect, defined by start and end positions  
The bolt itself rendered using ray marching algorithm  

Demo:  
![demo](https://github.com/nullsoftware/UnityLightning/blob/master/Demo/recorded-demo.gif?raw=true)  

Shader params:  
* **Bolt Color** (Color) - main color of lightning
* **Start Position** (Vector) - start position of the lightning bolt
* **End Position** (Vector) - end position of the lightning bolt
* **Animation Progress** (0-1) (Float) - the "progress" of the lightning bolt. 
* **Bolt Radius** (Float) - radius of lightning bolt
* **Glow Radius** (Float) - radius of lightning glowing effect
* **Glow Intensity** (Float) - lightning glow intensity
* **Noise Scale** (Float) - noise scale of horizontal lightning 3d displacment. Works best with `0.5` value.
* **Noise Offset** (Float) - noice offset, accepts any value.
* **Noise Amplitude** (Float) - defines how much lightning should be displaced. `0` value will just show straight line.
 
![demo](https://github.com/nullsoftware/UnityLightning/blob/master/Demo/shader-params.gif?raw=true)

**WARNING**: Since this shader uses a ray marching algorithm, I do not recommend to use it in real-world projects due to performance limitations.  
