module component.ui.text;

import derelict.opengl;
import manager.component;
import util.math;
import util.gl;
import util.ext_lib;
import util.font;
import std.stdio; 

struct Texture {
    uint texture;
    GLBuffer b;
}

class Text : IComponent {
    void initialize(Context ctx) {}
    
    void run(Context ctx) {
        auto font = ctx.font;
        font.draw("This is some awesome text", -100, 100);
    }
}

