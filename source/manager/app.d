module manager.app;

import std.stdio;
import std.conv;
import derelict.glfw3.glfw3;
import derelict.opengl;
import manager.router;
import manager.component;

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
    FrameBuffer frame_buffer;
    IRouter router;
    double dt = 0;
    bool component_initialized = false;

    this(IRouter router) {
        this.router = router;
    }

    void run() {
        DerelictGLFW3.load();
        DerelictGL3.load();
        glfwSetErrorCallback(&error_callback);
        if (!glfwInit())
        {
            writeln("failed to init glfw");
        }
        scope(exit) glfwTerminate();
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
        GLFWwindow* window = glfwCreateWindow(640, 480, "Destruction", null, null);
        if (!window)
        {
            writeln("could not create window");
        }
        scope(exit) glfwDestroyWindow(window);

        glfwMakeContextCurrent(window);
        auto vers = DerelictGL3.reload();
        glfwSwapInterval(1);

        glfwSetKeyCallback(window, &key_callback);
    
        Context context;
        while (!glfwWindowShouldClose(window)) {
            auto start_time = glfwGetTime();
            glfwGetFramebufferSize(window, &frame_buffer.width, &frame_buffer.height);
            glViewport(0, 0, frame_buffer.width, frame_buffer.height);
            glClear(GL_COLOR_BUFFER_BIT);

            context.frame_buffer = frame_buffer;
            context.dt = dt;
            auto component = router.get_current();
            if (!component_initialized) {
                component_initialized = true;
                component.initialize(context);
            }
            component.run(context);

            glfwSwapBuffers(window);
            glfwPollEvents();
            dt = glfwGetTime() - start_time;
        }
    }
}
