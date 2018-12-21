module component.simple_triangle;

import derelict.opengl;
import manager.component;
import util.math;

class SimpleTriangle : IComponent
{
    bool is_init;
    GLint program;

    string vertex_shader_text =
    "attribute vec3 vCol;\n" ~
    "attribute vec2 vPos;\n" ~
    "varying vec3 color;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    gl_Position = vec4(vPos, 0.0, 1.0);\n" ~
    "    color = vCol;\n" ~
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
        GLint vpos_location, vcol_location;

        import std.string;
        glGenBuffers(1, &vertex_buffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
        glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, cast(const void*)(vertices), GL_STATIC_DRAW);

        vertex_shader = glCreateShader(GL_VERTEX_SHADER);
        const char* vst = toStringz(vertex_shader_text);
        glShaderSource(vertex_shader, 1, &vst, null);
        glCompileShader(vertex_shader);

        fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
        const char* fst = toStringz(fragment_shader_text);
        glShaderSource(fragment_shader, 1, &fst, null);
        glCompileShader(fragment_shader);

        program = glCreateProgram();
        glAttachShader(program, vertex_shader);
        glAttachShader(program, fragment_shader);
        glLinkProgram(program);

        vpos_location = glGetAttribLocation(program, "vPos");
        vcol_location = glGetAttribLocation(program, "vCol");
        glEnableVertexAttribArray(vpos_location);
        glVertexAttribPointer(vpos_location, 2, GL_FLOAT, GL_FALSE,
                              float.sizeof * 5, cast(void*) 0);
        glEnableVertexAttribArray(vcol_location);
        glVertexAttribPointer(vcol_location, 3, GL_FLOAT, GL_FALSE,
                              float.sizeof * 5, cast(void*) (float.sizeof * 2));
    }

    void run(Context ctx) {
        glUseProgram(program);
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
}


