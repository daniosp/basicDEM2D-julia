# Receives list of interactions

function force_computation_routine!(interaction_list::Vector{Interaction}, CoR::Float64, dt::Float64)
    
        # Iterate through each interaction in the list
    for interaction in interaction_list 

        p1 = interaction.particle1  # First particle in the interaction
        p2 = interaction.particle2  # Second particle in the interaction
        bin = interaction.kinemat  # Kinematic properties of the interaction 

        # Start over forces
        p1.force = [0.0, 0.0]  # Reset force vector for particle 1
        p2.force = [0.0, 0.0]  # Reset force vector for particle 2

        initialize_binKinematics(bin, p1, p2, dt)

        if bin.overlap_n > 0.0 && bin.in_contact == false  # Check if particles are overlapping and not already in contact
            bin.in_contact = true  # Set contact flag to true
            bin.ini_overlap_vel_n = dot(bin.rel_vel_trl,bin.dir_n)  # Calculate initial overlap velocity
        end

        if bin.overlap_n > 0.0

            # Read contact force parameters from input file

            compute_normal_force!(interaction,CoR)


        elseif bin.overlap_n <= 0.0
            bin.in_contact = false  # Set contact flag to false
            bin.ini_overlap_vel_n = 0.0  # Reset initial overlap velocity
        end

    end

end
