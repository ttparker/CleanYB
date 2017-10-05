const filenames = []  # Names of analyzed data files to combine into plots
const minT =   # for zoomed-in plots
const maxT =

import JLD
include("CustomTypes.jl")

const nSystems = length(filenames)
function combineSystems(plotyLabel::AbstractString, plotTitle::String, f::Function, systems::Vector{SystemSummary}, plotFilename::String)
  plot(xlabel = "T", ylabel = plotyLabel, title = plotTitle)
  for i in 1:nSystems
    data = f(systems[i])
    plot!(systems[i].Ts, data, seriestype = :line, color = i, label = "")
    plot!(systems[i].Ts, data, seriestype = :scatter, color = i, label = "N = " * string(systems[i].params.L^2))
  end
  savefig("Analyzed/" * plotFilename * ".png")
end

function selectTs(system::SystemSummary, criterion)
  elements = filter(i -> criterion(system.Ts[i]), sortperm(system.Ts))
  SystemSummary(system.params, system.Ts[elements], system.avgEnergies[elements], system.energyVariances[elements], system.absAvgPsis[elements], system.avgAbsPsis[elements], system.absAvgPsi2s[elements], system.avgAbsPsi2s[elements])
end

# Read in data from Analyzed folder:
if(!isdir("Analyzed/"))
  println("No AnalyzedData directory found - run DataAnalysis.jl first.")
  quit()
end
systems = Vector{SystemSummary}()
for filename in filenames
  push!(systems, JLD.load("Analyzed/" * filename * ".jld", filename))
end

# Make plots:
using Plots

pyplot(markersize = 6)
Plots.scalefontsizes(1.75)
combineSystems("E/N", "Energy density", x -> x.avgEnergies, systems, "Energy")
combineSystems("C", "Heat capacity", x -> x.energyVariances .* x.params.L.^2 ./ x.Ts.^2, systems, "HeatCapacity")
combineSystems("\$|\\langle \\psi \\rangle|\$", "Order parameter", x -> x.absAvgPsis, systems, "OrderParameter1")
combineSystems("\$\\langle |\\psi| \\rangle\$", "Order parameter", x -> x.avgAbsPsis, systems, "OrderParameter2")
combineSystems("\$Q_2\$", "Binder ratio \$Q_2\$", x -> x.avgAbsPsi2s ./ x.avgAbsPsis.^2, systems, "BinderRatio")

# zoom into Binder ratio plot:
combineSystems("\$Q_2\$", "Binder ratio \$Q_2\$", x -> x.avgAbsPsi2s ./ x.avgAbsPsis.^2, [selectTs(sys, T -> minT <= T <= maxT) for sys in systems], "ZoomedBinderRatio")

# Break down various order parameters for each system:
for system in systems
  plot(system.Ts, [system.absAvgPsis, system.avgAbsPsis, sqrt(system.absAvgPsi2s), sqrt(system.avgAbsPsi2s)], seriestype = :line, label = "", xlabel = "T", title = "Order parameter for N = " * string(system.params.L^2))
  plot!(system.Ts, system.absAvgPsis, seriestype = :scatter, color = 1, markershape = :circle, label = "\$|\\langle \\psi \\rangle|\$")
  plot!(system.Ts, system.avgAbsPsis, seriestype = :scatter, color = 2, markershape = :rect, label = "\$\\langle |\\psi| \\rangle\$")
  plot!(system.Ts, sqrt(system.absAvgPsi2s), seriestype = :scatter, color = 3, markershape = :diamond, label = "\$\\sqrt{|\\langle \\psi^2 \\rangle|}\$")
  plot!(system.Ts, sqrt(system.avgAbsPsi2s), seriestype = :scatter, color = 4, markershape = :star5, label = "\$\\sqrt{\\langle |\\psi^2| \\rangle}\$")
  savefig("Analyzed/L" * string(system.params.L) * "OrderParameter.png")
end
