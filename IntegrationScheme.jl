

function update_particle!(particle::Particle, dt::Float64)
    #=
    This function updates the position and velocity of a particle based on its current state and the time step.
    =#

    new_acceleration = particle.force / particle.mass  # Calculate new acceleration based on force and mass
    particle.acc_trl = new_acceleration  # Update acceleration
    particle.vel_trl += new_acceleration * dt  # Update velocity based on acceleration and time step
    particle.coord += particle.vel_trl * dt  # Update position based on velocity and time step

    particle.pos_hist = push!(particle.pos_hist, copy(particle.coord))  # Store position history
    particle.vel_hist = push!(particle.vel_hist, copy(particle.vel_trl))  # Store velocity history
    particle.acc_hist = push!(particle.acc_hist, copy(particle.acc_trl))  # Store acceleration history
    particle.force_hist = push!(particle.force_hist, copy(particle.force))  # Store force history
end



