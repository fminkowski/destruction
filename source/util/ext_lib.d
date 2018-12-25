module util.ext_lib;

import core.sys.posix.dlfcn;
import std.string;


alias stbi_load_t = extern (C) ubyte* function(const(char)* filename, int* x, int* y, int* channels_in_file, int desired_channels);
alias stbi_image_free_t = extern(C) void function(void* retval_from_stbi_load);
alias stbi_set_flip_vertically_on_load_t = extern(C) void function(int flag_true_if_should_flip);

stbi_load_t stbi_load;
stbi_image_free_t stbi_image_free;
stbi_set_flip_vertically_on_load_t stbi_set_flip_vertically_on_load;

alias stbi_write_png_t = extern(C) int function(const char *filename, int w, int h, int comp, const void *data, int stride_in_bytes);
alias stbi_write_bmp_t = extern(C) int function(const char *filename, int w, int h, int comp, const void *data);
alias stbi_write_tga_t = extern(C) int function(const char *filename, int w, int h, int comp, const void *data);
alias stbi_write_jpg_t = extern(C) int function(const char *filename, int w, int h, int comp, const void *data, int quality);
alias stbi_write_hdr_t = extern(C) int function(const char *filename, int w, int h, int comp, const float *data);

alias stbi_flip_vertically_on_write_t = void function(int flag); // flag is non-zero to flip data vertically

stbi_write_png_t stbi_write_png;
stbi_write_bmp_t stbi_write_bmp; 
stbi_write_tga_t stbi_write_tga; 
stbi_write_jpg_t stbi_write_jpg;
stbi_write_hdr_t stbi_write_hdr;
stbi_flip_vertically_on_write_t stbi_flip_vertically_on_write;


struct Image {
    ubyte* data;
    ubyte[] buffer;
    int w;
    int h;
    int c;
    int size() {
        return w*h*c;
    }

    void write() {
        stbi_write_png("font.png", w, h, 1, data, w);
    }

    void flip() {
        for (auto y = 0; y < h/2; y++) {
            for (auto x = 0; x < w*c; x++) {
                auto i1 = y * w * c + x;
                auto i2 = (h-1-y) * w * c + x;
                auto tmp = data[i1];
                data[i1] = data[i2];
                data[i2] = tmp;
            }
        }
    }

    void copy(size_t w, size_t h, ubyte* buffer) {
        for (auto i = 0; i < w * h * c; i++) {
           this.buffer[i] = buffer[i]; 
        }
        data = this.buffer.ptr;
    }
}

Image load_image(string file_name) {
    int w, h, c;
    auto data = stbi_load(toStringz(file_name), &w, &h, &c, 0);
    Image image;
    image.data = data;
    image.w = w;
    image.h = h;
    image.c = c;
    return image;
}

void free_image(Image* image) {
    if (image.data) {
        stbi_image_free(image.data);
        image.data = null;
        image.w = 0;
        image.h = 0;
        image.c = 0;
    }
}


////// truetype
struct stbtt__buf {
   ubyte *data;
   int cursor;
   int size;
};

struct stbtt_fontinfo {
   void           * userdata;
   ubyte          * data;              // pointer to .ttf file
   int              fontstart;         // offset of start of font

   int numGlyphs;                     // number of glyphs, needed for range checking

   int loca,head,glyf,hhea,hmtx,kern,gpos; // table locations as offset from start of .ttf
   int index_map;                     // a cmap mapping for our chosen character encoding
   int indexToLocFormat;              // format needed to map from glyph index to glyph

   stbtt__buf cff;                    // cff font data
   stbtt__buf charstrings;            // the charstring index
   stbtt__buf gsubrs;                 // global charstring subroutines index
   stbtt__buf subrs;                  // private charstring subroutines index
   stbtt__buf fontdicts;              // array of font dicts
   stbtt__buf fdselect;               // map from glyph to fontdict
};

struct stbtt_bakedchar
{
   ushort x0,y0,x1,y1; // coordinates of bbox in bitmap
   float xoff,yoff,xadvance;
};

