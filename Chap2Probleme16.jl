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

# Fonction pour créer un VRAI histogramme avec bandes
function creer_vrai_histogramme(distances, titre, couleur)
    # Calcul manuel des bins pour avoir un vrai histogramme
    nb_bins = 30
    min_val = minimum(distances)
    max_val = maximum(distances)
    bin_width = (max_val - min_val) / nb_bins
    bins = range(min_val, stop=max_val, length=nb_bins+1)
    
    # Calcul manuel des fréquences
    counts = zeros(Int, nb_bins)
    for d in distances
        bin_index = min(floor(Int, (d - min_val) / bin_width) + 1, nb_bins)
        counts[bin_index] += 1
    end
    
    # Normalisation pour avoir une densité de probabilité
    total = length(distances)
    densities = counts ./ (total * bin_width)
    
    # Création de l'histogramme avec barres
    bin_centers = [min_val + (i-0.5)*bin_width for i in 1:nb_bins]
    
    bar(bin_centers, densities, 
        bar_width=bin_width*0.8,  # Légèrement plus étroit pour voir les séparations
        alpha=0.7,
        xlabel="Distance inter-événements", 
        ylabel="Densité de probabilité",
        title=titre,
        color=couleur,
        linewidth=1,
        linecolor=:black,
        label="",
        legend=false,
        grid=true)
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

# Fonction pour créer un histogramme avec bins fixes
function creer_histogramme_bins_fixes(distances, titre, couleur)
    # Bins fixes bien définis
    nb_bins = 25
    min_val = 0.0
    max_val = maximum(distances) * 1.1
    
    histogram(distances, 
             bins=range(min_val, stop=max_val, length=nb_bins),
             fill=true,
             alpha=0.7,
             xlabel="Distance inter-événements", 
             ylabel="Densité de probabilité",
             title=titre,
             color=couleur,
             linewidth=1,
             linecolor=:black,
             label="",
             normalize=:pdf,
             legend=false,
             grid=true)
end

# Fonction pour comparer avec superposition
function comparer_superposition_bandes(distances_unif, distances_exp, distances_exp_eff, n::Int)
    # Bins communs pour les trois distributions
    max_val = max(maximum(distances_unif), maximum(distances_exp), maximum(distances_exp_eff))
    bins = range(0, stop=max_val * 1.1, length=30)
    
    p = histogram(distances_unif, bins=bins, 
                  fill=true,
                  alpha=0.6,
                  label="Points uniformes",
                  xlabel="Distance inter-événements", 
                  ylabel="Densité de probabilité",
                  title="Comparaison des distributions (n=$n)",
                  color=:blue,
                  linewidth=1,
                  linecolor=:darkblue,
                  normalize=:pdf,
                  legend=:topright,
                  grid=true)
    
    histogram!(p, distances_exp, bins=bins,
               fill=true,
               alpha=0.6,
               label="Exponentiel (rejet)",
               color=:green,
               linewidth=1,
               linecolor=:darkgreen)
    
    histogram!(p, distances_exp_eff, bins=bins,
               fill=true,
               alpha=0.6,
               label="Exponentiel (efficace)",
               color=:red,
               linewidth=1,
               linecolor=:darkred)
    
    return p
end

# Fonction principale
function comparer_distributions_vraies_bandes(n::Int, λ::Float64, nb_simulations::Int)
    println("="^70)
    println("COMPARAISON AVEC VRAIS HISTOGRAMMES À BANDES")
    println("="^70)
    
    # Génération des données
    println("Génération des points uniformes...")
    distances_unif = distances_uniformes(n, nb_simulations)
    
    println("Génération des temps exponentiels conditionnés (méthode rejet)...")
    distances_exp, total_tentatives, rejets_par_acceptation = distances_exponentielles_conditionnees(λ, n, nb_simulations)
    
    println("Génération des temps exponentiels conditionnés (méthode efficace)...")
    distances_exp_eff = distances_exponentielles_efficace(n, nb_simulations)
    
    # ===== HISTOGRAMMES AVEC DE VRAIES BANDES =====
    
    # Méthode 1: Histogramme avec bins fixes
    p1 = creer_histogramme_bins_fixes(distances_unif, "Points uniformes (n=$n)", :lightblue)
    p2 = creer_histogramme_bins_fixes(distances_exp, "Exponentiel - Rejet (n=$n)", :lightgreen)
    p3 = creer_histogramme_bins_fixes(distances_exp_eff, "Exponentiel - Efficace (n=$n)", :lightcoral)
    
    # Méthode 2: Superposition
    p4 = comparer_superposition_bandes(distances_unif, distances_exp, distances_exp_eff, n)
    
    # Méthode 3: Histogramme avec type barre forcé
    p5 = creer_histogramme_barres(distances_unif, "Points uniformes - Barres (n=$n)", :blue)
    p6 = creer_histogramme_barres(distances_exp, "Exponentiel - Barres (n=$n)", :green)
    
    # Afficher les graphiques
    println("\nAffichage des histogrammes...")
    display(plot(p1, p2, p3, p4, layout=(2,2), size=(1200, 800)))
    display(plot(p5, p6, layout=(1,2), size=(1000, 400)))
    
    # ===== STATISTIQUES =====
    println("\nSTATISTIQUES:")
    println("Uniforme - Moyenne: $(round(mean(distances_unif), digits=6))")
    println("Exponentiel (rejet) - Moyenne: $(round(mean(distances_exp), digits=6))")
    println("Exponentiel (efficace) - Moyenne: $(round(mean(distances_exp_eff), digits=6))")
    println("Théorique - Moyenne attendue: $(round(1/n, digits=6))")
    
    # ===== RÉPONSES =====
    println("\nRÉPONSES AUX QUESTIONS:")
    proba_theorique = calculer_probabilite_theorique(λ, n)
    println("1. Inefficacité méthode rejet:")
    println("   • P(N=$n) = $(round(proba_theorique, digits=8))")
    println("   • Rejets/acceptation: $(round(rejets_par_acceptation, digits=1))")
    println("   • Efficacité: $(round(nb_simulations/total_tentatives * 100, digits=2))%")
    
    println("2. Méthode alternative efficace basée sur propriété Dirichlet")
    
    return distances_unif, distances_exp, distances_exp_eff
end

# Fonction pour tester différents backends de plot
function tester_backends()
    println("Test des différents backends pour les histogrammes...")
    
    # Essayer différents backends
    backends = [:gr, :pyplot, :plotlyjs]
    
    for backend in backends
        try
            Plots.gr()  # Utiliser GR par défaut, bon pour les histogrammes
            println("Backend GR activé")
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
    
    println("PROBLÈME 16 - VRAIS HISTOGRAMMES À BANDES")
    println("="^70)
    
    # Tester les backends
    tester_backends()
    
    # Comparer les distributions
    comparer_distributions_vraies_bandes(n, λ, nb_simulations)
    
    println("\n" * "="^70)
    println("Si vous voyez toujours des courbes au lieu de bandes:")
    println("1. Essayez d'ajouter l'argument `seriestype=:bar`")
    println("2. Utilisez `bar()` au lieu de `histogram()`")
    println("3. Vérifiez le backend de plotting (GR fonctionne bien)")
end

# Exécuter
Random.seed!(123)
probleme16_vraies_bandes()