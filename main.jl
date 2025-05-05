#=
basicDEM2D is a simple Discrete Element Method (DEM) software package for 2D simulations.
last update: 04-09-2025

Universidad EAFIT
Medellín, Colombia
Department of Mechanical Engineering

by Daniel Ospina Pajoy
prof. Juan Manuel Rodriguez Prieto
=#

# Import Required Packages 

using ImageMagick
using Plots
using LinearAlgebra
using Parameters

include("Materials.jl")
include("Particles.jl")
include("BinKinematics.jl")
include("Interactions.jl")
include("SearchAlgs_EqSPatialPart.jl")

include("IntegrationScheme.jl")
include("ForcesCompRoutine.jl")

include("RawInitialization.jl")
include("SearchAlgsRoutine.jl")


Base.copy(x::T) where T = T([getfield(x, k) for k ∈ fieldnames(T)]...)



# Read input files

# Assign Input
# # Particles information
# # Search Algorithm information
# # Contact information
# # Simulation time information

# Process

# Start vector results

# # Start main simulation loop
# # # Reset and Search Algorithm
# # # Reset and Identify interactions
# # # # Compute contacts for each interaction
# # # # Upadte forces and moments
# # # # Update particle kinematics
# # # # Save results

# Post-Processing
# Animation
# Plotting
# Output files

function main()

    particles, interaction_list, search_alg, dt, simulation_time, current_time, CoR, grid = raw_initialization()

    while current_time <= simulation_time

        interaction_list = search_algorithm_routine!(interaction_list, particles, search_alg, grid)

        force_computation_routine!(interaction_list, CoR, dt)

        for particle in particles
            update_particle!(particle, dt)
        end
        

        current_time += dt
    end

    animation = @animate for i in 1:length(particles[1].pos_hist)

        x, y = circleShape(particles[1].pos_hist[i][1], particles[1].pos_hist[i][2], particles[1].radius)
        plot(x, y, xlim=(-2, 2), ylim=(-2, 2), ratio=1, legend=false, c=:green, plot_title="Binary Collision")
    
        for p in particles[2:end]
            x, y = circleShape(p.pos_hist[i][1], p.pos_hist[i][2], p.radius)
            plot!(x, y, xlim=(-2, 2), ylim=(-2, 2), ratio=1, legend=false, c=:green)
        end
    
    end
    
    gif(animation, "./results/testMicCheck12.gif", fps = 200)

    pos_p1 = first.(particles[1].pos_hist)
    outfile = "./results/Horizontal Position basicDEM.txt"
    open(outfile, "w") do f
      for i in pos_p1
        println(f, i)
      end
    end # the file f is automatically closed after this block finishes
    
    vel_p1 = first.(particles[1].vel_hist)
    outfile = "./results/Horizontal Velocity basicDEM.txt"
    open(outfile, "w") do f
      for i in vel_p1
        println(f, i)
      end
    end # the file f is automatically closed after this block finishes
    
    acc_p1 = first.(particles[1].acc_hist)
    outfile = "./results/Horizontal Acceleration basicDEM.txt"
    open(outfile, "w") do f
      for i in acc_p1
        println(f, i)
      end
    end # the file f is automatically closed after this block finishes
    

end

function circleShape(h,k,r)

    #=
    This function returns the x and y coordinates of a circle with center (h,k) and radius r. 
    =#

    θ = LinRange(0, 2π, 100)
    x = h .+ r*cos.(θ)
    y = k .+ r*sin.(θ)
    return x,y

end


main()