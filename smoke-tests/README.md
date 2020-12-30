# Test Regime for Contradb

## Users
- login works
  - `signed in successfully` notification
  - upper right corner menu changes
  - search filter `verified` and `shared` options are enabled
- logout
  - `signed out successfully` notification
  - search filter `verified` and `shared options` are disabled
  - `new dance` redirects to login
- create
  - `sign up` menu item clicks
  - `Public Data Handling` saves form values
  - `No email` saves form values
- edit
  - verify form values from 'create'
  - `Update Notifications` saves form values
  - `Update Identity` changes pw
- password reminder
  - works `FAIL51`
  - button looks okay `FAIL51`
- admin user
  - can see ~1535 dances when setting verified & not verified, and sketchbooks and private, versus ~1225 as unlogged-in user
  - can edit & save another user's dance
  - can edit choreographer
  - edit choreographer Publish select has correct styling `FAIL`

## Dance Search (logged out)
- filters without login
  - ~269 dances
  - Title = "Baby" finds ~3 dances (The Baby Yoda, Becketize the Baby, The Baby Rose)
  - Clear Filters clears out Title
  - Choreographer "Hemphill" finds ~5 verified and ~32 all dances
  - `Clear Filters` clears out Choreographer
  - verified and not verified: ~1225 dances
  - `Clear Filters` reverts to `verified` only.
  - User "Gray" finds ~16 dances
  - `Clear Filters` clears out user
  - Hook "easy" finds ~7 dances
  - `Clear Filters` clears out Hook
  - not verified (only): ~954 dances
  - verified & not verified at once: ~1161 dances
  - `Clear Filters` clears out verification
  - +sketchbooks adds ~2 dances
  - `Clear Filters` clears out sketchbooks
  - only check `becket`: ~87 dances
  - `Clear Filters` clears out formations
- filters with login (d_morse@_____.com user account)
  - verified by me: ~3 dances
  - not verified by me (only): ~1158 dances
  - `Clear Filters`
  - entered by me (uncheck shared): ~10 dances
  - `Clear Filters`
  - `logout`
- SearchEx
  - Figure > Any Figure: ~269 dances
  - Figure > do si do: ~76 dances
  - chain then hey: ~21 dances
  - copy 'chain' and paste it onto 'hey', to make `chain then chain`: ~2 dances - `Clear Search` sends things back to Figure > Any Figure
  - Figure > chain > who = gentlespoons = ~4 dances

## Dance View

- go to dance 419 "Chance Dance Scrambled Eggs"
- title = Chance Dance Scrambled Eggs
- hook = "chainsow promenade to next neighbors"
- by = Jim Hemphill
- by-hyperlink works?
- formation = improper?
- 64 beats?
- Zebra-striping per A1/A2/B1/B2?
- thin grey borders on table cells
- text looks like:

```
A1 	16 	neighbors balance & swing
A2 	8 	chainsaw promenade left
  	8 	chainsaw promenade back to the right
B1 	8 	gentlespoons allemande left 1½
  	8 	partners swing, end in a ring
B2 	8 	balance & petronella
  	4 	balance the ring
  	4 	partners California twirl ⁋
```

- Notes:

```
Cooked up with the breakfast crew. 
Chance Dance, the All you can Eat Contra Dance Weekend
```

