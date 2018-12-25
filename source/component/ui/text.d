module component.ui.text;

import derelict.opengl;
import manager.component;
import util.math;
import util.gl;
import util.ext_lib;

import std.stdio; 

struct Texture {
    uint texture;
    GLBuffer b;
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

        texture.b = program.make_buffer();
        texture.texture = program.load_texture(font_image);

        program.describe_attrib(texture.b.vao, "in_pos", 2, 4, 0);
        program.describe_attrib(texture.b.vao, "in_texture", 2, 4, 2);
    }
    
    void run(Context ctx) {
        program.use();
        glBindVertexArray(texture.b.vao);
        glBindTexture(GL_TEXTURE_2D, texture.texture);
        draw_text("This is some awesome text", 0, 0);
    }

    import std.encoding;
    struct Point {
        float x, y, s, t;
    }
    void draw_text(string text, float x, float y) {

        float[] vertices;
        
        //make the origin the top-left of the window
        float x_offset = 0;
        float y_offset = 0;//line_gap();

        int vertex_count = 0;
        foreach (c; text.codePoints) {
            stbtt_aligned_quad quad;
            stbtt_GetBakedQuad(cdata.ptr, 512, 512,
                               cast(char)c-32, &x, &y, &quad, 1);//1=opengl & d3d10+,0=d3d9

            float x0 = pixel_to_gl_x(quad.x0 - x_offset);
            float x1 = pixel_to_gl_x(quad.x1 - x_offset);
            float y0 = pixel_to_gl_y(-quad.y0 + y_offset);
            float y1 = pixel_to_gl_y(-quad.y1 + y_offset);

            vertices ~= [x0, y0, quad.s0, quad.t0]; //top left
            vertices ~= [x1, y0, quad.s1, quad.t0]; //top right
            vertices ~= [x1, y1, quad.s1, quad.t1]; //bottom right
            vertices ~= [x0, y0, quad.s0, quad.t0]; //top left
            vertices ~= [x1, y1, quad.s1, quad.t1]; //bottom right
            vertices ~= [x0, y1, quad.s0, quad.t1]; //bottom left

            vertex_count+=6;
        }

        glBindBuffer(GL_ARRAY_BUFFER, texture.b.vbo);
        auto v = vertex_count;
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof,
                     vertices.ptr, GL_DYNAMIC_DRAW);
        program.draw_array(texture.b.vao, v);
    }
}

float pixel_to_gl_x(float pixel_pos, float screen_size=640)
{
    float half_screen = 0.5f * screen_size;
    return (pixel_pos) / (half_screen);
}

float pixel_to_gl_y(float pixel_pos, float screen_size=640)
{
    float half_screen = 0.5f * screen_size;
    return (pixel_pos) / (half_screen);
}
