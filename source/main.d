import manager.app;
import manager.router;
import manager.component;
import component.simple_triangle;


void main() {
    auto router = new ComponentRouter();
    router.register("simple_triangle", new SimpleTriangle());
    router.use_route("simple_triangle");

    auto app = new App(router);
    app.run();
}

