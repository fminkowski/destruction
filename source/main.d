import app;
import router;
import component;
import simple_triangle;


void main() {
    auto router = new ComponentRouter();
    router.register("simple_triangle", new SimpleTriangle());
    router.use_route("simple_triangle");
    auto app = new App(router);
    app.run();
}

