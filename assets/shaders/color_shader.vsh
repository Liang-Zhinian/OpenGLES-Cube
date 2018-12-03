
//uniform mat4 u_MvpMatrix;
//attribute vec4 a_Position;
//void main()
//{
//    gl_Position = u_MvpMatrix * a_Position;
//}

attribute vec4 a_Position;
attribute vec3 a_Normal;

uniform mat4 u_MvpMatrix;
uniform mat3 u_NormalMatrix;

void main()
{
    gl_Position = u_MvpMatrix * a_Position;
}
