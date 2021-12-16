# Continuous Integration and Deployment

We are using GitHub actions for automatically building Stigmee project and
deploying released binaries (Linux, Mac OSX, Windows) to a server
https://github.com/stigmee/front-godot/releases or https://lecrapouille.itch.io/
in which users can download them.

We have followed these instructions:
https://saltares.com/continuous-delivery-pipeline-for-godot-and-itch.io/

## Tokens and Secrets

Tokens are hashed values. Secrets are the containers holding tokens.

There are important steps concerning adding tokens which are not so easy to know
where to click on GitHub pages. In addition with an GitHub organisation, the
organisation by itself cannot hold tokens. One developer of the team has to hold
tokens. For Stigmee https://github.com/Lecrapouille is currently holding them.

- On **your personal GitHub Developer settings** (in this case Lecrapouille's
  personal GitHub Developer settings), create two "Personal access tokens"
  https://github.com/settings/tokens. For the first click on "Generate new
  token" and select the button "workflow (Update GitHub Action workflows)". For
  the second token click on the button "repo".

![token1](continuous_deployment_01.png)

- On **the Stigmee project GitHub settings**, create two secrets:
  - `EXPORT_GITHUB_TOKEN` holding your personal GitHub workflow token allowing
    you to trigger GitHub actions.
  - `ACCESS_TOKEN` holding your personal GitHub repo token to give you the right
    to git cloning on private repos inside the Stigmee organisation.

- For the moment it has been decided not using itch.io for Stigmee (to stay
  private). For the day we want to use it: on **your personal itch.io settings**
  (in this case Lecrapouille's personal itch.io Developer settings), find your
  Developer API Key.
- On **the project GitHub settings**, create the last secret:
  - `BUTLER_CREDENTIALS` holding your personal itch.io API key.
- This should looks like this:

![token2](continuous_deployment_02.png)

## Creating an account on https://itch.io/

- Go to https://itch.io/ and create an account.
- Install the Linux client: https://itch.io/app download and install it
`./itch-setup`.  I think it's mainly a browser, but for the few I used, it shows
statistics on downloads.

![token3](continuous_deployment_03.png)

## GitHub actions Syntax

GitHub actions are yaml files to be stored in the folder `<your
project>/.github/workflows/`. GitHub actions syntax is pretty easy and clear to
understand. Some other CI services such as Trevis-CI or Appveyor are for me
obsolete and shall not be used. Else, for more information concerning GitHub
actions: https://youtu.be/R8_veQiYBjI

If you notice well, GitHub actions files have lines like `uses:
firebelley/godot-export@v1.1.0` and
`josephbmanley/butler-publish-itchio-action@master` which simply refering to two
external GitHub projects with the desired release (for example
https://github.com/firebelley/godot-export).

GitHub actions steps follow this template:
- `name: foo bar` with the desired description.
- `uses: firebelley/godot-export@v3.0.0` referring to an external GitHub actions repos.
- `with:` optionally the list of parameters for the actions.
