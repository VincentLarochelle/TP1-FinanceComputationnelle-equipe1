# Problème 17 du chapitre 2

using Distributions, Plots, Statistics

# Algorithme Zombie Gap pour simuler des temps d'arrivée approximativement exponentiels
function zombie_gap(w, n)
    temps_interarrivee = Int[]
    
    for i in 1:n
        compteur = 0
        while true
            compteur += 1
            U = rand()  # U ∼ U(0, 1)
            if U < w
                push!(temps_interarrivee, compteur)
                break
            end
        end
    end
    return temps_interarrivee
end

w = 0.1
n = 100000
temps = zombie_gap(w, n)
moyenne_empirique = mean(temps)
moyenne_theorique = 1/w
lambda_estimee = 1/moyenne_empirique

println("Paramètre w = ", w)
println("Moyenne empirique = ", moyenne_empirique)
println("Moyenne théorique 1/w = ", moyenne_theorique)
println("Paramètre exponentiel λ estimé = ", lambda_estimee)
println("Paramètre exponentiel théorique λ = w = ", w)



# Test d'adéquation avec une exponentielle
λ = w
k_valeurs = 1:30
survie_empirique = [mean(temps .> k) for k in k_valeurs]
survie_theorique = exp.(-λ .* k_valeurs)  # P(T > k) = e^{-λk}

plot(k_valeurs, survie_empirique, 
    label="Empirique (Zombie Gap)", 
    linewidth=2,
    xlabel="Temps k",
    ylabel="P(T > k)", 
    title="Approximation exponentielle (w=$w)")
plot!(k_valeurs, survie_theorique, 
    label="Théorique Exponentielle(λ=$w)", 
    linewidth=2, 
    linestyle=:dash)