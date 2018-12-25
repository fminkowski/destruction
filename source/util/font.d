module util.font;

import util.math;
import util.gl;
import util.ext_lib;

struct Font {
    private {
    float _font_size;
    Image _img;
    stbtt_bakedchar[96] _character_data;
    stbtt_fontinfo _font_info;
    }
    
    Image img() {
        return _img;
    }

    float size() {
        return _font_size;
    }

    void init(string font_file = "/Library/Fonts/Tahoma.ttf", float font_size = 20.0) {
        this._font_size = font_size;
        import std.file;
        int buffer_width = 512;
        int buffer_height = 512;
        ubyte[512*512] temp_bitmap;
        auto font = cast(ubyte*)read(font_file);

        stbtt_InitFont(&_font_info, font,
                       stbtt_GetFontOffsetForIndex(font, 0));
        stbtt_BakeFontBitmap(font, 0, size,
                             temp_bitmap.ptr, buffer_width, buffer_height,
                             32, 96, _character_data.ptr);

        _img.copy(buffer_width, buffer_height, 1, temp_bitmap.ptr);
    }

    float line_gap() {
        int ascent, descent, line_gap;
        float scale = stbtt_ScaleForPixelHeight(&_font_info, size);
        stbtt_GetFontVMetrics(&_font_info, &ascent, &descent, &line_gap);
        float value = scale * (ascent - descent + line_gap); //pixels
        return value;
    }

    float[] make_text_vertices(string text, float x, float y) {
        import std.encoding;
        float[] vertices = new float[24 * text.length];
        
        y = -y; //out coordiate y is up, but in stb y is down
        foreach (i, c; text.codePoints) {
            stbtt_aligned_quad quad;
            stbtt_GetBakedQuad(_character_data.ptr, 512, 512,
                               cast(char)c-32, &x, &y, &quad, 1);//1=opengl & d3d10+,0=d3d9

            float x0 = pixel_to_gl_x(quad.x0);
            float x1 = pixel_to_gl_x(quad.x1);
            float y0 = pixel_to_gl_y(-quad.y0);
            float y1 = pixel_to_gl_y(-quad.y1);

            vertices[24*i    .. 24*i+4] = [x0, y0, quad.s0, quad.t0]; //top left
            vertices[24*i+4  .. 24*i+8] = [x1, y0, quad.s1, quad.t0]; //top right
            vertices[24*i+8  .. 24*i+12] = [x1, y1, quad.s1, quad.t1]; //bottom right
            vertices[24*i+12 .. 24*i+16] = [x0, y0, quad.s0, quad.t0]; //top left
            vertices[24*i+16 .. 24*i+20] = [x1, y1, quad.s1, quad.t1]; //bottom right
            vertices[24*i+20 .. 24*i+24] = [x0, y1, quad.s0, quad.t1]; //bottom left
        }
        
        return vertices;
    }
}

import derelict.opengl;

struct Texture {
    uint texture;
    GLBuffer b;
}

struct FontRenderer {
    GLProgram program;
    Texture texture;
    Font* font;

    string vertex_shader_text =
    "#version 330 core\n" ~
    "layout (location = 0) in vec2 in_pos;\n" ~
    "layout (location = 1) in vec2 in_texture;\n" ~
    "out vec2 Text_Coord;\n" ~
    "void main()\n" ~
    "{\n" ~
    "   gl_Position = vec4(in_pos, 0.0, 1.0);\n" ~
    "   Text_Coord = in_texture;\n" ~
    "}\n";

    string fragment_shader_text =
    "#version 330 core\n" ~
    "in vec2 Text_Coord;\n" ~
    "out vec4 FragColor;\n" ~
    "uniform sampler2D texture1;\n" ~
    "void main()\n" ~
    "{\n" ~
    "   vec4 color = texture(texture1, Text_Coord);\n" ~
    "   FragColor = vec4(1.0, 1.0, 1.0, color.r);\n" ~
    "}\n";


    void use_font(Font* font) {
        this.font = font;
    }

    float line_gap() {
        return font.line_gap;
    }

    void init() {
        program = create_program(vertex_shader_text,
                                 fragment_shader_text,
                                 ["in_pos", "in_texture"]);

        texture.b = program.make_buffer();
        texture.texture = program.load_texture(font.img);

        program.describe_attrib(texture.b.vao, "in_pos", 2, 4, 0);
        program.describe_attrib(texture.b.vao, "in_texture", 2, 4, 2);
    }
    
    void draw(string text, float x, float y) {
        program.use();
        program.bind_texture(texture.texture);
        float[] vertices = font.make_text_vertices(text, x, y);
        auto vertex_count = vertices.length / 4; 

        program.stream_to_buffer(texture.b.vao, texture.b.vbo, vertices);
        program.draw_array(texture.b.vao, vertex_count);
    }
}
