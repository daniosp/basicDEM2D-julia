# Receives list of interactions

function forces_computation_routine!(interaction_list::Vector{Interaction}, dt::Float64)
    
        # Iterate through each interaction in the list
    for interaction in interaction_list 


        p1 = interaction.particle1  # First particle in the interaction
        p2 = interaction.particle2  # Second particle in the interaction
        bin = interaction.kinemat  # Kinematic properties of the interaction 

        # Start over forces
        p1.force = [0.0, 0.0]  # Reset force vector for particle 1
        p2.force = [0.0, 0.0]  # Reset force vector for particle 2
        p1.torque = 0.0  # Reset torque for particle 1
        p2.torque = 0.0  # Reset torque for particle 255

        initialize_binKinematics(bin, p1, p2, dt)
        if bin.overlap_n > 0.0 && bin.in_contact == false  # Check if particles are overlapping and not already in contact
            bin.in_contact = true  # Set contact flag to true
            bin.ini_overlap_vel_n = dot(bin.rel_vel,bin.dir_n)  # Calculate initial overlap velocity
        end

                # Calculate tangential overlap
        if bin.overlap_t < 1e-15 && bin.in_contact == true && bin.first_contact == false  # Check if tangential overlap is not initialized
            bin.first_contact = true  # Set first contact flag to true
            bin.overlap_t = bin.overlap_vel_t * dt  # Calculate tangential overlap
            
        elseif bin.in_contact == true && bin.first_contact == true
            bin.overlap_t += bin.overlap_vel_t * dt  # Update tangential overlap

        else
            bin.first_contact = false  # Reset first contact flag
            bin.overlap_t = 0.0  # Reset tangential overlap if not in contact
        end


        if bin.overlap_n > 0.0

            # Read contact force parameters from input file (CURRENTLY DOING IT MANUALLY)
            interaction.cforce_n.type = "viscoelastic_linear"  # Set contact force type to viscoelastic linear
            interaction.cforce_n.formula = "energy"  # Set contact force formula to energy-based
            interaction.cforce_n.CoR = 0.7  # Set coefficient of restitution for normal contact force

            interaction.cforce_t.type = "spring_slider"  # Set contact force type to viscoelastic linear
            interaction.cforce_t.mu_fric = 0.2 #0.3 for binary comparison# Set friction coefficient for tangential contact force

            compute_normal_force!(interaction)
            compute_tangential_force!(interaction)  # Compute tangential force
            compute_tangential_torque!(interaction)  # Compute tangential torque


        elseif bin.overlap_n <= 0.0
            bin.in_contact = false  # Set contact flag to false
            bin.ini_overlap_vel_n = 0.0  # Reset initial overlap velocity
        end

    end

end
