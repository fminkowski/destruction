module component.moving_points;

import derelict.opengl;
import manager.component;
import util.math;
import util.gl;

class MovingPoints : IComponent
{
    import std.math;
    GLProgram program;
    double t = 0;
    uint point1_vao;
    uint point2_vao;
    uint point3_vao;

    string vertex_shader_text =
    "#version 330 core\n" ~
    "layout (location = 0) in vec2 in_pos;\n" ~
    "layout (location = 1) in vec3 in_color;\n" ~
    "out vec3 color;\n" ~
    "uniform float point_size;\n" ~
    "uniform vec2 position;\n" ~
    "void main()\n" ~
    "{\n" ~
    "   gl_Position = vec4(in_pos + position, 0, 1.0);\n" ~
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
                                 ["point_size", "position"]);

        float[5] vertices =
        [
            0.0,  0.0,  1, 0, 0
        ];

        point1_vao = program.create_buffer(vertices);
        program.describe_attrib(point1_vao, "in_pos",  2, 5, 0);
        program.describe_attrib(point1_vao, "in_color", 3, 5, 2);

        point2_vao = program.create_buffer(vertices);
        program.describe_attrib(point2_vao, "in_pos", 2, 5, 0);
        program.describe_attrib(point2_vao, "in_color", 3, 5, 2);

        point3_vao = program.create_buffer(vertices);
        program.describe_attrib(point3_vao, "in_pos", 2, 5, 0);
        program.describe_attrib(point3_vao, "in_color", 3, 5, 2);
    }
    
    void run(Context ctx) {
        program.use();
        t += ctx.dt;
        auto size = 10;
        float[2] position = [0.5f * cos(t), 0];
        program.set_uniform("point_size", [size]);

        program.set_uniform("position", position);
        program.draw_points(point1_vao, 1);

        position = [0.25f * cos(t), 0.25];
        program.set_uniform("position", position);
        program.draw_points(point2_vao, 1);

        position = [0.05f * cos(t), 0.5];
        program.set_uniform("position", position);
        program.draw_points(point3_vao, 1);
    }
}


