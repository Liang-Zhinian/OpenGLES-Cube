//uniform mat4 u_MvpMatrix;
//attribute vec4 a_Position;
//void main()
//{
//    gl_Position = u_MvpMatrix * a_Position;
//}

attribute vec4 a_Position;
attribute vec3 normal;

varying lowp vec4 colorVarying;

uniform mat4 u_MvpMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
    colorVarying = diffuseColor * nDotVP;
    
    gl_Position = u_MvpMatrix * a_Position;
}
