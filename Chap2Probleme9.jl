# Problème 9 du chapitre 2 : Distribution du minimum

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

# Fonction pour tracer l'histogramme principal avec bandes visibles
function tracer_histogramme_principal(valeurs_minimum::Vector{Float64}, N::Int)
    # Créer l'histogramme avec des bandes bien visibles
    histogramme = histogram(valeurs_minimum, bins=20, alpha=0.7, 
                           label="Données simulées", 
                           xlabel="Valeur du minimum Xi", 
                           ylabel="Fréquence",
                           title="Histogramme du minimum de $N variables U(0,1)",
                           color=:lightblue,
                           linewidth=2,
                           linecolor=:black,
                           legend=:topright)
    
    # Ajouter une ligne verticale pour la moyenne
    moyenne_simulee = mean(valeurs_minimum)
    vline!([moyenne_simulee], linewidth=3, color=:red, 
           label="Moyenne simulée = $(round(moyenne_simulee, digits=4))")
    
    # Ajouter la moyenne théorique
    moyenne_theorique = 1/(N+1)
    vline!([moyenne_theorique], linewidth=3, color=:green, 
           label="Moyenne théorique = $(round(moyenne_theorique, digits=4))")
    
    return histogramme
end

# Fonction pour tracer l'histogramme avec comparaison théorique
function tracer_histogramme_comparaison(valeurs_minimum::Vector{Float64}, N::Int)
    # Créer l'histogramme normalisé avec bordures visibles
    histogramme = histogram(valeurs_minimum, bins=25, alpha=0.6, 
                           label="Histogramme simulé", 
                           xlabel="t (valeur du minimum)", 
                           ylabel="Densité de probabilité",
                           title="Distribution du minimum de $N variables U(0,1)",
                           normalize=:pdf,
                           color=:lightblue,
                           linewidth=1.5,
                           linecolor=:darkblue)
    
    # Ajouter la distribution théorique
    t = range(0, 1, length=200)
    densite_theorique = N .* (1 .- t).^(N-1)  # PDF théorique
    plot!(histogramme, t, densite_theorique, linewidth=3, color=:red, 
          label="Théorique: f(t) = $N(1-t)^$(N-1)")
    
    return histogramme
end

# Fonction pour créer un histogramme détaillé avec statistiques
function histogramme_detaille(valeurs_minimum::Vector{Float64}, N::Int)
    # Calcul des statistiques
    moyenne_sim = mean(valeurs_minimum)
    ecart_type = std(valeurs_minimum)
    moyenne_theo = 1/(N+1)
    
    # Créer l'histogramme avec bordures épaisses
    p = histogram(valeurs_minimum, bins=30, 
                 xlabel="Valeur du minimum", 
                 ylabel="Densité de probabilité",
                 title="Distribution du minimum de $N variables U(0,1)",
                 normalize=:pdf,
                 color=:skyblue,
                 alpha=0.7,
                 linewidth=2,
                 linecolor=:navyblue,
                 label="Données simulées")
    
    # Ajouter la courbe théorique
    t = range(0, 1, length=200)
    densite_theo = N .* (1 .- t).^(N-1)
    plot!(p, t, densite_theo, linewidth=3, color=:crimson, 
          label="Distribution théorique")
    
    # Ajouter les lignes verticales pour les moyennes
    vline!(p, [moyenne_sim], linewidth=2, color=:red, linestyle=:dash, 
           label="Moyenne simulée")
    vline!(p, [moyenne_theo], linewidth=2, color=:green, linestyle=:dash, 
           label="Moyenne théorique")
    
    # Ajouter une annotation avec les statistiques
    annotate!(p, 0.6, maximum(densite_theo)*0.8, 
              text("Moyenne simulée: $(round(moyenne_sim, digits=4))\nMoyenne théorique: $(round(moyenne_theo, digits=4))\nÉcart-type: $(round(ecart_type, digits=4))", 
              :left, 10))
    
    return p
end

# Fonction pour les histogrammes multiples avec bandes bien visibles
function histogrammes_pour_differents_N()
    valeurs_N = [2, 5, 10, 20, 50]
    nombre_simulations = 5000
    
    # Créer un tableau de graphiques
    plots = []
    
    for N in valeurs_N
        # Simuler les données
        donnees = simuler_minimum_uniforme(N, nombre_simulations)
        
        # Créer l'histogramme pour ce N
        p = histogram(donnees, bins=20, 
                     title="N = $N",
                     xlabel="Minimum Xi",
                     ylabel="Densité",
                     normalize=:pdf,
                     color=Int(255/N*10),  # Variation de couleur
                     alpha=0.7,
                     linewidth=1.5,
                     linecolor=:black,
                     label=false)
        
        # Ajouter la courbe théorique
        t = range(0, 1, length=100)
        densite_theo = N .* (1 .- t).^(N-1)
        plot!(p, t, densite_theo, linewidth=2, color=:red, label="Théorique")
        
        push!(plots, p)
    end
    
    # Combiner tous les graphiques
    plot_final = plot(plots..., layout=(length(valeurs_N), 1), 
                     size=(800, 1000),
                     plot_title="Évolution de la distribution du minimum avec N")
    
    return plot_final
end

# Fonction principale
function probleme9_corrige()
    # Paramètres
    N = 10
    nombre_simulations = 10000
    
    println("="^60)
    println("PROBLÈME 9 - DISTRIBUTION DU MINIMUM")
    println("="^60)
    
    # Simulation
    println("Simulation en cours...")
    donnees = simuler_minimum_uniforme(N, nombre_simulations)
    
    # Graphique 1: Histogramme principal avec bandes
    println("Génération de l'histogramme principal...")
    histo1 = tracer_histogramme_principal(donnees, N)
    display(histo1)
    
    # Graphique 2: Comparaison avec théorie
    println("Génération de l'histogramme de comparaison...")
    histo2 = tracer_histogramme_comparaison(donnees, N)
    display(histo2)
    
    # Graphique 3: Histogramme détaillé
    println("Génération de l'histogramme détaillé...")
    histo3 = histogramme_detaille(donnees, N)
    display(histo3)
    
    # Graphique 4: Histogrammes multiples pour différents N
    println("Génération des histogrammes multiples...")
    histo4 = histogrammes_pour_differents_N()
    display(histo4)
    
    # Statistiques
    println("\nSTATISTIQUES POUR N = $N:")
    println("Moyenne simulée: $(round(mean(donnees), digits=6))")
    println("Moyenne théorique: $(round(1/(N+1), digits=6))")
    println("Écart-type: $(round(std(donnees), digits=6))")
end

# Exécuter le programme
probleme9_corrige()