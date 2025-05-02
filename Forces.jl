# Receives list of interactions

function force_computation_routine!(interaction_list::Vector{Interaction}, CoR::Float64)
    
        # Iterate through each interaction in the list
    for interaction in interaction_list 

        p1 = interaction.particle1  # First particle in the interaction
        p2 = interaction.particle2  # Second particle in the interaction

        bin = interaction.kinemat  # Kinematic properties of the interaction 

        # Start over forces
        p1.force = [0.0, 0.0]  # Reset force vector for particle 1
        p2.force = [0.0, 0.0]  # Reset force vector for particle 2

        initialize_binKinematics(bin,p1,p2)

        if bin.overlap_n > 0.0 && bin.in_contact == false  # Check if particles are overlapping and not already in contact
            bin.in_contact = true  # Set contact flag to true
            bin.ini_overlap_vel_n = dot(bin.rel_vel_trl,bin.dir_n)  # Calculate initial overlap velocity
        end

        if bin.overlap_n > 0.0
            beta = pi/log(CoR)
            # EQUIVALENT MAXIMUM STRAIN ENERGY FORMULATION
            k_n = 1.053*(abs(bin.ini_overlap_vel_n)*interaction.eff_radius*interaction.eff_young^2*interaction.eff_mass^0.5)^(2/5) # Normal stiffness
            gamma_n = sqrt((4*interaction.eff_mass*k_n)/(1+beta^2))  # Damping coefficient

            elastic_force = k_n * bin.overlap_n  
            damping_force = gamma_n * bin.overlap_vel_n

            force_n_mag = elastic_force + damping_force  # Magnitude of the contact force

            
            println("overlap",bin.overlap_n)
            println("overlap vel",bin.overlap_vel_n)

            if force_n_mag >= 0
                p1.force -= force_n_mag*bin.dir_n 
                p2.force += force_n_mag*bin.dir_n   
            end


        elseif bin.overlap_n <= 0.0
            bin.in_contact = false  # Set contact flag to false
            bin.ini_overlap_vel_n = 0.0  # Reset initial overlap velocity
        end

    end

end