module component.simple_triangle;

import derelict.opengl;
import manager.component;
import util.math;
import util.gl;

class SimpleTriangle : IComponent
{
    bool is_init;
    GLProgram program;

    string vertex_shader_text =
    "attribute vec3 vCol;\n" ~
    "attribute vec2 vPos;\n" ~
    "varying vec3 color;\n" ~
    "uniform float scale;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    gl_Position = vec4(vPos, 0.0, 1.0);\n" ~
    "    color = scale * vCol;\n" ~
    "}\n";

    string fragment_shader_text =
    "varying vec3 color;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    gl_FragColor = vec4(color, 1.0);\n" ~
    "}\n";

    Vertex[3] vertices =
    [
        Vertex( -0.6f, -0.4f, 1f, 0f, 0f ),
        Vertex(  0.6f, -0.4f, 0f, 1f, 0f ),
        Vertex(  0f,  0.6f, 0f, 0f, 1f )
    ];

    void initialize(Context ctx) {
        program = create_program(vertex_shader_text,
                                 fragment_shader_text,
                                 ["vPos", "vCol"],
                                 ["scale"]);

        program.create_buffer!(Vertex[3])(vertices);

        program.describe_attrib("vPos", 2, 5, 0);
        program.describe_attrib("vCol", 3, 5, 2);
    }

    void run(Context ctx) {
        glUseProgram(program.id);
        glUniform1f(program.uniforms["scale"], 0.5);
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
}


