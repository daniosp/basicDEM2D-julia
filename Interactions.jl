#=
Interactions
last update: 04-17-2025

Universidad EAFIT
Medellín, Colombia
Department of Mechanical Engineering

by Daniel Ospina Pajoy
prof. Juan Manuel Rodriguez Prieto
=#

include("ContactForceN.jl")
include("ContactForceT.jl")

@with_kw mutable struct Interaction
    particle1::Particle = Particle()  # First particle in the interaction
    particle2::Particle = Particle() # Second particle in the interaction

    eff_radius::Float64 = 0.0  # Effective radius for the interaction
    eff_mass::Float64 = 0.0  # Effective mass for the interaction
    eff_young::Float64 = 0.0  # Effective Young's modulus for the interaction
    avg_poisson::Float64 = 0.0  # Average Poisson's ratio for the interaction

    kinemat::BinKinematics = BinKinematics() # Kinematic properties of the interaction
    cforce_n::ContactForceN = ContactForceN()  # Normal contact force parameters
    cforce_t::ContactForceT = ContactForceT()  # Tangential contact force parameters

    in_list::Bool = false  # Flag to check if interaction is in the list
    in_search::Bool = false  # Flag to check if interaction is in the search algorithm
end

function compute_effprops!(interaction::Interaction)  # Compute effective properties for the interaction
    # Calculate effective radius, mass, and Young's modulus based on the two particles involved in the interaction
    interaction.eff_radius = (1/interaction.particle1.radius + 1/interaction.particle2.radius)^(-1)  # Effective radius
    interaction.eff_mass = (interaction.particle1.mass * interaction.particle2.mass) / (interaction.particle1.mass + interaction.particle2.mass)
    interaction.eff_young = ((1-interaction.particle1.material.poisson_ratio^2) / interaction.particle1.material.elastic_modulus + (1-interaction.particle2.material.poisson_ratio^2) / interaction.particle2.material.elastic_modulus)^(-1)  # Effective Young's modulus
    interaction.avg_poisson = (interaction.particle1.material.poisson_ratio + interaction.particle2.material.poisson_ratio) / 2  # Average Poisson's ratio
end

function manage_interaction_list!(interaction_list::Vector{Interaction},new_interaction::Interaction)  # Add interaction between particles

    new_interaction.in_list = false  # Set flag to true for the new interaction
    new_interaction.in_search = true  # Set flag to true for the new interaction

    for int in interaction_list
        if (int.particle1.id == new_interaction.particle1.id && int.particle2.id == new_interaction.particle2.id) || (int.particle1.id == new_interaction.particle2.id && int.particle2.id == new_interaction.particle1.id)
            int.in_list = true  # Interaction already exists
            int.in_search = true  # Set flag to true for the existing interaction
            
            new_interaction.in_list = true  # Set flag to true for the new interaction
            break
        end
    end

    if new_interaction.in_list == false  # If interaction is not in the list, add it
        push!(interaction_list, deepcopy(new_interaction))  # Add new interaction to the list
    end
end

function reset_interaction_searchflag!(interaction_list::Vector{Interaction})  # Reset interaction list
    for int in interaction_list
        int.in_search = false  # Reset flag for all interactions in the list
    end
end


function pop_from_interaction_list!(interaction_list::Vector{Interaction})
    filter!(int -> int.in_search == true, interaction_list)

    return interaction_list  # Return updated interaction list
end

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


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

    p1.torque = torque1  # Update torque for particle 1
    p2.torque = torque2  # Update torque for particle 2

end

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


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
