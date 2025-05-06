

function update_particle!(particle::Particle, dt::Float64)
    #=
    This function updates the position and velocity of a particle based on its current state and the time step.
    =#

    new_acceleration = particle.force / particle.mass  # Calculate new acceleration based on force and mass
    particle.acc_trl = new_acceleration  # Update acceleration
    particle.vel_trl += new_acceleration * dt  # Update velocity based on acceleration and time step
    particle.coord += particle.vel_trl * dt  # Update position based on velocity and time step

    new_rot_acceleration = particle.torque / particle.m_inertia  # Calculate new angular acceleration based on torque and inertia
    particle.acc_rot = new_rot_acceleration  # Update angular acceleration
    particle.vel_rot += new_rot_acceleration * dt  # Update angular velocity based on angular acceleration and time step
    particle.orient += particle.vel_rot * dt  # Update orientation based on angular velocity and time step


    particle.coord_hist = push!(particle.coord_hist, copy(particle.coord))  # Store position history
    particle.orient_hist = push!(particle.orient_hist, copy(particle.orient))  # Store orientation history
    particle.vel_trl_hist = push!(particle.vel_trl_hist, copy(particle.vel_trl))  # Store translational velocity history
    particle.vel_rot_hist = push!(particle.vel_rot_hist, copy(particle.vel_rot))  # Store angular velocity history
    particle.acc_trl_hist = push!(particle.acc_trl_hist, copy(particle.acc_trl))  # Store translational acceleration history
    particle.acc_rot_hist = push!(particle.acc_rot_hist, copy(particle.acc_rot))  # Store angular acceleration history
    particle.force_hist = push!(particle.force_hist, copy(particle.force))  # Store force history
    particle.torque_hist = push!(particle.torque_hist, copy(particle.torque))  # Store torque history

end



