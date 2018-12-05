
uniform mat4 u_MvMatrix;       // A constant representing the combined model/view matrix.
uniform mat4 u_ProjectionMatrix; // A constant representing the projection matrix.

attribute vec4 a_Position;     // Per-vertex position information we will pass in.
attribute vec4 a_Color;        // Per-vertex color information we will pass in.
//attribute vec3 a_Normal;       // Per-vertex normal information we will pass in.
//attribute vec2 a_TextureCoord;

// Out
//varying lowp vec2 v_TextureCoord;

varying vec3 v_Position;       // This will be passed into the fragment shader.
varying vec4 v_Color;          // This will be passed into the fragment shader.
//varying vec3 v_Normal;         // This will be passed into the fragment shader.

// The entry point for our vertex shader.
void main()
{
    // Transform the vertex into eye space.
    v_Position = vec3(u_MvMatrix * a_Position);
    
    // Pass through the color.
    v_Color = a_Color;
    
    // Transform the normal's orientation into eye space.
//    v_Normal = vec3(u_MvMatrix * vec4(a_Normal, 0.0));
    
//    v_TextureCoord = a_TextureCoord;
    
    // gl_Position is a special variable used to store the final position.
    // Multiply the vertex by the matrix to get the final point in normalized screen coordinates.
    vec4 modelViewPosition = u_MvMatrix * a_Position;
    gl_Position = u_ProjectionMatrix * modelViewPosition;
}