struct stbtt_aligned_quad
{
   float x0,y0,s0,t0; // top-left
   float x1,y1,s1,t1; // bottom-right
};

alias stbtt_InitFont_t            = extern(C) int function(stbtt_fontinfo *info, const ubyte* data, int offset);
alias stbtt_BakeFontBitmap_t      = extern(C) int function(const ubyte* data, int offset,
                                                           float pixel_height, ubyte* pixels, int pw, int ph,
                                                           int first_char, int num_chars, stbtt_bakedchar* chardata);
alias stbtt_ScaleForPixelHeight_t = extern(C) float function(const stbtt_fontinfo* info, float height);
alias stbtt_GetFontOffsetForIndex_t = extern(C) int function(const ubyte* data, int index);
alias stbtt_GetFontVMetrics_t     = extern(C) void function(const stbtt_fontinfo* info, int* ascent, int* descent, int* lineGap);
alias stbtt_GetBakedQuad_t        = extern(C) void function(const stbtt_bakedchar* chardata,
                                                            int pw, int ph, int char_index,
                                                            float* xpos, float* ypos,
                                                            stbtt_aligned_quad* q, int opengl_fillrule);

stbtt_InitFont_t stbtt_InitFont;
stbtt_BakeFontBitmap_t stbtt_BakeFontBitmap;
stbtt_ScaleForPixelHeight_t stbtt_ScaleForPixelHeight;
stbtt_GetFontVMetrics_t stbtt_GetFontVMetrics;
stbtt_GetBakedQuad_t stbtt_GetBakedQuad;
stbtt_GetFontOffsetForIndex_t stbtt_GetFontOffsetForIndex;

bool load_stb_lib(string shared_library) {
    auto handle = dlopen(toStringz(shared_library), RTLD_NOW);
    if (!handle) {
        return false;
    }
    stbi_load = bind!stbi_load_t(handle, "stbi_load");
    stbi_image_free = bind!stbi_image_free_t(handle, "stbi_image_free");
    stbi_set_flip_vertically_on_load = bind!stbi_set_flip_vertically_on_load_t(handle, "stbi_set_flip_vertically_on_load");
    stbi_set_flip_vertically_on_load(1);

    stbtt_InitFont = bind!stbtt_InitFont_t(handle, "stbtt_InitFont");
    stbtt_BakeFontBitmap = bind!stbtt_BakeFontBitmap_t(handle, "stbtt_BakeFontBitmap");
    stbtt_ScaleForPixelHeight = bind!stbtt_ScaleForPixelHeight_t(handle, "stbtt_ScaleForPixelHeight");
    stbtt_GetFontVMetrics = bind!stbtt_GetFontVMetrics_t(handle, "stbtt_GetFontVMetrics");
    stbtt_GetBakedQuad = bind!stbtt_GetBakedQuad_t(handle, "stbtt_GetBakedQuad");
    stbtt_GetFontOffsetForIndex = bind!stbtt_GetFontOffsetForIndex_t(handle, "stbtt_GetFontOffsetForIndex");

    stbi_write_png = bind!stbi_write_png_t(handle, "stbi_write_png");
    stbi_write_bmp = bind!stbi_write_bmp_t(handle, "stbi_write_bmp");
    stbi_write_tga = bind!stbi_write_tga_t(handle, "stbi_write_tga");
    stbi_write_jpg = bind!stbi_write_jpg_t(handle, "stbi_write_jpg");
    stbi_write_hdr = bind!stbi_write_hdr_t(handle, "stbi_write_hdr");
    stbi_flip_vertically_on_write = bind!stbi_flip_vertically_on_write_t(handle, "stbi_flip_vertically_on_write");

    return true;
}

T bind(T)(void* handle, string name) {
    import std.stdio;
    auto r = cast(T)dlsym(handle, toStringz(name));
    if (!r) {
        writeln("Could not find symbol " ~ name);
    }
    return r;
}
