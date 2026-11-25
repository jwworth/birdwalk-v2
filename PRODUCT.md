# Birdwalk Product

Birdwalk is a game that presents a birding identification challenge to users.
Once per day, a new challenge drops that is based on a real world location, such
as Acadia National Park. We'll show the park's state as well so the customer has
more context if they aren't familiar with the park by name alone.

The user starts the game and sees a photo of a bird that was actually seen at
that park. This data comes from eBird and is brought in manually to during data
seeding.

The choices are the actual bird, plus three distractors: for Blue Jay, a wrong
choice might be Canada Jay and Eastern Bluebird. Each challenge contains exactly
five rounds. Each round has one correct bird and three distinct incorrect
choices, displayed in a randomized order.

When all five birds are chosen, we get a results page that shows how many
answers were correct, and a large photo of each bird with its name, scientific
name, and a fact about the bird.

Players can navigate between the five bird results using left and right
controls. The photo, bird names, fact, and navigation controls should fit within
the viewport on typical desktop and mobile screens without requiring vertical
scrolling.

The results are only shown after answering all five questions, not after each
round.

Photos will come from Wikimedia. Every photograph must have an identifiable
source, creator, license, and license URL, plus any additional attribution
information required by its license. The application must display appropriate
attribution wherever the photograph appears. Images must not be used without the
required licensing information.

The user can then share their result by clicking a share button, which puts this
in the clipboard (assuming 3/5 correct).

```
My BirdWalk Score (Acadia National Park, August 5, 2026):
🟢🟢🟢🔴🔴
https://playbirdwalk.com
```

Design is clean and fieldbooky.

Data is entered through a Rails admin interface that stores the data in
Postgres. We'll need forms for challenges, that let us create a round with the
correct answer and three distractor birds. And for birds that end up being the
correct answer, we'll need a way to attach photos with appropriate attribution.

BirdWalk features one playable challenge per calendar day, cycling indefinitely
through all playable challenges in their defined order. The rotation
automatically accommodates newly added challenges. The initial content goal is
52 national parks, but the application does not depend on a fixed number of
challenges.

Challenges are manually curated to maximize variety across the 52-day cycle.
Common species should not dominate the correct answers. Bird selection does not
need to be automated.

This app doesn't care who the user is at all, so they don't have an account,
streaks, days played, etc. If they hard reload the app, it starts at the
beginning again, and their results are not saved if they reload.
