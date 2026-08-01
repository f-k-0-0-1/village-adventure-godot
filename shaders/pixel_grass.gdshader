shader_type canvas_item;

// Customization for individual pixel-art grass tufts
uniform vec4 grass_color : source_color = vec4(0.38, 0.65, 0.32, 1.0); // Cozy green
uniform vec4 highlight_color : source_color = vec4(0.58, 0.82, 0.45, 1.0); // Blade tip highlight
uniform float density : hint_range(5.0, 50.0) = 20.0; // How clustered the grass is
uniform float wind_speed : hint_range(0.0, 5.0) = 2.0;
uniform float wind_strength : hint_range(0.0, 0.2) = 0.05;

// Pseudo-random hash function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // Scale coordinates by density to create a field grid
    vec2 grid = UV * density;
    vec2 cell_index = floor(grid);
    vec2 cell_uv = fract(grid);
    
    // Randomize presence of grass per cell (creates sparse, natural tufts instead of full fill)
    float presence = random(cell_index);
    if (presence < 0.6) {
        discard; // Hide pixels where grass doesn't exist, leaving background transparent
    }
    
    // Add wind sway effect that increases towards the top of the grass blade
    float wind = sin(TIME * wind_speed + cell_index.x) * wind_strength * cell_uv.y;
    float adjusted_x = cell_uv.x + wind;
    
    // Shape a pixel-art V-shaped or pointed grass blade tuft inside the cell
    float blade_width = 0.25;
    float center_dist = abs(adjusted_x - 0.5);
    
    // Taper the blade as it goes up (cell_uv.y goes from 0 at bottom to 1 at top)
    float height_limit = 0.8 - (random(cell_index + 1.0) * 0.3);
    
    if (cell_uv.y > height_limit || center_dist > (blade_width * (1.0 - cell_uv.y * 0.5))) {
        discard; // Discard pixels outside the blade shape for complete transparency
    }
    
    // Color gradient: darker at the base, highlighted at the tip
    vec4 final_color = mix(grass_color, highlight_color, cell_uv.y);
    
    COLOR = final_color;
}