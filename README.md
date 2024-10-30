<div style="display: flex; justify-content: center; align-items: center; width: 100%; margin-top: 20px;">
    <a href="https://apps.apple.com/us/app/quote-droplet-daily-quotes/id6455084603?itscg=30200&itsct=apps_box_badge&mttnsubad=6455084603" style="display: inline-block;">
        <img src="https://toolbox.marketingtools.apple.com/api/v2/badges/download-on-the-app-store/black/en-us?releaseDate=1691884800" alt="Download on the App Store" style="width: 246px; height: 82px; vertical-align: middle; object-fit: contain;" />
    </a>
</div>

# Features to Come 📲

### User-Oriented
- Quote submission: enter your name for submission credit in the app's "Newest Quotes" section
- User navigation flows from clicking on the widget or notifications -> should lead to that quote in the app (perhaps in an expanded view, as opposed to the base quote box)
- Onboarding user navigation flow for first-launch to get a user's widget and notifications set up
### Technical
-  Google Image Search API integration to fetch author images ad-hoc
-  Based on user quote interactions (like, save, etc.), they'll be shown more similar quotes
    - Integrate LLM to analyze `bookmarkedQuotes` and `likedQuotes` from `localQuotesService`, to come up with relevant search queries to my API, [Quote-Dropper](https://github.com/Daggerpov/Quote-Dropper) 

# Development 💻

Please take a look at the [Projects tab Kanban board](https://github.com/users/Daggerpov/projects/5/views/1) for the best representation as to what I'm working on, and what my current priorities are for this app. 

### Recently (this past week):
- Re-architected to follow MVVM (Model-View-ViewModel) file/code structure
- Incorporated Dependency Injection
    - For the primary benefit of unit testing with mock services
        - [PR #130](https://github.com/Daggerpov/Quote-Droplet-iOS/pull/130/files): Unit tests with Dependency Injection for Mock Services (New)
    - Also, to decouple logic between views and view models, while ensuring the View Model doesn't depend on the View (only a dependency in the opposite direction)
- Re-wrote closures with memmory leak prevention in mind, using `weak self`
    - [PR #134](https://github.com/Daggerpov/Quote-Droplet-iOS/pull/134): Memory Leaks & Compiler Optimization
- Various Refactoring:
    - [PR #129](https://github.com/Daggerpov/Quote-Droplet-iOS/pull/129): Custom View Modifiers (DRY principle) + Standardized Components
    - [PR #122](https://github.com/Daggerpov/Quote-Droplet-iOS/pull/122/files): Refactoring to Enums
        - Prior to this refactor, I was using string checks for logic, which was a big code smell, that could've caused logic errors and definitely made the code harder to read

### Currently:
- Memory Leak Unit Testing
    - See [this Stackoverflow Q&A](https://stackoverflow.com/a/79135798/13368695) of mine for more context 
- Continuing refactoring efforts, for these two files in particular (bloated and could have helper functions for repeated work or separation of logic, to follow the SOLID - Single Responsibility principle more closely)
    - `QuoteDropletWidget.swift`
    - `APIService.swift`
- Incorporate UI Testing


