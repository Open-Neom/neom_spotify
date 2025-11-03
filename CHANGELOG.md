### 1.1.0 - Major Architectural Refactor & Third-Party Specialization
This release marks a major architectural refactor for neom_spotify, solidifying its role as the central module for all Spotify-related functionalities within the Open Neom ecosystem. The primary focus has been on achieving greater modularity, testability, and a clear separation of concerns, in line with the overarching Clean Architecture principles.

Key Architectural & Feature Improvements:

Major Architectural Changes:

neom_spotify is now a dedicated, self-contained module for Spotify integration, ensuring a clear separation of concerns from main modules.

Decoupling from neom_itemlists:

Spotify synchronization logic, previously integrated with neom_itemlists, has been entirely extracted and centralized here. This allows neom_itemlists to focus purely on local itemlist management, while neom_spotify handles the external synchronization process.

Service-Oriented Architecture:

Controllers within neom_spotify (e.g., NeomSpotifyController) now exclusively interact with core functionalities through their respective service interfaces (use_cases) defined in neom_core. This includes services like UserService and ItemlistFirestore.

This promotes the Dependency Inversion Principle (DIP), leading to significantly improved testability and flexibility by abstracting concrete implementations.

Module-Specific Translations:

Introduced SpotifyTranslationConstants to centralize and manage all UI text strings specific to Spotify functionalities. This ensures improved localization, maintainability, and consistency with Open Neom's global strategy.

Examples of new translation keys include: synchronizePlaylists.

Centralized Spotify Integration Logic:

neom_spotify now fully encapsulates the logic for Spotify authentication, playlist fetching, and music search.

It handles complex data mapping from Spotify API models to Open Neom's domain models (AppMediaItem, Itemlist).

Enhanced Maintainability & Scalability:

As a dedicated and self-contained module, neom_spotify is now easier to maintain, test, and extend for future Spotify-related features.

Any module requiring Spotify integration can simply depend on neom_spotify and its NeomSpotifyService.

Leverages Core Open Neom Modules:

Built upon neom_core for foundational services and neom_commons for reusable UI components and utilities, ensuring seamless integration within the ecosystem.