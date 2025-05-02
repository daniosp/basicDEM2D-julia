#=
Particle Structure Definition
last update: 04-09-2025

Universidad EAFIT
Medellín, Colombia
Department of Mechanical Engineering

by Daniel Ospina Pajoy
prof. Juan Manuel Rodriguez Prieto
=#


@with_kw mutable struct Particle
    id::Int64 = 0                 # Default Particle ID

    # Kinematic Properties
    coord::Vector{Float64} = [0.0, 0.0]  # Default position vector
    vel_trl::Vector{Float64} = [0.0, 0.0]  # Default velocity vector
    acc_trl::Vector{Float64} = [0.0, 0.0]  # Default acceleration vector

    # Physical Properties
    mass::Float64  = 1.0                   # Default mass of the particle
    radius::Float64 = 1.0         # Default radius of the particle
    volume::Float64  = 1.0         # Default volume (calculated from radius)
    material::Material = Material(density=1.0)  # Default material with density
    
    # Forcing terms
    force::Vector{Float64} = [0.0, 0.0]  # Default force vector

    # Store Results
    pos_hist::Vector{Vector{Float64}} = []  # Default empty position history
    vel_hist::Vector{Vector{Float64}} = []  # Default empty velocity history
    acc_hist::Vector{Vector{Float64}} = []  # Default empty acceleration history
    force_hist::Vector{Vector{Float64}} = []  # Default empty force history
end
# _________________________________________________________________________

# Particle methods

function initialize_densityprops(p::Particle)
    p.volume = 4/3 * pi * p.radius^3
    p.mass = p.volume * p.material.density
    return p
end