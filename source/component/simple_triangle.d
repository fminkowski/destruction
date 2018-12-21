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
        GLuint vertex_buffer, vertex_shader, fragment_shader;

        import std.string;
        glGenBuffers(1, &vertex_buffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
        glBufferData(GL_ARRAY_BUFFER,
                     vertices.sizeof,
                     cast(const void*)(vertices),
                     GL_STATIC_DRAW);

        program = create_program(vertex_shader_text,
                                      fragment_shader_text,
                                      ["vPos", "vCol"],
                                      ["scale"]);

        auto vpos = program.attribs["vPos"];
        glEnableVertexAttribArray(vpos);
        glVertexAttribPointer(vpos, 2, GL_FLOAT, GL_FALSE,
                              float.sizeof * 5, cast(void*) 0);
        
        auto vcol = program.attribs["vCol"];
        glEnableVertexAttribArray(vcol);
        glVertexAttribPointer(vcol, 3, GL_FLOAT, GL_FALSE,
                              float.sizeof * 5, cast(void*) (float.sizeof * 2));
    }

    void run(Context ctx) {
        glUseProgram(program.id);
        glUniform1f(program.uniforms["scale"], 0.5);
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
}


