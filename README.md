# GLORIOUSLEVEL

GLORIOUSLEVEL est une application iOS dédiée aux exercices de respiration pour la détente et la concentration.

## Fonctionnalités

- **Exercices de respiration** : Propose plusieurs méthodes de respiration (Wim Hof, 365, 4x4) pour s'adapter à vos besoins.
- **Suivi visuel et haptique** : Animations fluides et retours haptiques pour guider votre respiration.
- **Intégration Apple Health** : Enregistrez vos sessions de respiration en tant que "Mindful Minutes".
- **Rappels** : Planifiez des rappels pour maintenir une routine régulière.
- **Personnalisation** : Ajustez les temps de contraction, de relâchement et le nombre de répétitions.

## Prérequis

- iOS 17.0 ou plus récent.
- Xcode 15.0 ou plus récent pour le développement.

## Structure du projet

- **Models** : Contient la logique métier (`BreathingViewModel`, `HealthKitManager`, `NotificationManager`).
- **Views** : Contient les vues SwiftUI (`BreathingView`, `SettingsView`, `HeartbeatView`, etc.).
- **Assets** : Contient les ressources graphiques.

## Conformité

Ce projet suit les directives définies dans `AGENTS.md`, notamment :
- Utilisation de Swift moderne (async/await).
- SwiftUI avec `@Observable` et `@MainActor`.
- Respect des conventions de nommage et de structure.

## Auteurs

- Mo (Créateur initial)
