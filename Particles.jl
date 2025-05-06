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

    # Geometric Properties
    radius::Float64 = 1.0         # Default radius of the particle
    volume::Float64  = 1.0         # Default volume (calculated from radius)
    m_inertia::Float64 = 0.0      # Default mass moment of inertia (calculated from radius)

    # Physical Properties
    material::Material = Material(density=1.0)  # Default material with density
    mass::Float64  = 1.0                   # Default mass of the particle
    
    # Forcing terms
    force::Vector{Float64} = [0.0, 0.0]  # Default force vector
    torque::Float64 = 0.0  # Default torque value (Torque is managed as a scalar for 2D problems)

    # Kinematic Properties
    coord::Vector{Float64} = [0.0, 0.0]  # Default position vector
    orient::Float64 = 0.0  # Default orientation angle

    vel_trl::Vector{Float64} = [0.0, 0.0]  # Default velocity vector
    vel_rot::Float64 = 0.0  # Default angular velocity (scalar for 2D problems)

    acc_trl::Vector{Float64} = [0.0, 0.0]  # Default acceleration vector
    acc_rot::Float64 = 0.0  # Default angular acceleration (scalar for 2D problems)

    # Store Results
    coord_hist::Vector{Vector{Float64}} = []  # Default empty position history
    orient_hist::Vector{Float64} = []  # Default empty orientation history
    vel_trl_hist::Vector{Vector{Float64}} = []  # Default empty velocity history
    vel_rot_hist::Vector{Float64} = []  # Default empty angular velocity history
    acc_trl_hist::Vector{Vector{Float64}} = []  # Default empty acceleration history
    acc_rot_hist::Vector{Float64} = []  # Default empty angular acceleration history
    force_hist::Vector{Vector{Float64}} = []  # Default empty force history
    torque_hist::Vector{Float64} = []  # Default empty torque history
end
# _________________________________________________________________________

# Particle methods

function initialize_props(p::Particle)
    p.volume = 4/3 * pi * p.radius^3
    p.mass = p.volume * p.material.density
    p.m_inertia = (2/5) * p.mass * p.radius^2  # Moment of inertia for a solid sphere
    return p
end