include("Yb.jl")  # details of this specific system
include("MC.jl")  # MC algorithm

thermalizationSweeps = 2 * 10^5
equilibriumSweeps = 1 * 10^6

f = open("Output","w")
println(f)

currentJzz = 1.
currentJpm = 0.915
currentJpmpm = -0.9
currentJzpm = 0.5
currentL = 64  # must be even for commensurability

for currentT in 1.5:.1:2.5
  MCRun(currentJzz, currentJpm, currentJpmpm, currentJzpm, currentT, currentL, thermalizationSweeps, equilibriumSweeps, f)
  println("MC run complete")
end
println(f, "Jzz: ", currentJzz, ", Jpm: ", currentJpm, ", Jpmpm: ", currentJpmpm, ", Jzpm: ", currentJzpm, ", L: ", currentL, "\nThermalization sweeps: ", thermalizationSweeps, ", Equilibrium sweeps: ", equilibriumSweeps)
close(f)
println("Done")
