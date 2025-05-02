#=
Material Structure Definition
last update: 04-17-2025

Universidad EAFIT
Medellín, Colombia
Department of Mechanical Engineering

by Daniel Ospina Pajoy
prof. Juan Manuel Rodriguez Prieto
=#

# Defining the Material structure
@with_kw struct Material
    name::String  = "material"        # Material name
    density::Float64 = 1.0   # Density of the material (kg/m^3)
    elastic_modulus::Float64 = 1.0 # Elastic modulus (Pa)
    poisson_ratio::Float64 = 0.3  # Poisson's ratio
end
