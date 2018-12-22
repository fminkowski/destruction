import manager.app;
import manager.router;
import manager.component;
import component.simple_triangle;
import component.textured_quad;
import util.ext_lib;


void main() {
    load_stb_lib("../lib/stb/stb.dylib");
    auto router = new ComponentRouter();
    router.register("simple_triangle", new SimpleTriangle());
    router.register("textured_quad", new TexturedQuad());
    router.use_route("simple_triangle");

    auto app = new App(router);
    app.run();
}

