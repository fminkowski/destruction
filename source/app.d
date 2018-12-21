import std.stdio;
import std.conv;
import derelict.glfw3.glfw3;
import derelict.opengl;

struct Context {
    FrameBuffer frame_buffer;
    double dt;
}

interface IComponent {
    void run(Context context);
}

interface IRouter {
    void register(string route_name, IComponent component);
    void use_route(string route_name);
    IComponent get_current();
}

class ComponentRouter : IRouter {
    string current_route;
    IComponent[string] components;
    void register(string route_name, IComponent component) {
        components[route_name] = component;
    }

    void use_route(string route_name) {
        current_route = route_name;
    }

    IComponent get_current() {
        return components[current_route];
    }
}

struct FrameBuffer {
    int width;
    int height; 
}


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
    double dt;

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
            router.get_current().run(context);

            glfwSwapBuffers(window);
            glfwPollEvents();
            dt = glfwGetTime() - start_time;
        }
    }
}

void main() {
    ComponentRouter router = new ComponentRouter();
    router.register("simple_triangle", new SimpleTriangle());
    router.use_route("simple_triangle");
    App app = new App(router);
    app.run();
}

struct Vertex
{
    float x, y;
    float r, g, b;
} 

class SimpleTriangle : IComponent
{
    bool is_init;
    GLint program;

    string vertex_shader_text =
    "attribute vec3 vCol;\n" ~
    "attribute vec2 vPos;\n" ~
    "varying vec3 color;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    gl_Position = vec4(vPos, 0.0, 1.0);\n" ~
    "    color = vCol;\n" ~
    "}\n";

    string fragment_shader_text =
    "varying vec3 color;\n" ~
    "void main()\n" ~
    "{\n" ~
    "    gl_FragColor = vec4(color, 1.0);\n" ~
    "}\n";

    Vertex[3] vertices =
    [
        Vertex( -0.6f, -0.4f, 1f, 0f, 0f ),
        Vertex(  0.6f, -0.4f, 0f, 1f, 0f ),
        Vertex(  0f,  0.6f, 0f, 0f, 1f )
    ];

    void run(Context ctx) {
        if (!is_init) {
            is_init = true;
            GLuint vertex_buffer, vertex_shader, fragment_shader;
            GLint vpos_location, vcol_location;

            import std.string;
            glGenBuffers(1, &vertex_buffer);
            glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
            glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, cast(const void*)(vertices), GL_STATIC_DRAW);

            vertex_shader = glCreateShader(GL_VERTEX_SHADER);
            const char* vst = toStringz(vertex_shader_text);
            glShaderSource(vertex_shader, 1, &vst, null);
            glCompileShader(vertex_shader);

            fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
            const char* fst = toStringz(fragment_shader_text);
            glShaderSource(fragment_shader, 1, &fst, null);
            glCompileShader(fragment_shader);

            program = glCreateProgram();
            glAttachShader(program, vertex_shader);
            glAttachShader(program, fragment_shader);
            glLinkProgram(program);

            vpos_location = glGetAttribLocation(program, "vPos");
            vcol_location = glGetAttribLocation(program, "vCol");
            glEnableVertexAttribArray(vpos_location);
            glVertexAttribPointer(vpos_location, 2, GL_FLOAT, GL_FALSE,
                                  float.sizeof * 5, cast(void*) 0);
            glEnableVertexAttribArray(vcol_location);
            glVertexAttribPointer(vcol_location, 3, GL_FLOAT, GL_FALSE,
                                  float.sizeof * 5, cast(void*) (float.sizeof * 2));
        }
        glUseProgram(program);
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
}