- Database
  - user Allison Jonjak
  - shared everywhere
  - Copy button prompts for login
    - login to proceed
  - Copy button goes to dance editor with the dance loaded (click back)
  - navigate back to dance (back button doesn't work as I expect)
  - `✔ verified (1)` badge
  - toggle is off
  - have text "1 user has called this transcription"
  - temporarily toggle `off` -> `on`
    - flash of clock icon instead of `✔`
    - badge becomes (2)
    - toggle is blue and says 'on'
  - mailto link to datadactyl@somedomain.com (different on prod)
  - click the mailto link
    - subject is "contradb dance problem"
    - body is "Dear datadactyl, I see a problem with  'Chance Dance Scrambled Eggs' (http://localhost:3000/dances/419) transcribed by Allison Jonjak. The problem is "
  - toggle Validation off > on > off
    - highlights `promenade` and `next neighbors` in preamble
    - highlights `promenade` in A2
  - dialect is tested elsewhere...

## Dialect Editor
Log in as d_morse@_____.com

- "Dave Morse > dialect" looks okay
- click "show..." button under Advanced & "Restore Default Dialect" button
- "larks & robins" makes 8 entries
- "Face to Face Turn for Two" "substitute" button and enter "%S shoulder round" makes a 9th entry
- "substitute for a move"> "Rory O'More" makes a 10th entry. Set it to "Rory Amore" and blur the text field. The pencil icon should flash as a clock, then turn to a check. 
- click ContraDB in upper left corner to return to main search page.
- search for "Rory Amore and shoulder round" and check 'not verified'
- click "Going our Opposite Waves" by Jim Hemphill
- A1 should start with "robins pull by right" and contain "Rory Amore right"
- click "Copy"

## Dance Edit

The set-up to this is the Dialect Editor section above

- change title from "Going Our Opposite Waves variation" to "Smoke Test"
- change choreographer from "Jim Hemphill" to "Dave Morse". Tab complete around the word "Dave".
- change the formation to "improper". Tab complete should be there. 
- click the first figure, and add a note of ", larks chill, gentlespoons begone, men twirl". Lingo lines should change the rendered text to underlinke "larks" and red-strikethrough "gentlespoons" and "men". Also check that the leading comma comes immediately after the word "chill".
- in the notes, add the same text:  ", larks chill, gentlespoons begone, men twirl. There won't be any lingo lines, but the spellchecker might underline "gentlespoons". 
- Figures +Add a swing. It should pop in in the A1
- on the C1 "partners swing", hit the ⋮ menu and "Add Progression". The ⁋ symbol should appear. 
- on the C1 "slide left along set", hit the ⋮ menu and "Remove Progression". The ⁋ symbol should disappear. 
- In the B2 click "star right 3 places with next", change the hand to left and the grip to "hands across". 
- Also in the B2 verify "partners right shoulder round once" appears
- Remove the new "partners swing" in the A1
- press 'Rotate' 3 times to pull the B2 into the A1
- set Share to 'private'
- Save Dance
- toggle "Validate"

![Should look like this](./dance-editor-result.png)

- note the title of "Smoke Test"
- note the underlined "swing" and "Rory Amore" in the hook.
- note the by: Dave Morse. Does the link work?
- note the "swing" in the preamble
- note that "future neighbor" is not underlined in the preamble because contradb only recognizes the plural "neighbors". 
```
A1 8 parnters right shoulder round once
   6 partners swing ⁋
   2 slide left along set
A2 2 robins pull by right, larks chill, larks begone, men twirl
```
Note the underlining of "larks" twice in the A2 line. "Gentlespoons" got translated to "larks"! FAIL but also probably WONTFIX. What if they change the word "swing" though? Note red line through "men". 

- at the end of the B2 look for "star left - hands across - 3 places with next"
- note the many lingo lines in the notes (see image)
- in the Database well, note that the user is Dave Morse and the word "private".

## Figures

This feature is scheduled for decommisioning, so don't worry too much about it. 

- click the figures tab. You should see a janky word cloud of figures.
- click "swing". You should see a summary of dances with swings after some time (15 seconds?)

## Programs

- Programs Index
  - Click 'Programs' menu item leads to a huge list of programs
  - Click '01.16.18-State College, Pa (band Smash the Windows)' by Karl Senseman
- Programs View
  - has a table of contents with hyperlinks.
  - Click "Dean's Valentine" in the TOC and it jumps downpage to that dance
  - "Dean's Valentine" entry says it's not published in red
  - "Another Easy One" has dance figures
  - "Another Easy One" introduces moves: down the hall, up the hall, right left through
  - toggle validation and verify that lingo lines appear on "neighbors" in the last figure of The Baby Rose
  - We could do more extensive testing of dialects here, but it uses
    the same code to render dances as dance show, so we rely on that
    testing.


- Programs Editor
  - this feature is scheduled for rewrite, and nobody's programming so I'm skipping the test regime for now. 

## Choreographers

- click "Choreographers" menu item
- verify there's a big list of choreographers displayed.
- click "Bob Crawford"
- note "The Baby Yoda" appears as the only dance
- click "New Dance"
  - when prompted log in as an administrator
  - verify that the new dance is by "Bob Crawford"
- return to Bob's choreographer page. 
- click the "Edit Choreographer" button
  - change name to Robert Crawford
  - change the publish to "Always"
  - Save Choreographer
  - Note the changed name and the changed publish of Always
  - Click through to The Baby Yoda and verify that his name changed there too.
  - Click back
  - click "Edit Choreographer" again and change everything back

## Online Documentation

- About
  - click "About" menu item
  - read the text and think if it makes sense
  - Verify that it mentions it's licensed under AGPL3
  - AGPL3 licence hyperlink works
  - source code hyperlink to github works
  - click the "here's a little documentation" link to visit the ..
- Help
  - read the text and think if it makes sense
  - is the contact information up-to-date?
  - does clicking identities launch the mailer with the right To: address? (the one mentioned in mouseover, currently Dave)

## Preferences

Log in as whatever user

- go to [User Name] > Account menu item
- verify that Update Notifications saves the radio button values
- verify that changing password works
- verify that changing other Identity form values work
- verify that deleting user from waaaaay back in User creation works
