#!/bin/bash
# Démonstration de calendar-ai avec Ollama
# Ce script montre différents exemples d'utilisation

echo "========================================="
echo "Démonstration de calendar-ai avec Ollama"
echo "========================================="
echo ""

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier qu'Ollama est disponible
echo -e "${BLUE}Vérification de la connexion Ollama...${NC}"
if ! calendar-ai --test-connection; then
    echo -e "${YELLOW}Erreur: Ollama n'est pas accessible${NC}"
    echo "Assurez-vous que Ollama est en cours d'exécution:"
    echo "  ollama serve"
    echo ""
    echo "Et qu'un modèle est installé:"
    echo "  ollama pull llama2"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Ollama est prêt !${NC}"
echo ""

# Mode dry-run pour la démonstration
DRY_RUN="--dry-run"

echo "========================================="
echo "Exemples d'événements de calendrier"
echo "========================================="
echo ""

echo -e "${BLUE}1. Rendez-vous simple avec date et heure${NC}"
echo "   Texte: 'Rendez-vous dentiste demain à 14h'"
calendar-ai $DRY_RUN "Rendez-vous dentiste demain à 14h"
echo ""

echo -e "${BLUE}2. Événement avec durée${NC}"
echo "   Texte: 'Réunion équipe lundi 10h pour 2 heures'"
calendar-ai $DRY_RUN "Réunion équipe lundi 10h pour 2 heures"
echo ""

echo -e "${BLUE}3. Événement en soirée${NC}"
echo "   Texte: 'Dîner avec Marie vendredi soir à 19h30'"
calendar-ai $DRY_RUN "Dîner avec Marie vendredi soir à 19h30"
echo ""

echo -e "${BLUE}4. Événement récurrent (note: support à implémenter)${NC}"
echo "   Texte: 'Cours de yoga tous les mardis à 18h'"
calendar-ai $DRY_RUN "Cours de yoga tous les mardis à 18h"
echo ""

echo "========================================="
echo "Exemples de tâches (todos)"
echo "========================================="
echo ""

echo -e "${BLUE}5. Tâche simple${NC}"
echo "   Texte: 'Acheter du pain'"
calendar-ai $DRY_RUN "Acheter du pain"
echo ""

echo -e "${BLUE}6. Tâche avec échéance${NC}"
echo "   Texte: 'Finir le rapport pour vendredi'"
calendar-ai $DRY_RUN "Finir le rapport pour vendredi"
echo ""

echo -e "${BLUE}7. Tâche urgente${NC}"
echo "   Texte: 'URGENT : envoyer le devis au client'"
calendar-ai $DRY_RUN "URGENT : envoyer le devis au client"
echo ""

echo -e "${BLUE}8. Tâche avec date spécifique${NC}"
echo "   Texte: 'Appeler le plombier demain matin'"
calendar-ai $DRY_RUN "Appeler le plombier demain matin"
echo ""

echo "========================================="
echo "Utilisation avancée"
echo "========================================="
echo ""

echo -e "${BLUE}9. Avec un modèle différent${NC}"
echo "   Texte: 'Conférence mardi 15h' (avec --model mistral)"
echo "   Note: Nécessite 'ollama pull mistral'"
# calendar-ai $DRY_RUN --model mistral "Conférence mardi 15h"
echo "   (Commenté si le modèle n'est pas installé)"
echo ""

echo -e "${BLUE}10. Mode debug${NC}"
echo "    Texte: 'Réunion importante demain' (avec --debug)"
calendar-ai $DRY_RUN --debug "Réunion importante demain"
echo ""

echo "========================================="
echo "Pour exécuter réellement"
echo "========================================="
echo ""
echo "Retirez l'option --dry-run pour exécuter les commandes :"
echo ""
echo -e "${GREEN}calendar-ai 'Rendez-vous dentiste demain à 14h'${NC}"
echo ""
echo "Vous pouvez aussi utiliser le mode vocal :"
echo ""
echo -e "${GREEN}calendar-ai --voice${NC}"
echo ""
echo "Pour plus d'informations, consultez OLLAMA_INTEGRATION.md"
echo ""
