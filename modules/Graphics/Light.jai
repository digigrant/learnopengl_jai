DirectionalLight :: struct {
    direction : Vector3;    // this could also be a vec4 - w=0

    ambient_color : Vector3;
    diffuse_color : Vector3;
    specular_color : Vector3;
    name : string;
};

PointLight :: struct {
    position : Vector3;

    ambient_color : Vector3;
    diffuse_color : Vector3;
    specular_color : Vector3;
    name : string;

    constant : float;
    linear : float;
    quadratic : float;
};

SpotLight :: struct {
    position : Vector3;
    direction : Vector3;

    ambient_color : Vector3;
    diffuse_color : Vector3;
    specular_color : Vector3;
    name : string;

    constant : float;
    linear : float;
    quadratic : float;

    inner_cutoff : float;
    outer_cutoff : float;
};

