module util.ext_lib;

import core.sys.posix.dlfcn;
import std.string;


alias stbi_load_t = extern (C) ubyte* function(const(char)* filename, int* x, int* y, int* channels_in_file, int desired_channels);
alias stbi_image_free_t = extern(C) void function(void* retval_from_stbi_load);
alias stbi_set_flip_vertically_on_load_t = extern(C) void function(int flag_true_if_should_flip);

stbi_load_t stbi_load;
stbi_image_free_t stbi_image_free;
stbi_set_flip_vertically_on_load_t stbi_set_flip_vertically_on_load;

bool load_stb_lib(string shared_library) {
    auto handle = dlopen(toStringz(shared_library), RTLD_NOW);
    if (!handle) {
        return false;
    }
    stbi_load = cast(stbi_load_t)dlsym(handle, "stbi_load");
    stbi_image_free = cast(stbi_image_free_t)dlsym(handle, "stbi_image_free");
    stbi_set_flip_vertically_on_load = cast(stbi_set_flip_vertically_on_load_t)dlsym(handle, "stbi_set_flip_vertically_on_load");
    stbi_set_flip_vertically_on_load(1);
    return true;
}

struct Image {
    ubyte* data;
    int w;
    int h;
    int c;
    int size;
}

Image load_image(string file_name) {
    int w, h, c;
    auto data = stbi_load(toStringz(file_name), &w, &h, &c, 0);
    Image image;
    image.data = data;
    image.w = w;
    image.h = h;
    image.c = c;
    image.size = w*h*c;
    return image;
}

void free_image(Image* image) {
    if (image.data) {
        stbi_image_free(image.data);
        image.data = null;
        image.w = 0;
        image.h = 0;
        image.c = 0;
        image.size = 0;
    }
}
