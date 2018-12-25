module component.ui.text;

import derelict.opengl;
import manager.component;
import util.math;
import util.gl;
import util.ext_lib;

import std.stdio; 

struct Texture {
    uint vao;
    uint texture;
}

class Text : IComponent
{
    import std.math;
    GLProgram program;
    Texture texture;

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

    stbtt_bakedchar[96] cdata;
    ubyte[512*512] temp_bitmap;
    Image font_image;

    stbtt_fontinfo font_info;
    float font_size = 32f;
    void init_font() {
        import std.file;
        int buffer_width = 512;
        int buffer_height = 512;
        string font_file = "/System/Library/Fonts/Keyboard.ttf";
        auto font = cast(ubyte*)read(font_file);

        stbtt_InitFont(&font_info, font,
                       stbtt_GetFontOffsetForIndex(font, 0));
        stbtt_BakeFontBitmap(font, 0, font_size,
                             temp_bitmap.ptr, buffer_width, buffer_height,
                             32, 96, cdata.ptr);

        font_image.data = temp_bitmap.ptr;
        font_image.w = buffer_width;
        font_image.h = buffer_height;
        font_image.c = 1;
        font_image.flip;
    }

    float line_gap() {
        int ascent, descent, line_gap;
        float scale = stbtt_ScaleForPixelHeight(&font_info, font_size);
        stbtt_GetFontVMetrics(&font_info, &ascent, &descent, &line_gap);
        float value = scale * (ascent - descent + line_gap); //pixels
        return value;
    }

    void initialize(Context ctx) {
        init_font();
        program = create_program(vertex_shader_text,
                                 fragment_shader_text,
                                 ["in_pos", "in_texture"]);

        float[16] vertices = [
             0.5f,  0.5f, 1.0f, 1.0f,
             0.5f, -0.5f, 1.0f, 0.0f,
            -0.5f, -0.5f, 0.0f, 0.0f,
            -0.5f,  0.5f, 0.0f, 1.0f
        ];
        uint[6] indices = [  
            0, 1, 3,
            1, 2, 3
        ];
        texture.vao = program.create_indexed_buffer(vertices, indices);
        texture.texture = program.load_texture(font_image);
        font_image.write;

        program.describe_attrib(texture.vao, "in_pos", 2, 4, 0);
        program.describe_attrib(texture.vao, "in_texture", 2, 4, 2);
    }
    
    void run(Context ctx) {
        program.use();
        program.draw_textured_elements(texture.vao, texture.texture, 6);
    }

    import std.encoding;
    struct Point {
        float x, y, s, t;
    }
    Point[] draw_text(string text, float x, float y) {

        const int vertices_per_quad = 6;
        auto vertices = new Point[text.length];
        
        //make the origin the top-left of the window
        float x_offset = 0;
        float y_offset = line_gap();

        int vertex_count = 0;
        foreach (c; text.codePoints) {
            writeln(c);
            stbtt_aligned_quad quad;
            stbtt_GetBakedQuad(cdata.ptr, 512, 512, c-32, &x, &y, &quad, 1);//1=opengl & d3d10+,0=d3d9

            float x0 = quad.x0 - x_offset;
            float x1 = quad.x1 - x_offset;
            float y0 = quad.y0 + y_offset;
            float y1 = quad.y1 + y_offset;

            vertices[vertex_count++] = Point(x0, y0, quad.s0, quad.t0); //top left
            vertices[vertex_count++] = Point(x1, y0, quad.s1, quad.t0); //top right
            vertices[vertex_count++] = Point(x1, y1, quad.s1, quad.t1); //bottom right
            vertices[vertex_count++] = Point(x0, y0, quad.s0, quad.t0); //top left
            vertices[vertex_count++] = Point(x1, y1, quad.s1, quad.t1); //bottom right
            vertices[vertex_count++] = Point(x0, y1, quad.s0, quad.t1); //bottom left
        }
        return vertices;
    }
}

