# Problème 16 du chapitre 2

using Plots, Statistics, Random, SpecialFunctions

# Fonctions de simulation
function distances_uniformes(n::Int, nb_simulations::Int)
    toutes_distances = Float64[]
    for _ in 1:nb_simulations
        points_tries = sort(rand(n))
        append!(toutes_distances, diff(points_tries))
    end
    return toutes_distances
end

function distances_exponentielles_conditionnees(λ::Float64, n::Int, nb_simulations::Int)
    toutes_distances = Float64[]
    total_tentatives, total_acceptations = 0, 0
    
    for _ in 1:nb_simulations
        tentatives = 0
        while true
            tentatives += 1
            total_tentatives += 1
            temps, temps_cumulatif = Float64[], 0.0
            while temps_cumulatif <= 1.0
                t = randexp() / λ
                temps_cumulatif += t
                temps_cumulatif <= 1.0 && push!(temps, t)
            end
            if length(temps) == n
                total_acceptations += 1
                append!(toutes_distances, temps)
                break
            end
        end
    end
    return toutes_distances, total_tentatives, (total_tentatives - total_acceptations) / total_acceptations
end

function distances_exponentielles_efficace(n::Int, nb_simulations::Int)
    toutes_distances = Float64[]
    for _ in 1:nb_simulations
        points_tries = sort(rand(n + 1))
        append!(toutes_distances, diff(points_tries))
    end
    return toutes_distances
end

# Calculs théoriques
calculer_probabilite_theorique(λ::Float64, n::Int) = exp(n * log(λ) - λ - loggamma(n + 1))

# Fonction principale
function probleme16()
    n, λ, nb_simulations = 50, 50.0, 1000
    Random.seed!(123)
    
    # Génération des données
    println()
    distances_unif = distances_uniformes(n, nb_simulations)
    distances_exp, total_tentatives, rejets_par_acceptation = distances_exponentielles_conditionnees(λ, n, nb_simulations)
    distances_exp_eff = distances_exponentielles_efficace(n, nb_simulations)
    
    # Histogrammes
    p1 = histogram(distances_unif, bins=30, alpha=0.7, color=:blue, linewidth=2, linecolor=:black,
                   xlabel="Distance", ylabel="Densité", title="Points uniformes (n=$n)", normalize=:pdf)
    p2 = histogram(distances_exp, bins=30, alpha=0.7, color=:green, linewidth=2, linecolor=:black,
                   xlabel="Distance", ylabel="Densité", title="Exponentiel conditionné (n=$n)", normalize=:pdf)
    display(plot(p1, p2, layout=(1,2), size=(1000, 400)))
    
    # Statistiques
    println("\nSTATISTIQUES:")
    println("Uniforme - Moyenne: $(round(mean(distances_unif), digits=6))")
    println("Exponentiel (rejet) - Moyenne: $(round(mean(distances_exp), digits=6))")
    println("Exponentiel (efficace) - Moyenne: $(round(mean(distances_exp_eff), digits=6))")
    println("Théorique - Moyenne attendue: $(round(1/n, digits=6))")
    
    # Analyse efficacité
    proba_theorique = calculer_probabilite_theorique(λ, n)
    println("\n1. Inefficacité méthode rejet:")
    println("   • P(N=$n) = $(round(proba_theorique, digits=8))")
    println("   • Rejets/acceptation: $(round(rejets_par_acceptation, digits=1))")
    println("   • Efficacité: $(round(nb_simulations/total_tentatives * 100, digits=2))%")
    
    println("\n2. Méthode alternative efficace:")
    println("   • Statistiques d'ordre de n+1 points uniformes")
    println("   • Efficacité 100% - Pas de rejet")
end

# Exécuter
probleme16()