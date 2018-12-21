import component;

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
