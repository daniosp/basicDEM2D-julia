#=
Interactions
last update: 04-17-2025

Universidad EAFIT
Medellín, Colombia
Department of Mechanical Engineering

by Daniel Ospina Pajoy
prof. Juan Manuel Rodriguez Prieto
=#

@with_kw mutable struct Interaction
    particle1::Particle = Particle()  # First particle in the interaction
    particle2::Particle = Particle() # Second particle in the interaction

    eff_radius::Float64 = 0.0  # Effective radius for the interaction
    eff_mass::Float64 = 0.0  # Effective mass for the interaction
    eff_young::Float64 = 0.0  # Effective Young's modulus for the interaction

    kinemat::BinKinematics = BinKinematics() # Kinematic properties of the interaction

    in_list::Bool = false  # Flag to check if interaction is in the list
    in_search::Bool = false  # Flag to check if interaction is in the search algorithm
end

function compute_effprops!(interaction::Interaction)  # Compute effective properties for the interaction
    # Calculate effective radius, mass, and Young's modulus based on the two particles involved in the interaction
    interaction.eff_radius = (1/interaction.particle1.radius + 1/interaction.particle2.radius)^(-1)  # Effective radius
    interaction.eff_mass = (interaction.particle1.mass * interaction.particle2.mass) / (interaction.particle1.mass + interaction.particle2.mass)
    interaction.eff_young = ((1-interaction.particle1.material.poisson_ratio^2) / interaction.particle1.material.elastic_modulus + (1-interaction.particle2.material.poisson_ratio^2) / interaction.particle2.material.elastic_modulus)^(-1)  # Effective Young's modulus
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
        push!(interaction_list, copy(new_interaction))  # Add new interaction to the list
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