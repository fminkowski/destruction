module manager.component;

import util.font;

struct FrameBuffer {
    int width;
    int height; 
}

struct Context {
    FrameBuffer frame_buffer;
    double dt;
    FontRenderer* font;
}

interface IComponent {
    void initialize(Context context);
    void run(Context context);
}
