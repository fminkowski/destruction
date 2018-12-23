module component.moving_point;

import derelict.opengl;
import manager.component;
import util.math;
import util.gl;

class MovingPoint : IComponent
{
    import std.math;
    GLProgram program;
    double t = 0;
    uint vao;

    string vertex_shader_text =
    "#version 330 core\n" ~
    "layout (location = 0) in vec2 in_pos;\n" ~
    "layout (location = 1) in vec3 in_color;\n" ~
    "out vec3 color;\n" ~
    "uniform float point_size;\n" ~
    "uniform mat4 tran;\n" ~
    "void main()\n" ~
    "{\n" ~
    "   gl_Position = tran * vec4(in_pos, 0, 1.0);\n" ~
    "   gl_PointSize = point_size;\n" ~
    "   color = in_color;\n" ~
    "}\n";

    string fragment_shader_text =
    "#version 330 core\n" ~
    "in vec3 color;\n" ~
    "out vec4 frag_color;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    frag_color = vec4(color, 1.0);\n" ~
    "}\n";

    void initialize(Context ctx) {
        program = create_program(vertex_shader_text,
                                 fragment_shader_text,
                                 ["in_pos", "in_color"],
                                 ["point_size", "tran"]);

        float[5] vertices =
        [
            0.0,  0.0,  1, 0, 0
        ];
        vao = program.create_buffer(vertices);

        program.describe_attrib(vao, "in_pos", 2, 5, 0);
        program.describe_attrib(vao, "in_color", 3, 5, 2);
    }
    
    void run(Context ctx) {
        program.use();
        t += ctx.dt;
        auto e = eye4!float();
        auto tran = translate(e, V4!float(0.5f * cos(t), 0, 0, 1)).to_gl;
        program.set_uniform("point_size", [10]);
        program.set_uniform("tran", tran);
        program.draw_points(vao, 1);
    }
}


