module component.textured_quad;

import derelict.opengl;

import manager.component;
import util.math;
import util.gl;
import util.ext_lib;

struct Texture {
    GLBuffer b;
    uint texture;
}

class TexturedQuad : IComponent
{
    import std.math;
    GLProgram program;
    double t = 0;
    const vertex_count = 28;
    const index_count = 6;

    string vertex_shader_text =
    "#version 330 core\n" ~
    "layout (location = 0) in vec2 vPos;\n" ~
    "layout (location = 1) in vec3 vCol;\n" ~
    "layout (location = 2) in vec2 aTexCoord;\n" ~
    "out vec3 color;\n" ~
    "out vec2 TexCoord;\n" ~
    "void main()\n" ~
    "{\n" ~
    "   gl_Position = vec4(vPos, 0.0, 1.0);\n" ~
    "   color = vCol;\n" ~
    "   TexCoord = vec2(aTexCoord.x, aTexCoord.y);" ~
    "}\n";

    string fragment_shader_text =
    "#version 330 core\n" ~
    "in vec3 color;\n" ~
    "in vec2 TexCoord;\n" ~
    "out vec4 FragColor;\n" ~
    "uniform sampler2D texture1;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    FragColor = texture(texture1, TexCoord);\n" ~
    "}\n";


    Texture texture;
    void initialize(Context ctx) {
        program = create_program(vertex_shader_text,
                                 fragment_shader_text,
                                 ["vPos", "vCol", "aTexCoord"],
                                 ["texture1"]);

        float[vertex_count] vertices = [
             0.5f,  0.5f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f,
             0.5f, -0.5f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f,
            -0.5f, -0.5f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
            -0.5f,  0.5f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f
        ];
        uint[index_count] indices = [  
            0, 1, 3,
            1, 2, 3
        ];
        texture.b = program.create_indexed_buffer(vertices, indices);
        auto vao = texture.b.vao;

        auto image = load_image("test.png");
        texture.texture = program.load_texture(image);

        program.describe_attrib(vao, "vPos", 2, 7, 0);
        program.describe_attrib(vao, "vCol", 3, 7, 2);
        program.describe_attrib(vao, "aTexCoord", 2, 7, 5);
    }

    void run(Context ctx) {
        program.use();
        program.draw_textured_elements(texture.texture, texture.b.vao, index_count);
    }
}


