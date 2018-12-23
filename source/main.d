import manager.app;
import manager.router;
import manager.component;
import component.simple_triangle;
import component.textured_quad;
import component.points;
import component.moving_point;
import component.moving_points;
import util.ext_lib;


void main() {
    load_stb_lib("../lib/stb/stb.dylib");
    auto router = new ComponentRouter();
    router.register("simple_triangle", new SimpleTriangle());
    router.register("textured_quad", new TexturedQuad());
    router.register("points", new Points());
    router.register("moving_point", new MovingPoint());
    router.register("moving_points", new MovingPoints());
    router.use_route("moving_point");

    auto app = new App(router);
    app.run();
}

