#=
Grid structure and methods
last update: 04-17-2025

Universidad EAFIT
Medellín, Colombia
Department of Mechanical Engineering

by Daniel Ospina Pajoy
prof. Juan Manuel Rodriguez Prieto
=#


# _________________________________________________________________________
# Defining the Grid structure

@with_kw mutable struct Grid
    cell_size::Float64
    cells::Dict{Tuple{Int, Int}, Vector{Particle}}
end

function Grid(cell_size::Float64)
    return Grid(cell_size, Dict{Tuple{Int, Int}, Vector{Particle}}())
end
# _________________________________________________________________________

# Defining the Grid Methods

function get_cell_index(position::Vector{Float64}, cell_size::Float64)
    return (floor(Int, position[1] / cell_size), floor(Int, position[2] / cell_size))
end

function add_particle!(grid::Grid, particle::Particle)
    cell_index = get_cell_index(particle.coord, grid.cell_size)
    if haskey(grid.cells, cell_index)
        push!(grid.cells[cell_index], particle)
    else
        grid.cells[cell_index] = [particle]
    end
end

function get_neighbors(grid::Grid, particle::Particle)
    cell_index = get_cell_index(particle.coord, grid.cell_size)
    neighbors = Particle[]

    for dx in -1:1, dy in -1:1  # Check surrounding cells
        neighbor_index = (cell_index[1] + dx, cell_index[2] + dy)
        if haskey(grid.cells, neighbor_index)
            append!(neighbors, grid.cells[neighbor_index])
        end
    end

    return neighbors
end