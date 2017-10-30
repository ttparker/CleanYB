const Ls = ["46", "64", "90", "128"]
const phase = "in"
const Tc = "1.56"
const nSteps = 1000

import JLD
include("CustomTypes.jl")
using Plots
pyplot()
Plots.scalefontsizes(1.3)

mkpath("Samples/")
for L in Ls
  psis = JLD.load("Analyzed/L" * L * "Tc.jld", "Tc").psiList::Vector{Complex{Float64}}

  stepSize = div(length(psis), nSteps)
  selectedPsis = psis[stepSize:stepSize:length(psis)]
  plot(Plots.partialcircle(0, 2 * pi, 100, 1.), xlims = (-1, 1), ylims = (-1, 1), label = "", seriescolor = :grey, aspect_ratio = :equal, xlabel = "Re \$\\psi\$", ylabel = "Im \$\\psi\$", title = "Order parameter samples\nfor clean system in " * phase * "-plane phase\nL = " * L * ", T = " * Tc)
  plot!(real(selectedPsis), imag(selectedPsis), seriestype = :scatter, label = "")
  savefig("Samples/L" * L * "scatter.png")

  histogram2d(real(psis), imag(psis), bins = linspace(-1, 1, 300), normed = true, xlims = (-1, 1), ylims = (-1, 1), aspect_ratio = :equal, seriescolor = :matter, xlabel = "Re \$\\psi\$", ylabel = "Im \$\\psi\$", title = "Order parameter samples\nfor clean system in " * phase * "-plane phase\nL = " * L * ", T = " * Tc)
  plot!(Plots.partialcircle(0, 2 * pi, 100, 1.), seriescolor = :grey, label = "")
  savefig("Samples/L" * L * "heat.png")

  println("L = " * L * " analyzed")
end
