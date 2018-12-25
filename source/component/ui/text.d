module component.ui.text;

import manager.component;
import util.gl;
import util.font;

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

