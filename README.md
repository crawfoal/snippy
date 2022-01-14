# Snippy

This is my solution to our team's 01/14/2022 learning challenge! The challenge
is based on Exercise 54 in Brian P. Hagan's "Exercises for Programmers" book by
PragProg.

## Development & Testing

- Run the application with `mix run --no-halt`, or within an iex session
  `iex -S mix`. You can visit the application at http://localhost:4001/.
- Run tests via `mix test`.

## Notes & Questions

- I took a short bit to touch on XSS and see how that might look and wrote a
  test to ensure that my implementation protected against it. I used an example
  from here: https://owasp.org/www-community/attacks/xss/, but didn't take the
  time to make it fully functional. Just used that to write my test.
  - I questioned where to escape the string - before saving it or before
    presenting it. I chose before saving it because that felt more reliable.
- I learned how Phoenix's `redirect` helper works as well as the `redirected_to`
 test helper. But looking back on it, redirecting maybe wasn't what I should
 have spent my time on in this exercise.
- I read through the Agent docs in more detail and realized that last week I
  probably should have used `get_and_update` instead of sending and receiving
  messages between the agent and client processes.
- I couldn't get `Plug.MethodOverride` with a hidden input working, so I decided
  to just use `POST` on my form...
- This implementation currently doesn't handle concurrent updates (there's a
  race condition).
- Another thing that is bugging me is the duplication in parameter parsing. To
  address this, I'd review what Johnny did for this in recent work, as well as
  any other community patterns.
- I'd also refactor `Store` to have the server helper functions broken out. This
  would reduce some duplication and make coming updates easier.
- I'm not sure I like the interface that `Snippets` has. I'd reconsider that
  after implenting the versioning aspect of the problem because I'd have more
  information at that point about what a better interface might look like.
- I'm currently just at the beginning of implenting support for multiple
  versions. I've started by adding a created at timestamp to the `Snippet`
  struct. The plan is to the store an array of `Snippets`, adding new versions
  to the top of the list. I chose to store the `created_at` timestamp in unix
  format because I had a feeling I might want to use it sort of like an id
  and/or for comparision of versions, but I'm not sure exactly how that will
  play out.
- A few beginning thoughts on handling concurrent updates:
  - Simplest solution I can think of would be to implementing a high level
    locking approach. The lock could be obtained when the edit endpoint is
    handled and released after the update comes in. But then we'd probably want
    some sort of expiration on that because someone could end up not actually
    submitting an update (e.g. they walk away and forget).
  - Maybe even simpler, and better, would be to just reject updates that weren't
    based on the most recent version. Still pretty naive, but then you don't
    have to handle locking and unlocking, which could get pretty messy.
  - More complex, but more user friendly, would be to lock individual rows. And
    show live updates! That would be cool, but also help the users be more
    likely to be editing the most up-to-date version.
- I had to make my test synchronous for them to pass :(
- Figure out a way to remove the 1 second sleep from that one test.
- Format created at timestamps when displaying history
