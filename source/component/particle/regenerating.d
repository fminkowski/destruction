module component.particle.regenerating;

import derelict.opengl;
import manager.component;
import util.math;
import util.gl;

struct Particle {
    V2!float p;
    V2!float v;
    float life;

    import std.random;
    void reset() {
        auto spread = 5.0;
        p.x = uniform(-spread, spread) / 50f;
        p.y = uniform(-spread, spread) / 50f;
        v.x = uniform(-10, 10) / 10f;
        v.y = uniform(-10, 10) / 10f;
        life = 0;
    }
}

class RegeneratingParticles : IComponent
{
    import std.math;
    GLProgram program;
    double t = 0;

    string vertex_shader_text =
    "#version 330 core\n" ~
    "layout (location = 0) in vec2 in_pos;\n" ~
    "layout (location = 1) in vec3 in_color;\n" ~
    "out vec4 color;\n" ~
    "uniform vec2 offset;\n" ~
    "uniform vec4 u_color;\n" ~
    "void main()\n" ~
    "{\n" ~
    "   gl_Position = vec4(in_pos + offset, 0.0, 1.0);\n" ~
    "   color = u_color * vec4(in_color, 1.0);\n" ~
    "}\n";

    string fragment_shader_text =
    "#version 330 core\n" ~
    "in vec4 color;\n" ~
    "out vec4 frag_color;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    frag_color = color;\n" ~
    "}\n";

    uint vao;
    uint instance_vao;
    Particle[] particles;

    void initialize(Context ctx) {
        particles = build_particles(1000);
        program = create_program(vertex_shader_text,
                                 fragment_shader_text,
                                 ["in_pos", "in_color"],
                                 ["offset", "u_color"]);

        float size = 0.005;
        float[30] vertices =
        [
            -size,  size, 1.0f, 1.0f, 1.0f,
             size, -size, 1.0f, 1.0f, 1.0f,
            -size, -size, 1.0f, 1.0f, 1.0f,

            -size,  size, 1.0f, 1.0f, 1.0f,
             size, -size, 1.0f, 1.0f, 1.0f,   
             size,  size, 1.0f, 1.0f, 1.0f	
        ];
        vao = program.create_buffer(vertices);

        program.describe_attrib(vao, "in_pos", 2, 5, 0);
        program.describe_attrib(vao, "in_color", 3, 5, 2);

    }
    
    void run(Context ctx) {
        program.use();
        t += ctx.dt;
        int index = 0;
        float offset = 0.1f;
        foreach (ref p; particles) {
            p.p.x += ctx.dt * p.v.x;
            p.p.y += ctx.dt * p.v.y;
            program.set_uniform("offset", p.p.e);

            auto f = p.life/2.0;
            p.life += ctx.dt;
            if (f > 1) {
                p.reset();
            }
            auto color = lerp!float([.8, .8, .8, 1], [0.75, 0.3, 0.1, 0.75], f);
            program.set_uniform("u_color", color);
            program.draw_array(vao, 6);
        } 
    }

    void reset_particles() {
        foreach (p; particles){
            p.reset();
        }
    }

    Particle[] build_particles(int count) {
        auto particles = new Particle[count];
        foreach (i; 0..count) {
            Particle p;
            p.reset();
            particles ~= p;
        }
        return particles;
    }

}

