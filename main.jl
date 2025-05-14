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
include("RawInitialization_billiard.jl")
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

    particles, interaction_list, search_alg, dt, simulation_time, current_time, CoR, grid = raw_initialization_billiard()

    while current_time <= simulation_time

        interaction_list = search_algorithm_routine!(interaction_list, particles, search_alg, grid)
        
        forces_computation_routine!(interaction_list, dt)

        for particle in particles
            update_particle!(particle, dt)
        end

        println(pointer_from_objref(interaction_list[1]))
        println(pointer_from_objref(particles[interaction_list[1].particle1.id]))

        

        current_time += dt
    end

    xlimits = (-2, 3)
    ylimits = (-1, 1)

    animation = @animate for i in 1:length(particles[1].coord_hist)

        x, y = circleShape(particles[1].coord_hist[i][1], particles[1].coord_hist[i][2], particles[1].radius)
        this_plot = plot(x, y, xlim=xlimits, ylim=ylimits, ratio=1, legend=false, c=:black, plot_title="Billiard Animation")

        x, y = radius_orientation(particles[1].coord_hist[i][1],particles[1].coord_hist[i][2], particles[1].radius, particles[1].orient_hist[i])
        plot!(this_plot, x, y, xlim=xlimits, ylim=ylimits, ratio=1, legend=false, c=:black)
    
        for p in particles[2:end]
            x, y = circleShape(p.coord_hist[i][1], p.coord_hist[i][2], p.radius)
            plot!(this_plot, x, y, xlim=xlimits, ylim=ylimits, ratio=1, legend=false, c=:black)

            x, y = radius_orientation(p.coord_hist[i][1],p.coord_hist[i][2], p.radius, p.orient_hist[i])
            plot!(this_plot, x, y, xlim=xlimits, ylim=ylimits, ratio=1, legend=false, c=:black)
        end
    
    end
    
    gif(animation, "./results/billiardTest.gif", fps = 200)

    pos_p1 = first.(particles[1].coord_hist)
    outfile = "./results/Horizontal Position basicDEM.txt"
    open(outfile, "w") do f
      for i in pos_p1
        println(f, i)
      end
    end # the file f is automatically closed after this block finishes

    posy_p1 = map(v -> v[2], particles[1].coord_hist)
    outfile = "./results/Vertical Position basicDEM.txt"
    open(outfile, "w") do f
      for i in posy_p1
        println(f, i)
      end
    end # the file f is automatically closed after this block finishes
    
    
    vel_p1 = first.(particles[1].vel_trl_hist)
    outfile = "./results/Horizontal Velocity basicDEM.txt"
    open(outfile, "w") do f
      for i in vel_p1
        println(f, i)
      end
    end # the file f is automatically closed after this block finishes
    
    acc_p1 = first.(particles[1].acc_trl_hist)
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

function radius_orientation(h,k,r,theta)

  r_end_x = h + r*cos(theta)
  r_end_y = k + r*sin(theta) 
  
  return [h, r_end_x], [k, r_end_y]

end


main()