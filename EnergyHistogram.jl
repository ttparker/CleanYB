
const L = "128"
const T = "1.56"  # Temperature of energy distribution to be plotted
const dataFile = "Data/L" * L * "/Block7"  # raw data file containing that temperature run

f = open(dataFile, "r")
line = ""
while line != "T: " * T * "\n"
  line = readline(f)
  if eof(f)
    println("Failed to find line in file")
    quit()
  end
end
readline(f)  # "Energies:"
energies = map(x -> parse(Float64, x), split(readline(f), ", "))
close(f)

using Plots
pyplot()
Plots.scalefontsizes(1.75)
histogram(energies, bins = 50, normed = true, xlabel = "E", ylabel = "p(E)", title = "Energy distribution\nfor L = " * L * ", T = " * T, legend = :none)
mkpath("Analyzed")
savefig("Analyzed/L" * L * "EnergyHistogram.png")
