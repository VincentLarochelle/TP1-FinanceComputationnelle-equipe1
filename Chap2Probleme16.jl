# Problème 16 du chapitre 2 : Comparaison équiprobable vs conditionnellement équiprobable

using Plots
using Statistics
using Random
using SpecialFunctions 

# Fonction pour générer des points uniformes et calculer les distances inter-points
function distances_uniformes(n::Int, nb_simulations::Int)
    toutes_distances = Float64[]
    
    for _ in 1:nb_simulations
        # Générer n points uniformes dans [0,1]
        points = rand(n)
        # Trier les points
        points_tries = sort(points)
        # Calculer les distances entre points consécutifs
        for i in 1:(length(points_tries)-1)
            distance = points_tries[i+1] - points_tries[i]
            push!(toutes_distances, distance)
        end
    end
    
    return toutes_distances
end

# Fonction pour générer des temps exponentiels conditionnés à avoir exactement n événements dans [0,1]
function distances_exponentielles_conditionnees(λ::Float64, n::Int, nb_simulations::Int)
    toutes_distances = Float64[]
    total_tentatives = 0
    total_acceptations = 0
    
    for _ in 1:nb_simulations
        accepte = false
        tentatives = 0
        
        while !accepte
            tentatives += 1
            total_tentatives += 1
            
            # Générer des temps exponentiels jusqu'à dépasser 1
            temps = Float64[]
            temps_cumulatif = 0.0
            evenements = 0
            
            while temps_cumulatif <= 1.0 && evenements <= n
                temps_inter = randexp() / λ
                temps_cumulatif += temps_inter
                if temps_cumulatif <= 1.0
                    push!(temps, temps_inter)
                    evenements += 1
                end
            end
            
            # Vérifier si on a exactement n événements
            if length(temps) == n
                accepte = true
                total_acceptations += 1
                # Ajouter les distances à la liste
                for dist in temps
                    push!(toutes_distances, dist)
                end
            end
        end
    end
    
    rejets_par_acceptation = (total_tentatives - total_acceptations) / total_acceptations
    
    return toutes_distances, total_tentatives, rejets_par_acceptation
end

# Méthode alternative plus efficace utilisant la propriété des processus de Poisson
function distances_exponentielles_efficace(n::Int, nb_simulations::Int)
    toutes_distances = Float64[]
    
    for _ in 1:nb_simulations
        # Générer n+1 points uniformes dans [0,1] et les trier
        points_uniformes = rand(n + 1)
        # Trier les points
        points_tries = sort(points_uniformes)
        
        # Calculer les écarts entre points consécutifs
        ecarts = Float64[]
        for i in 1:n
            ecart = points_tries[i+1] - points_tries[i]
            push!(ecarts, ecart)
        end
        
        # Les écarts suivent une distribution Dirichlet(1,1,...,1)
        # et représentent les temps inter-arrivées conditionnés
        for dist in ecarts
            push!(toutes_distances, dist)
        end
    end
    
    return toutes_distances
end

# Fonction pour calculer la probabilité théorique d'avoir exactement n événements
function calculer_probabilite_theorique(λ::Float64, n::Int)
    # Pour un processus de Poisson: P(N=n) = (λ^n * e^{-λ}) / n!
    # Calcul en log pour éviter les overflow
    log_prob = n * log(λ) - λ - loggamma(n + 1)
    return exp(log_prob)
end

# Fonction pour créer un histogramme avec l'option qui force les barres
function creer_histogramme_barres(distances, titre, couleur)
    histogram(distances, bins=:scott,  # Méthode de Scott pour le nombre de bins
             bar_position=:overlay,
             fill=true,
             alpha=0.7,
             xlabel="Distance inter-événements", 
             ylabel="Densité de probabilité",
             title=titre,
             color=couleur,
             linewidth=2,
             linecolor=:black,
             label="",
             normalize=:pdf,
             legend=false,
             grid=true,
             seriestype=:bar)  # FORCER le type barre
end

# Fonction pour comparer les distributions et afficher les résultats
function comparer_distributions_vraies_bandes(n::Int, λ::Float64, nb_simulations::Int)
    
    # Génération des données
    distances_unif = distances_uniformes(n, nb_simulations)
    distances_exp, total_tentatives, rejets_par_acceptation = distances_exponentielles_conditionnees(λ, n, nb_simulations)
    distances_exp_eff = distances_exponentielles_efficace(n, nb_simulations)
    
    # Méthode 3: Histogramme avec type barre forcé
    p1 = creer_histogramme_barres(distances_unif, "Points uniformes - Barres (n=$n)", :blue)
    p2 = creer_histogramme_barres(distances_exp, "Exponentiel - Barres (n=$n)", :green)
    
    # Afficher les graphiques

    display(plot(p1, p2, layout=(1,2), size=(1000, 400)))
    
    # ===== STATISTIQUES =====
    println("\nSTATISTIQUES:")
    println("Uniforme - Moyenne: $(round(mean(distances_unif), digits=6))")
    println("Exponentiel (rejet) - Moyenne: $(round(mean(distances_exp), digits=6))")
    println("Exponentiel (efficace) - Moyenne: $(round(mean(distances_exp_eff), digits=6))")
    println("Théorique - Moyenne attendue: $(round(1/n, digits=6))")
    
    # ===== RÉPONSE =====
    proba_theorique = calculer_probabilite_theorique(λ, n)
    println("1. Inefficacité méthode rejet:")
    println("   • P(N=$n) = $(round(proba_theorique, digits=8))")
    println("   • Rejets/acceptation: $(round(rejets_par_acceptation, digits=1))")
    println("   • Efficacité: $(round(nb_simulations/total_tentatives * 100, digits=2))%")
    
    return nothing
end

# Fonction pour tester différents backends de plot
function tester_backends()
    
    # Essayer différents backends
    backends = [:gr, :pyplot, :plotlyjs]
    
    for backend in backends
        try
            Plots.gr()  
            break
        catch e
            println("Backend $backend non disponible: $e")
        end
    end
end

# Fonction principale
function probleme16_vraies_bandes()
    # Paramètres
    n = 50
    λ = 50.0
    nb_simulations = 1000
    
    # Tester les backends
    tester_backends()
    
    # Comparer les distributions
    comparer_distributions_vraies_bandes(n, λ, nb_simulations)
end

# Exécuter
Random.seed!(123)
probleme16_vraies_bandes()