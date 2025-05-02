#=
Search Algorithms
last update: 04-17-2025

Universidad EAFIT
Medellín, Colombia
Department of Mechanical Engineering

by Daniel Ospina Pajoy
prof. Juan Manuel Rodriguez Prieto
=#

# particles: List of Particle objects in the simulation
# grid: Spatial grid for the simulation (if using equal spatial partitioning)


function search_algorithm_routine!(interaction_list::Vector{Interaction}, particles::Vector{Particle}, search_alg::String, grid::Grid)

    #=
    This function manages the search algorithm for interactions between particles.
    It can use either a simple loop or an equal spatial partitioning algorithm.
    =#

    # Reset interaction list and search flags

reset_interaction_searchflag!(interaction_list)

if search_alg == "simple_loop"
    for particle in particles
        for neighbor in particles
            if particle.id !== neighbor.id  # Avoid self-interaction

                temp_int = Interaction(particle1=particle, particle2=neighbor)  # Create interaction object
                compute_effprops!(temp_int)  # Compute effective properties for the interaction
                manage_interaction_list!(interaction_list, temp_int)  # Add interaction to the list
                temp_int = nothing  # Clear temporary interaction object
                return interaction_list
            end
        end
    end

elseif search_alg == "eq_spatial_part"

    empty!(grid.cells) # Clear grid

    for particle in particles
        add_particle!(grid, particle)  # Rebuild grid and identify particles in corresponindg bins
    end

    for particle in particles
        # Find neighboring particles
        neighbors = get_neighbors(grid, particle)
        for neighbor in neighbors
            if particle.id !== neighbor.id  # Avoid self-interaction

                temp_int = Interaction(particle1=particle, particle2=neighbor)  # Create interaction object
                compute_effprops!(temp_int)  # Compute effective properties for the interaction
                manage_interaction_list!(interaction_list, temp_int)  # Add interaction to the list
                temp_int = nothing  # Clear temporary interaction object
                return interaction_list
            end
        end
    end
end

interaction_list = pop_from_interaction_list!(interaction_list)

end