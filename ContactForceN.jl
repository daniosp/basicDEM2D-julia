@with_kw mutable struct ContactForceN
    # Normal contact force parameters
 
    type::String = "none"  # Type of normal contact force
    formula::String = "none"  # Formula for normal contact force
    CoR::Float64 = 0.0  # Coefficient of restitution for normal contact force
    k_n::Float64 = 0.0  # Stiffness for normal contact force
    gamma_n::Float64 = 0.0  # Damping coefficient for normal contact force

    total_force::Float64 = 0.0  # Total normal force magnitude
end

