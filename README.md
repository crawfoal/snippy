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
