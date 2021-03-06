module util.gl;

import derelict.opengl;
import util.ext_lib;

struct GLBuffer {
    uint vao, vbo, ebo;
}

struct GLProgram {
    GLint id;
    GLuint[string] attribs;
    GLint[string] uniforms;

    GLBuffer make_buffer() {
        uint vbo, vao;
        glGenVertexArrays(1, &vao);
        glGenBuffers(1, &vbo);
        glBindVertexArray(vao);

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        GLBuffer buffer;
        buffer.vao = vao;
        buffer.vbo = vbo;
        return buffer;
    }

    uint create_buffer(T)(T vertices) {
        auto b = make_buffer();
        glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, vertices.ptr, GL_STATIC_DRAW);
        return b.vao;
    }

    GLBuffer create_indexed_buffer(T1, T2)(T1 vertices, T2 indices) {
        uint vbo, vao, ebo;
        GLBuffer b;
        glGenVertexArrays(1, &b.vao);
        glGenBuffers(1, &b.vbo);
        glGenBuffers(1, &b.ebo);

        glBindVertexArray(b.vao);
        
        glBindBuffer(GL_ARRAY_BUFFER, b.vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, vertices.ptr, GL_STATIC_DRAW);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, b.ebo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.sizeof, indices.ptr, GL_STATIC_DRAW);
        glEnableVertexAttribArray(0);
        return b;
    }

    void stream_to_buffer(T1)(uint vao, uint vbo, T1[] vertices) {
        glBindVertexArray(vao);        
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof,
                     vertices.ptr, GL_DYNAMIC_DRAW);
    }

    void bind_texture(uint texture) {
        glBindTexture(GL_TEXTURE_2D, texture); 
    }

    uint load_texture(Image image) {
        uint texture;
        glGenTextures(1, &texture);
        glActiveTexture(GL_TEXTURE0);
        // all upcoming GL_TEXTURE_2D operations now have effect on this texture object
        glBindTexture(GL_TEXTURE_2D, texture); 
        // set the texture wrapping parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        // set texture filtering parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        if (image.data) {
            auto format = get_gl_format(image);
            glTexImage2D(GL_TEXTURE_2D, 0, format,
                         image.w, image.h, 0, image.c == 1 ? GL_RED : format,
                         GL_UNSIGNED_BYTE, image.data);
            glGenerateMipmap(GL_TEXTURE_2D);
        }
        return texture;
    }

    void describe_attrib(uint vao, string attrib,
                         int size, int num_elements, int offset) {
        auto a = attribs[attrib];
        glBindVertexArray(vao);
        glVertexAttribPointer(a, size,
                              GL_FLOAT, GL_FALSE,
                              cast(int)float.sizeof * num_elements,
                              cast(void*) (float.sizeof * offset));
        glEnableVertexAttribArray(a);
    } 

    void set_uniform(T)(string uniform, T[] values) {
        auto id = uniforms[uniform];
        switch (values.length) {
        case 1:
            glUniform1f(id, cast(float)values[0]);
            break;
        case 2:
            glUniform2f(id, cast(float)values[0], cast(float)values[1]);
            break;
        case 3:
            glUniform3f(id, cast(float)values[0], cast(float)values[1], cast(float)values[2]);
            break;
        case 4:
            glUniform4f(id, cast(float)values[0], cast(float)values[1], cast(float)values[2], cast(float)values[3]);
            break;
        default:
            glUniformMatrix4fv(id, 1, GL_TRUE, cast(float*)values.ptr);
            break;
        }
    }

    void use() {
        glUseProgram(id);
    }

    void draw_points(uint vao, size_t count) {
        glBindVertexArray(vao);
        glEnable(GL_PROGRAM_POINT_SIZE);
        glDrawArrays(GL_POINTS, 0, cast(int)count);
    }

    void draw_array(uint vao, size_t count) {
        glBindVertexArray(vao);
        glDrawArrays(GL_TRIANGLES, 0, cast(int)count);
    }

    void draw_elements(uint vao, size_t index_count) {
        glBindVertexArray(vao);
        glDrawElements(GL_TRIANGLES, cast(int)index_count,
                       GL_UNSIGNED_INT, null);
    }

    void draw_textured_elements(uint texture, uint vao, size_t index_count) {
        glBindTexture(GL_TEXTURE_2D, texture);
        draw_elements(vao, index_count);
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
    import std.stdio;
    import std.conv;
    int success;
    char[512] infoLog;

    vertex_shader = glCreateShader(GL_VERTEX_SHADER);
    const char* vst = toStringz(vertex_shader_text);
    glShaderSource(vertex_shader, 1, &vst, null);
    glCompileShader(vertex_shader);
    glGetShaderiv(vertex_shader, GL_COMPILE_STATUS, &success);
    if (success == 0) {
        glGetShaderInfoLog(vertex_shader, infoLog.length, null, infoLog.ptr);
        writeln(to!string(infoLog));
    }

    fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
    const char* fst = toStringz(fragment_shader_text);
    glShaderSource(fragment_shader, 1, &fst, null);
    glCompileShader(fragment_shader);
    glGetShaderiv(fragment_shader, GL_COMPILE_STATUS, &success);
    if (success == 0) {
        glGetShaderInfoLog(fragment_shader, infoLog.length, null, infoLog.ptr);
        writeln(to!string(infoLog));
    }

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
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable( GL_BLEND );
    return result;
}

GLenum get_gl_format(Image image) {
    switch(image.c) {
    case 1: return GL_R8;
    case 2: return GL_RG;
    case 3: return GL_RGB;
    default: return GL_RGBA;
    }
}
