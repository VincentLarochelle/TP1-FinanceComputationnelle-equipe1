# Problème 9 du chapitre 2

using Plots
using Statistics

# Fonction pour simuler le minimum de N variables uniformes
function simuler_minimum_uniforme(N::Int, nombre_simulations::Int)
    valeurs_minimum = zeros(nombre_simulations)
    
    for i in 1:nombre_simulations
        # Générer N variables aléatoires uniformes entre 0 et 1
        echantillon = rand(N)
        # Calculer le minimum de l'échantillon
        valeurs_minimum[i] = minimum(echantillon)
    end
    
    return valeurs_minimum
end

# Fonction pour tracer l'histogramme et la distribution théorique
function tracer_distribution_minimum(valeurs_minimum::Vector{Float64}, N::Int)
    # Créer l'histogramme des valeurs minimum simulées
    histogramme = histogram(valeurs_minimum, bins=30, alpha=0.7, 
                           label="Simulation (N=$N)", 
                           xlabel="Valeur du minimum", 
                           ylabel="Densité de probabilité",
                           title="Distribution du minimum de $N variables U(0,1)",
                           normalize=:pdf)
    
    # Ajouter la distribution théorique
    t = range(0, 1, length=100)
    densite_theorique = N .* (1 .- t).^(N-1)  # PDF théorique
    plot!(histogramme, t, densite_theorique, linewidth=3, color=:red, 
          label="Distribution théorique")
    
    return histogramme
end

# Fonction pour étudier la dépendance par rapport à N
function etudier_dependance_N(valeurs_N::Vector{Int}, nombre_simulations::Int=10000)
    # Stocker les résultats pour chaque N
    resultats = Dict{Int, Vector{Float64}}()
    moyennes = Float64[]
    ecarts_types = Float64[]
    
    for N in valeurs_N
        println("Simulation pour N = $N...")
        # Simuler les valeurs minimum
        valeurs_min = simuler_minimum_uniforme(N, nombre_simulations)
        resultats[N] = valeurs_min
        
        # Calculer les statistiques
        push!(moyennes, mean(valeurs_min))
        push!(ecarts_types, std(valeurs_min))
        
        # Afficher les résultats théoriques et simulés
        moyenne_theorique = 1/(N+1)
        println("N=$N: Moyenne simulée = $(round(mean(valeurs_min), digits=4)), " *
                "Moyenne théorique = $(round(moyenne_theorique, digits=4))")
    end
    
    # Tracer l'évolution de la moyenne en fonction de N
    graphique_moyennes = plot(valeurs_N, moyennes, marker=:circle, linewidth=2,
                            xlabel="Nombre de variables (N)", 
                            ylabel="Moyenne du minimum",
                            title="Évolution de la moyenne du minimum en fonction de N",
                            label="Moyennes simulées",
                            legend=:topright)
    
    # Ajouter les valeurs théoriques
    moyennes_theoriques = 1 ./ (valeurs_N .+ 1)
    plot!(graphique_moyennes, valeurs_N, moyennes_theoriques, 
          linewidth=2, color=:red, label="Moyennes théoriques")
    
    return resultats, graphique_moyennes, moyennes, ecarts_types
end

# Fonction pour calculer la fonction de répartition empirique
function calculer_fonction_repartition(valeurs, t_values)
    n = length(valeurs)
    sorted_vals = sort(valeurs)
    cdf_values = zeros(length(t_values))
    
    for (i, t) in enumerate(t_values)
        cdf_values[i] = count(x -> x <= t, valeurs) / n
    end
    
    return cdf_values
end

# Fonction principale
function main()
    # Paramètres initiaux
    N_initial = 10
    nombre_simulations = 10000
    
    println("=== Étude de la distribution du minimum ===")
    println("Paramètres: N = $N_initial, Nombre de simulations = $nombre_simulations")
    
    # Simulation pour N = 10
    valeurs_minimum = simuler_minimum_uniforme(N_initial, nombre_simulations)
    
    # Statistiques descriptives
    println("\n--- Résultats pour N = $N_initial ---")
    println("Moyenne = $(round(mean(valeurs_minimum), digits=4))")
    println("Écart-type = $(round(std(valeurs_minimum), digits=4))")
    println("Minimum observé = $(round(minimum(valeurs_minimum), digits=4))")
    println("Maximum observé = $(round(maximum(valeurs_minimum), digits=4))")
    println("Moyenne théorique = $(round(1/(N_initial+1), digits=4))")
    
    # Tracer la distribution
    graphique = tracer_distribution_minimum(valeurs_minimum, N_initial)
    display(graphique)
    
    # Tracer aussi la fonction de répartition
    t_values = range(0, 1, length=100)
    cdf_empirique = calculer_fonction_repartition(valeurs_minimum, t_values)
    cdf_theorique = 1 .- (1 .- t_values).^N_initial
    
    graphique_cdf = plot(t_values, cdf_empirique, linewidth=2, label="Empirique",
                        xlabel="t", ylabel="Pr(min Xi ≤ t)",
                        title="Fonction de répartition pour N=$N_initial")
    plot!(graphique_cdf, t_values, cdf_theorique, linewidth=2, color=:red, 
          label="Théorique: 1-(1-t)^N")
    display(graphique_cdf)
    
    # Étudier la dépendance par rapport à N
    println("\n=== Étude de la dépendance par rapport à N ===")
    valeurs_N = [2, 5, 10, 20, 50, 100]
    resultats, graphique_moyennes, moyennes, ecarts_types = etudier_dependance_N(valeurs_N, 5000)
    
    display(graphique_moyennes)
    
    # Afficher un résumé
    println("\n=== Résumé ===")
    println("Le minimum de N variables uniformes U(0,1) :")
    println("- Tend vers 0 lorsque N augmente")
    println("- Sa variabilité diminue lorsque N augmente")
    println("- Sa distribution devient de plus en plus concentrée près de 0")
    println("- La moyenne théorique est E[min] = 1/(N+1)")
    println("- La fonction de répartition est Pr(min Xi ≤ t) = 1 - (1 - t)^N")
end

# Exécuter le programme
main()