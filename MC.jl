function MCRun(Jzz::Float64, Jpm::Float64, Jpmpm::Float64, Jzpm::Float64, T::Float64, L::Int64, thermalizationSweeps::Int64, equilibriumSweeps::Int64, f::IOStream)
  system = Yb(Jzz, Jpm, Jpmpm, Jzpm, T, L)  # initialize spins
  for sweep = 1:thermalizationSweeps  # wait for system to thermalize
    MCSweep!(system)
  end
  energyList = Float64[]
  psiList = Complex{Float64}[]  # measurements after each sweep
  for sweep = 1:equilibriumSweeps  # take equilibrium measurements
    MCSweep!(system)
    push!(energyList, system.energy)
    push!(psiList, measurePsi(system))
  end

  # write results to file:
  println(f, "T: ", T)
  println(f, "Energies:")  # lines 16-20 write each sweep's energy
  for energy in energyList
    print(f, energy / system.N, " ")
  end
  println(f)
  println(f, "Psis:")  # lines 21-25 write each sweep's psi
  for psi in psiList
    print(f, real(psi), "+", imag(psi), "I ")
  end
  println(f)
  psiAvg = mean(psiList)
  println(f, "AverageEnergy: ", mean(energyList) / system.N, "\nAveragePsi: ", real(psiAvg), "+", imag(psiAvg), "I\n")
end

function randomSpin()
  z = 2 * rand() - 1
  s = sqrt(1 - z^2)
  theta = 2 * pi * rand()
  [s * cos(theta), s * sin(theta), z]
end

function MCSweep!(sys::Yb)
  for step = 1:sys.N
    n2, n3 = rand(1:sys.L, 2)  # pick a spin to flip
    nw = mod1(n2 + 1, sys.L)
    se = mod1(n2 - 1, sys.L)
    sw = mod1(n3 + 1, sys.L)
    ne = mod1(n3 - 1, sys.L)
    candidate = randomSpin()  # candidate new orientation
    DeltaE = dot(candidate - sys.spins[n2, n3, :], sys.Ja1 * (sys.spins[se, ne, :] + sys.spins[nw, sw, :]) + sys.Ja2 * (sys.spins[nw, n3, :] + sys.spins[se, n3, :]) + sys.Ja3 * (sys.spins[n2, sw, :] + sys.spins[n2, ne, :]))
    if DeltaE <= 0 || rand() < exp(-DeltaE / sys.T)
      sys.spins[n2, n3, :] = candidate  # replace spin by candidate
      sys.energy += DeltaE
    end
  end
end

function sublatticeMagnetization(n2Range::StepRange{Int64,Int64}, n3Range::StepRange{Int64,Int64}, spins::Array{Float64, 3})
  sublatticeM = [0., 0., 0.]
  for n2 in n2Range
    for n3 in n3Range
      sublatticeM += spins[n2, n3, :]
    end
  end
  sublatticeM
end

function measurePsi(system::Yb)
  M1 = sublatticeMagnetization(system.evenRange, system.evenRange, system.spins)
  M2 = sublatticeMagnetization(system.oddRange, system.oddRange, system.spins)
  M3 = sublatticeMagnetization(system.oddRange, system.evenRange, system.spins)
  M4 = sublatticeMagnetization(system.evenRange, system.oddRange, system.spins)

  # in-plane phase (Jpmpm << 0):
  C1 = [3/2, 3/2*im, 0]
  C2 = [1/2, -3/2*im, 0]
  C3 = [-1-sqrt(3)/2*im, -sqrt(3)/2, 0]
  C4 = [-1+sqrt(3)/2*im, sqrt(3)/2, 0]

#=  # out-of-plane phase (Jpmpm >> 0) order parameter:
  C1 = [-3/2*im*system.sintheta, 3/2*system.sintheta, 0]
  C2 = [3/2*im*system.sintheta, 1/2*system.sintheta, 2*system.costheta]
  C3 = [sqrt(3)/2*system.sintheta, (-1-sqrt(3)/2*im)*system.sintheta, (-1+sqrt(3)*im)*system.costheta]
  C4 = [-sqrt(3)/2*system.sintheta, (-1+sqrt(3)/2*im)*system.sintheta, (-1-sqrt(3)*im)*system.costheta] =#

  (dot(M1, C1) + dot(M2, C2) + dot(M3, C3) + dot(M4, C4)) / system.N
end
