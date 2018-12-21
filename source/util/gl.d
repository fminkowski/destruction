module util.gl;

import derelict.opengl;

struct GLProgram {
    GLint id;
    GLuint[string] attribs;
    GLuint[string] uniforms;

    void describe(string attrib, int size, int num_elements, int offset) {
        auto a = attribs[attrib];
        glEnableVertexAttribArray(a);
        glVertexAttribPointer(a, size,
                              GL_FLOAT, GL_FALSE,
                              cast(int)float.sizeof * num_elements,
                              cast(void*) (float.sizeof * offset));
    } 
}

GLProgram create_program(string vertex_shader_text,
                    string fragment_shader_text,
                    string[] attribs=[],
                    string[] uniforms=[]) {
    GLProgram result;
    GLuint vertex_buffer, vertex_shader, fragment_shader;
    GLint program_id, vpos_location, vcol_location;

    import std.string;

    vertex_shader = glCreateShader(GL_VERTEX_SHADER);
    const char* vst = toStringz(vertex_shader_text);
    glShaderSource(vertex_shader, 1, &vst, null);
    glCompileShader(vertex_shader);

    fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
    const char* fst = toStringz(fragment_shader_text);
    glShaderSource(fragment_shader, 1, &fst, null);
    glCompileShader(fragment_shader);

    program_id = glCreateProgram();
    glAttachShader(program_id, vertex_shader);
    glAttachShader(program_id, fragment_shader);
    glLinkProgram(program_id);

    result.id = program_id;

    foreach (a; attribs) {
        const char* tmp = toStringz(a);
        result.attribs[a] = glGetAttribLocation(program_id, tmp);
    }

    foreach (u; uniforms) {
        const char* tmp = toStringz(u);
        result.uniforms[u] = glGetUniformLocation(program_id, tmp);
    }
    return result;
}
