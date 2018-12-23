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
    const vertex_count = 15;

    string vertex_shader_text =
    "#version 330 core\n" ~
    "layout (location = 0) in vec2 vPos;\n" ~
    "layout (location = 1) in vec3 vCol;\n" ~
    "out vec3 color;\n" ~
    "uniform vec3 scale;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    gl_Position = vec4(vPos, 0.0, 1.0);\n" ~
    "    color = scale * vCol;\n" ~
    "}\n";

    string fragment_shader_text =
    "#version 330 core\n" ~
    "in vec3 color;\n" ~
    "out vec4 FragColor;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    FragColor = vec4(color, 1.0);\n" ~
    "}\n";

    uint vao;
    void initialize(Context ctx) {
        program = create_program(vertex_shader_text,
                                 fragment_shader_text,
                                 ["vPos", "vCol"],
                                 ["scale"]);

        float[vertex_count] vertices =
        [
            -0.6f, -0.4f, 1f, 0f, 0f,
             0.6f, -0.4f, 0f, 1f, 0f,
             0.0f,  0.6f, 0f, 0f, 1f
        ];
        vao = program.create_buffer(vertices);

        program.describe_attrib(vao, "vPos", 2, 5, 0);
        program.describe_attrib(vao, "vCol", 3, 5, 2);
    }

    void run(Context ctx) {
        program.use();

        t += ctx.dt;
        auto c = cos(t);
        auto s = sin(t);
        float[] v = [c*c, s*s, c*c];
        program.set_uniform("scale", v);

        program.draw_array(vao, vertex_count);
    }
}


