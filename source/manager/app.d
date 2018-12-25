module manager.app;

import std.stdio;
import std.conv;
import derelict.glfw3.glfw3;
import derelict.opengl;
import manager.router;
import manager.component;
import util.font;
import std.stdio;
import std.conv;


extern(C) 
void error_callback(int error, const(char)* description) nothrow
{
    try
    {
        writeln("Error: ", to!string(description));
    } catch (Exception e) {

    }
}

extern(C)
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) nothrow
{
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GLFW_TRUE);
    }
}

class App {
    const frame_rate = 60.0;
    GLFWwindow* window;
    FrameBuffer frame_buffer;
    IRouter router;
    double dt = 0;
    Font font;
    FontRenderer font_renderer;
    bool component_initialized = false;

    this(IRouter router) {
        this.router = router;
    }

    void init() {
        DerelictGLFW3.load();
        DerelictGL3.load();
        glfwSetErrorCallback(&error_callback);
        if (!glfwInit())
        {
            writeln("failed to init glfw");
        }
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
        window = glfwCreateWindow(640, 640, "Destruction", null, null);
        if (!window)
        {
            writeln("could not create window");
        }

        glfwMakeContextCurrent(window);
        auto vers = DerelictGL3.reload();
        glfwSwapInterval(1);

        glfwSetKeyCallback(window, &key_callback);
        
        font.init();
        font_renderer.use_font(&font);
        font_renderer.init();
    }

    void run() {
        init(); 
        Context context;
        while (!glfwWindowShouldClose(window)) {
            auto start_time = glfwGetTime();
            glfwGetFramebufferSize(window, &frame_buffer.width, &frame_buffer.height);
            glViewport(0, 0, frame_buffer.width, frame_buffer.height);
            glClear(GL_COLOR_BUFFER_BIT);

            context.frame_buffer = frame_buffer;
            context.dt = dt;
            context.font = &font_renderer;
            font_renderer.draw("dt: " ~ to!string(dt * 1000), -320, 320 - font.line_gap);            
            auto component = router.get_current();
            if (!component_initialized) {
                component_initialized = true;
                component.initialize(context);
            }
            component.run(context);

            glfwSwapBuffers(window);
            glfwPollEvents();
            wait_rest_of_frame(start_time);
        }
        glfwDestroyWindow(window);
        glfwTerminate();
    }

    void wait_rest_of_frame(double start_time) {
        dt = glfwGetTime() - start_time;
        const frame_time = 1.0 / frame_rate;
        while ( dt <= frame_time) {
            dt = glfwGetTime() - start_time;
        }
    }
}
