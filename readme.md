This is the LUA code for the FAF coop mod.

Contributing
------------

To contribute, please fork this repository and make pull requests to the develop branch.

Use the normal git conventions for commit messages, with the following rules:

- Subject line shorter than 80 characters
- No trailing period
- For non-trivial commits, always include a commit message body, describing the change in detail
- If there are related issues, reference them in the commit message footer

We use [git flow](http://nvie.com/posts/a-successful-git-branching-model/) for our branch conventions.

When making _backwards incompatible API changes_, do so with a stub function and put in a logging statement including traceback. This gives time for mod authors to change their code, as well as for us to catch any incompatibilities introduced by the change.

Code convention
---------------

Please follow the [Lua Style Guide](http://lua-users.org/wiki/LuaStyleGuide) as much as possible.

For file encoding, use UTF-8 and unix-style file endings in the repo (Set core.autocrlf).

Running the game with your changes
----------------------------------

There are instructions [in English](setup/setup-english.md) and [in Russian](setup/setup-russian.md) to help you set up a development environment. It is important that you discuss your contributions beforehand. You can do this by making a comment on an existing issue or, if it doesn't exist yet, by opening a new issue. Not all pull requests are merged by default. It is important that the changes align with the vision of the project. 