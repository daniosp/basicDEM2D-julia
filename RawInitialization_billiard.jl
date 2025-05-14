# Raw initialization

function raw_initialization_billiard()

# Simulation Time Parameters
framerate = 200;
dt = 0.1;
simulation_time = 3;
current_time = 0.0;

# Physics Parameters
CoR = 0.7 # Coefficient of Restitution


particle_radius = 0.5
cell_size = particle_radius*2 # Same as particle diameter
grid = Grid(cell_size)

test_material = Material(name="Test Material", density=2e3, elastic_modulus=3e6, poisson_ratio=0.3)

# Initializing Particles

                # id, pos, vel, acc, mass, radius, r_hist
part1 = Particle(id=1, coord=[-1.0, 0.0], vel_trl=[2.0, 0.5],vel_rot=1.0, radius=0.5, material=test_material)
part2 = Particle(id=2, coord=[1.0, 0.0], radius=0.5, material=test_material)
part3 = Particle(id=3, coord=[1.0+cos(pi/4)*2*particle_radius+1e-3, cos(pi/4)*2*particle_radius+1e-3], radius=0.5, material=test_material)
part4 = Particle(id=4, coord=[1.0+cos(pi/4)*2*particle_radius+1e-3, -cos(pi/4)*2*particle_radius+1e-3], radius=0.5, material=test_material)

particles = [part1,part2,part3,part4]
# Initializing Particle Properties

for p in particles
    initialize_props(p) # Initialize density properties
end

# Initializing History Variables
for p in particles
    p.coord_hist = copy([p.coord])
    p.orient_hist = copy([p.orient])
    p.vel_trl_hist = copy([p.vel_trl])
    p.vel_rot_hist = copy([p.vel_rot])
    p.acc_trl_hist = copy([p.acc_trl])
    p.acc_rot_hist = copy([p.acc_rot])
    #p.force_hist = copy([p.force])
    #p.torque_hist = copy([p.torque])
end

interaction_list = Interaction[]  # Initialize empty interaction list


search_alg = "eq_spatial_part"

return particles, interaction_list, search_alg, dt, simulation_time, current_time, CoR, grid

end



