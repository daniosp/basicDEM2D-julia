@with_kw mutable struct ContactForceT
    # Normal contact force parameters
 
    type::String = "none"  # Type of normal contact force
    k_t::Float64 = 0.0  # Stiffness for normal contact force
    mu_fric::Float64 = 0.0  # Friction coefficient

    total_force::Float64 = 0.0  # Total tangential force magnitude
end

