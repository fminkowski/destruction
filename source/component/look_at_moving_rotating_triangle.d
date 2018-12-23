module component.look_at_moving_rotating_triangle;

import derelict.opengl;
import manager.component;
import util.math;
import util.gl;

class LookAtMovingRotatingTriangle : IComponent
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
    "uniform mat4 view;\n" ~
    "uniform mat4 rot;\n" ~
    "uniform mat4 tran;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    gl_Position = view * tran * rot * vec4(vPos, 0.0, 1.0);\n" ~
    "    color = vCol;\n" ~
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
                                 ["rot", "tran", "view"]);

        float[vertex_count] vertices =
        [
            -0.5f, -0.5f, 1f, 0f, 0f,
             0.5f, -0.5f, 0f, 1f, 0f,
             0.5f,  0.5f, 0f, 0f, 1f
        ];
        vao = program.create_buffer(vertices);

        program.describe_attrib(vao, "vPos", 2, 5, 0);
        program.describe_attrib(vao, "vCol", 3, 5, 2);
    }

    void run(Context ctx) {
        program.use();
        t += ctx.dt;
    
        auto view = look_at(
                    V3!float(0, 1, 1),
                    V3!float(0, 0, 0),
                    V3!float(0, 1, 0)
        );

        auto q = Quat!float(V3!float(0, 0, 1), t);
        auto m = q.rotation_matrix!double;
        auto e = eye4!float();
        auto tran = translate(e, V4!float(0.5f * cos(t), 0, 0, 1)).to_gl;

        program.set_uniform("view", view.to_gl);
        program.set_uniform("rot", m.to_gl);
        program.set_uniform("tran", tran);

        program.draw_array(vao, vertex_count);
    }
}


