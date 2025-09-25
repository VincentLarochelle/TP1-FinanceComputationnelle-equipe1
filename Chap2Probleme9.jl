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

# Fonction pour tracer l'histogramme principal 
function tracer_histogramme_principal(valeurs_minimum::Vector{Float64}, N::Int)
    # Créer l'histogramme 
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

# Fonction pour les histogrammes multiples avec bandes bien visibles (CORRIGÉE)
function histogrammes_pour_differents_N()
    valeurs_N = [2, 5, 10, 20, 50]
    nombre_simulations = 5000
    
    # Créer un tableau de graphiques
    plots = []
    
    # Palette de couleurs fixes
    couleurs = [:blue, :green, :orange, :purple, :brown]
    
    for (index, N) in enumerate(valeurs_N)
        # Simuler les données
        donnees = simuler_minimum_uniforme(N, nombre_simulations)
        
        # Créer l'histogramme pour ce N avec couleur fixe
        p = histogram(donnees, bins=20, 
                     title="N = $N",
                     xlabel="Minimum Xi",
                     ylabel="Densité",
                     normalize=:pdf,
                     color=couleurs[index],  # Couleur fixe de la palette
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

# Fonction alternative simplifiée pour histogrammes multiples
function histogrammes_multiples_simples()
    valeurs_N = [2, 5, 10, 20, 50]
    nombre_simulations = 3000
    
    # Créer un seul graphique avec tous les histogrammes
    p = plot(layout=(length(valeurs_N), 1), size=(800, 1000),
            plot_title="Distribution du minimum pour différentes valeurs de N")
    
    for (index, N) in enumerate(valeurs_N)
        # Simuler les données
        donnees = simuler_minimum_uniforme(N, nombre_simulations)
        
        # Ajouter l'histogramme au sous-graphique
        histogram!(p[index], donnees, bins=15, 
                  label="N=$N", 
                  normalize=:pdf,
                  color=index,
                  alpha=0.6,
                  linewidth=1)
        
        # Ajouter la courbe théorique
        t = range(0, 0.5, length=100)  # Limiter l'échelle pour N grand
        densite_theo = N .* (1 .- t).^(N-1)
        plot!(p[index], t, densite_theo, linewidth=2, color=:red, 
              label="Théorique")
        
        # Titre du sous-graphique
        plot!(p[index], title="N = $N", xlabel="Valeur du minimum", ylabel="Densité")
    end
    
    return p
end

# Afficher les données pour chaque N
function afficher_donnees()
    valeurs_N = [2, 5, 10, 20, 50]
    nombre_simulations = 5000
    
    println("N  | Moyenne simulée | Moyenne théorique | Écart-type | Rapport")
    println("-"^65)
    
    for N in valeurs_N
        # Simuler les données
        donnees = simuler_minimum_uniforme(N, nombre_simulations)
        
        # Calculer les statistiques
        moyenne_sim = mean(donnees)
        ecart_type = std(donnees)
        moyenne_theo = 1/(N+1)
        rapport = moyenne_sim / moyenne_theo
        
        # Afficher sur une seule ligne
        println(lpad(N, 2), " | ", 
                lpad(round(moyenne_sim, digits=4), 15), " | ", 
                lpad(round(moyenne_theo, digits=4), 17), " | ", 
                lpad(round(ecart_type, digits=4), 10), " | ", 
                round(rapport, digits=4))
    end
end

# Fonction principale
function chap2probleme9()
    # Paramètres
    N = 10
    nombre_simulations = 10000

    donnees = simuler_minimum_uniforme(N, nombre_simulations)
    histo1 = tracer_histogramme_principal(donnees, N)
    display(histo1)
    histo2 = tracer_histogramme_comparaison(donnees, N)
    display(histo2)
    histo3 = histogramme_detaille(donnees, N)
    display(histo3)
    histo4 = histogrammes_multiples_simples()
    display(histo4)
    
    # Statistiques pour N=10
    println("\nSTATISTIQUES POUR N = $N:")
    println("Moyenne simulée: $(round(mean(donnees), digits=6))")
    println("Moyenne théorique: $(round(1/(N+1), digits=6))")
    println("Écart-type: $(round(std(donnees), digits=6))")
    println("Minimum observé: $(round(minimum(donnees), digits=6))")
    println("Maximum observé: $(round(maximum(donnees), digits=6))")
    
    # Afficher les données pour chaque N
    afficher_donnees()
end

# Exécuter le programme
chap2probleme9()