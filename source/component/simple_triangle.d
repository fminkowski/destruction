module component.simple_triangle;

import derelict.opengl;
import manager.component;
import util.math;
import util.gl;

class SimpleTriangle : IComponent
{
    import std.math;
    GLProgram program;
    double t = 0;
    const vertex_count = 3;

    string vertex_shader_text =
    "attribute vec3 vCol;\n" ~
    "attribute vec2 vPos;\n" ~
    "varying vec3 color;\n" ~
    "uniform vec3 scale;\n" ~
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


    void initialize(Context ctx) {
        program = create_program(vertex_shader_text,
                                 fragment_shader_text,
                                 ["vPos", "vCol"],
                                 ["scale"]);

        Vertex[vertex_count] vertices =
        [
            Vertex( -0.6f, -0.4f, 1f, 0f, 0f ),
            Vertex(  0.6f, -0.4f, 0f, 1f, 0f ),
            Vertex(  0f,  0.6f, 0f, 0f, 1f )
        ];
        program.create_buffer!(Vertex[vertex_count])(vertices);

        program.describe_attrib("vPos", 2, 5, 0);
        program.describe_attrib("vCol", 3, 5, 2);
    }

    void run(Context ctx) {
        program.use();

        t += ctx.dt;
        auto c = cos(t);
        auto s = sin(t);
        float[] v = [c*c, s*s, c*c];
        program.set_uniform("scale", v);

        program.draw(vertex_count);
    }
}


