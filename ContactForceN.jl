@with_kw mutable struct ContactForceN
    # Normal contact force parameters
 
    type::String = "none"  # Type of normal contact force
    formula::String = "none"  # Formula for normal contact force
    CoR::Float64 = 0.0  # Coefficient of restitution for normal contact force
    k_n::Float64 = 0.0  # Stiffness for normal contact force
    gamma_n::Float64 = 0.0  # Damping coefficient for normal contact force

    total_force::Float64 = 0.0  # Total normal force magnitude
end

function compute_normal_force!(interaction::Interaction)
    # Compute normal force based on the effective properties of the interaction
    # and the kinematic properties of the particles involved in the interaction
    # This function is called within the force_computation_routine! function
    # to calculate the normal force for each interaction.

    # Placeholder for normal force computation logic

    p1 = interaction.particle1  # First particle in the interaction
    p2 = interaction.particle2  # Second particle in the interaction
    bin = interaction.kinemat  # Kinematic properties of the interaction 
    cforce_n = interaction.cforce_n  # Normal contact force parameters

    if cforce_n.type == "viscoelastic_linear"

        beta = pi/log(cforce_n.CoR)

        if cforce_n.formula == "energy"
            # Equivalent maximum strain energy 
            cforce_n.k_n = 1.053*(abs(bin.ini_overlap_vel_n)*interaction.eff_radius*interaction.eff_young^2*interaction.eff_mass^0.5)^(2/5)
 
        elseif cforce_n.formula == "overlap"
            # Equivalent maximum overlap
            cforce_n.k_n = 1.053*(abs(bin.ini_overlap_vel_n)*interaction.eff_radius*interaction.eff_young^2*interaction.eff_mass^0.5)^(2/5) * (exp(-atan(beta)/beta))^2

        elseif cforce_n.formula == "time"
            # Equivalent collision duration
            cforce_n.k_n = 1.198*(abs(bin.ini_overlap_vel_n)*interaction.eff_radius*interaction.eff_young^2*interaction.eff_mass^0.5)^(2/5) * (1+beta^(-2)) 

        end

        cforce_n.gamma_n = sqrt((4*interaction.eff_mass*cforce_n.k_n)/(1+beta^2))  # Damping coefficient

        elastic_force = cforce_n.k_n * bin.overlap_n  
        damping_force = cforce_n.gamma_n * bin.overlap_vel_n

    elseif cforce_n.type == "none"
        elastic_force = 0.0  # Reset elastic force if type is none
        damping_force = 0.0  # Reset damping force if type is none 
    end

    cforce_n.total_force = elastic_force + damping_force  # Magnitude of the contact force

    if cforce_n.total_force >= 0 # Check if the force magnitude is positive
        p1.force -= cforce_n.total_force*bin.dir_n 
        p2.force += cforce_n.total_force*bin.dir_n   

    else 
        cforce_n.total_force = 0.0  # Reset force if negative
    end

end
