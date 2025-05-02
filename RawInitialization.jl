# Raw initialization

function raw_initialization()

# Simulation Time Parameters
framerate = 200;
dt = 0.01;
simulation_time = 0.2;
current_time = 0.0;

# Physics Parameters
CoR = 0.7 # Coefficient of Restitution

cell_size = 0.5*2 # Same as particle diameter
grid = Grid(cell_size)

test_material = Material(name="Test Material", density=1e3, elastic_modulus=1e7, poisson_ratio=0.3)

# Initializing Particles

                # id, pos, vel, acc, mass, radius, r_hist
p1 = Particle(id=1, coord=[-0.5, 0.0], vel_trl=[2.0, 0.0], radius=0.5, material=test_material)
initialize_densityprops(p1) # Initialize density properties


p2 = Particle(id=2, coord=[0.6, 0.0], vel_trl=[-2.0, 0.0], radius=0.5, material=test_material)
initialize_densityprops(p2) # Initialize density properties

particles = [p1,p2]

# Initializing History Variables
for p in particles
    p.pos_hist = copy([p.coord])
    p.vel_hist = copy([p.vel_trl])
    p.acc_hist = copy([p.acc_trl])
end

interaction_list = Interaction[]  # Initialize empty interaction list


search_alg = "simple_loop"

return particles, interaction_list, search_alg, dt, simulation_time, current_time, CoR, grid

end



