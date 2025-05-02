@with_kw mutable struct BinKinematics
    # Relative position
    dir ::Vector{Float64} = [0.0, 0.0]
    dist ::Float64 = 0.0

    # Relative velocity
    rel_vel_trl ::Vector{Float64} = [0.0, 0.0]

    # Normal overlap parameters
    dir_n ::Vector{Float64} = [0.0, 0.0]
    overlap_n ::Float64 = 0.0
    overlap_vel_n ::Float64 = 0.0

    # Contact parameters
    in_contact ::Bool = false
    ini_overlap_vel_n ::Float64 = 0.0
end

function initialize_binKinematics(bin::BinKinematics,particle1::Particle,particle2::Particle)

    bin.dir = particle2.coord - particle1.coord  # Calculate direction vector between particles
    bin.dist = norm(bin.dir)  # Calculate distance between particles

    bin.rel_vel_trl = particle1.vel_trl - particle2.vel_trl  # Calculate relative translational velocity vector

    bin.dir_n = bin.dir / bin.dist  # Normalize the direction vector
    bin.overlap_n = (particle1.radius + particle2.radius) - bin.dist  # Calculate normal overlap
    bin.overlap_vel_n = dot(bin.rel_vel_trl,bin.dir_n)  # Calculate normal overlap velocity
    return bin
end