# Intro-IUKIT

## Environnement
### Exercice 1
Les fichiers de base: 
- Le delegate agit comme un listener, à chaque fois que l'utilisateur fait une action, elle sera envoyée.

Les fichiers de base permettent de lancer une application vierge
Le storyboard est une prévisualisation de l'application créée
Le simulateur est une instance d'iphone possédant l'application

### Exercice 2
Cmd + R sert à build le projet
Cmd + Shift + O Raccourci pour ouvrir un fichier
Indenter automatiquement : Ctrl + I
Commenter : Cmd + :


## Délégation
### Exercice 1
Une propriété static permet un partage de la propriété entre chaque classe

### Exercice 2
dequeueReusableCell permet de retourner une cellule existante et d'éviter de créer plusieurs instances d'une même cellule


## Navigation
### Exercice 1
Nous venons de créer une page de navigation permettant d'ouvrir les documents
Le NavigationController permet de gérer les évenement de changement de page tandis que la navigationBar est un composant affichant uniquement le titre de la page actuelle


## Ecran detail
### Exercice 1
Un Segue est une connexion entre le viewController et les storyboards

### Exercie 2
Une constraint permet d'appliquer une règle CSS à un élément
AutoLayout gère lui, automatiquement la disposition des éléments


## QLPreview
### Question
Il est plus pertinent de changer l'accessory des cellules avec un disclosureIndicator car cela permet à l'utilisateur de mieux comprendre où il se trouve dans la hiérarchie


## Importation
### Questions
- Un #selector est un mécanisme qui permet de référencer une méthode et l'appeler dans l'action d'un objet
- Dans cet appel, .add est une valeur de l'énumération UIBarButtonSystemItem fournie par UIKit
- Swift, étant un langage moderne orienté objet, il n'est pas directement compatible avec les mécanismes de runtime d'Objective-C. @objc est donc requis
- Oui c'est possible, il faut par exemple utiliser rightBarButtonItems ou leftBarButtonItems selon le coté où l'on veut ajouter le bouton

- La fonction defer sert à spécifier un morceau de code qui sera executé à la fin de la fonction
