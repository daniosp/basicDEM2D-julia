@with_kw mutable struct ContactForceT
    # Normal contact force parameters
 
    type::String = "none"  # Type of normal contact force
    k_t::Float64 = 0.0  # Stiffness for normal contact force
    mu_fric::Float64 = 0.0  # Friction coefficient

    total_force::Float64 = 0.0  # Total tangential force magnitude
end


function compute_tangential_force!(interaction::Interaction)

    p1 = interaction.particle1  # First particle in the interaction
    p2 = interaction.particle2  # Second particle in the interaction
    bin = interaction.kinemat  # Kinematic properties of the interaction 
    cforce_n = interaction.cforce_n  # Normal contact force parameters
    cforce_t = interaction.cforce_t  # Normal contact force parameters

    if cforce_t.type == "spring_slider"

        if cforce_n.total_force > 0.0 
            cforce_t.k_t = (1-interaction.avg_poisson)/(1-interaction.avg_poisson/2) * cforce_n.k_n  # Tangential stiffness
        else
            cforce_t.k_t = 0.0  # Reset tangential stiffness if normal force is zero
        end

        elastic_force = cforce_t.k_t * bin.overlap_t  # Elastic force

        if cforce_n.total_force > 0.0
            friction_force = cforce_t.mu_fric * cforce_n.total_force  # Friction force
        else
            friction_force = 0.0  # Reset friction force if normal force is zero
        end

    elseif cforce_t.type == "none"
        elastic_force = 0.0  # Reset elastic force if type is none
        friction_force = 0.0  # Reset friction force if type is none

    end
    cforce_t.total_force = min(abs(elastic_force),abs(friction_force))  # Magnitude of the contact force

    p1.force -= cforce_t.total_force*bin.dir_t 
    p2.force += cforce_t.total_force*bin.dir_t   

end

function compute_tangential_torque!(interaction::Interaction)

    p1 = interaction.particle1  # First particle in the interaction
    p2 = interaction.particle2  # Second particle in the interaction
    bin = interaction.kinemat  # Kinematic properties of the interaction

    # Tangential force vector for each particle
    ft1 = -interaction.cforce_t.total_force *bin.dir_t 
    ft2 = -ft1

    # Lever arm for each particle; Assuming half of the overlap
    lever_arm1 = (p1.radius - bin.overlap_n/2) * bin.dir_n
    lever_arm2 = -(p2.radius - bin.overlap_n/2) * bin.dir_n

    torque1 = cross([lever_arm1[1]; lever_arm1[2]; 0 ], [ft1[1]; ft1[2];0])[3] # Torque for particle 1
    torque2 = cross([lever_arm2[1]; lever_arm2[2]; 0 ], [ft2[1]; ft2[2];0])[3] # Torque for particle 2

    p1.torque += torque1  # Update torque for particle 1
    p2.torque += torque2  # Update torque for particle 2

end