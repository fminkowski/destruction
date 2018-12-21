module manager.component;

struct FrameBuffer {
    int width;
    int height; 
}

struct Context {
    FrameBuffer frame_buffer;
    double dt;
}

interface IComponent {
    void run(Context context);
}
