@with_kw mutable struct BinKinematics
    # Relative position
    dir ::Vector{Float64} = [0.0, 0.0]
    dist ::Float64 = 0.0

    # Relative velocity
    rel_vel::Vector{Float64} = [0.0, 0.0]
    rel_n_vel::Vector{Float64} = [0.0, 0.0]
    rel_t_vel::Vector{Float64} = [0.0, 0.0]

    # Normal overlap parameters
    dir_n ::Vector{Float64} = [0.0, 0.0]
    overlap_n ::Float64 = 0.0
    overlap_vel_n ::Float64 = 0.0

    # Tangential overlap parameters
    dir_t ::Vector{Float64} = [0.0, 0.0]
    overlap_t ::Float64 = 0.0
    overlap_vel_t ::Float64 = 0.0

    # Contact parameters
    in_contact ::Bool = false
    ini_overlap_vel_n ::Float64 = 0.0 # Initial overlap velocity on contact
end


function initialize_binKinematics(bin::BinKinematics,particle1::Particle,particle2::Particle, dt::Float64)

    bin.dir = particle2.coord - particle1.coord  # Calculate direction vector between particles
    bin.dist = norm(bin.dir)  # Calculate distance between particle
    
    # Normal Overlap and Unit Vector
    bin.overlap_n = (particle1.radius + particle2.radius) - bin.dist  # Calculate normal overlap
    bin.dir_n = bin.dir / bin.dist  # Normalize the direction vector

    # Positions of the contact points relative to the centroids (It is assumed as half of the overlap)
    c1 = (particle1.radius - bin.overlap_n/2) * bin.dir_n  # Contact point on particle 1
    c2 = (particle2.radius - bin.overlap_n/2) * bin.dir_n  # Contact point on particle 2

    # Velocities at contact points
    w1 = cross([0; 0; particle1.vel_rot] , [c1[1]; c1[2]; 0])  # Angular velocity of particle 1
    w2 = cross([0; 0; particle2.vel_rot] , [c2[1]; c2[2]; 0])  # Angular velocity of particle 2
    vc1 = particle1.vel_trl + w1[1:2]  # Linear velocity of contact point on particle 1
    vc2 = particle2.vel_trl + w2[1:2]  # Linear velocity of contact point on particle 2

    # Relative velocity at contact point
    bin.rel_vel = vc1 - vc2 # Calculate relative translational velocity vector

    # Calculate normal overlap velocity
    bin.overlap_vel_n = dot(bin.rel_vel,bin.dir_n)  

    # Calculate tangential relative velocity
    bin.rel_t_vel = bin.rel_vel - bin.overlap_vel_n * bin.dir_n  # Calculate tangential relative velocity vector

    # Tangential unit vector
    if norm(bin.rel_t_vel) > 0.0
        bin.dir_t = bin.rel_t_vel / norm(bin.rel_t_vel)  # Normalize the tangential direction vector
    else
        bin.dir_t = [0.0, 0.0]  # Set to zero if no tangential velocity
    end

    # Calculate tangential overlap velocity
    bin.overlap_vel_t = dot(bin.rel_vel,bin.dir_t)  # Calculate tangential overlap velocity

    # Calculate tangential overlap

    if bin.overlap_t < 1e-14
        bin.overlap_t = bin.overlap_vel_t * dt  # Calculate tangential overlap
    else
        bin.overlap_t += bin.overlap_vel_t * dt  # Update tangential overlap
    end

end