# Compliments

Compliments is a Slack application that allows teammates to compliment one another in a structured, public way.

Use `/compliment` to call out a teammate:

![Posting a Compliment](assets/readme-command.png "Posting a Compliment")

And see your compliment posted publicly in a designated channel:

![Compliment Post](assets/readme-post.png "Compliment Post")

The complimented individual will receive a notification of their appreciation.

---

### Installation

Compliments requires some manual setup in order to operate in a Slack workspace.

**Step one: Configure the application**

When configuring the application in the Slack interface, we recommend these values:

Basic Information:

* **App Name**: Compliments
* **Short description**: Show public appreciation for your teammates
* **Icon**: See `assets/icon.png`
* **Background Color**: `#2c2d30`

Incoming Webhooks:

* **Activate Incoming Webhooks**: On

Slash Commands (Create New Command):

* **Command**: `/compliment`
* **Request URL**: _Wherever we host the application_
* **Short description**: Compliment someone publicly
* **Usage Hint**: `[person] [message]`
* **Escape channels, users, and links sent to your app**: Checked

OAuth & Permisions (Scopes):

* `chat:write:bot`
* `incoming-webhook`
* `commands`
* `users:read`

(Optionally Restrict API Token Usage)

**Step two: Copy secrets**

After configuring the application in the Slack workspace, we now need to copy several secrets to the configuration of the app. Here are the items we'll need from the Slack interface:

* Signing Secret: `XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`
* Webhook URL: `https://hooks.slack.com/services/TXXXXXXXX/BXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX`
* OAuth Access Token: `xoxp-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

Using these values, fill in `rel/config/config.exs` in this format:

```elixir
use Mix.Config

config :slack,
  port: 4000,
  shared_secret: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

config :manager,
  oauth_token: "xoxp-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  webhook: "https://hooks.slack.com/services/TXXXXXXXX/BXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX"

```

We can also configure the listening port using the `port` setting.

**Step three: Deploy the application**

Compliments is an Elixir application which bundles the Erlang Runtime System (ERTS) to create a binary. In order to build the bundle, we need a build environment with the same operating system and architecture as the machine that will host the application.

For an example environment, see [the included Dockerfile](rel/Dockerfile).

Once in the environment, build the application with

```
mix deps.get
COOKIE="some secret here" MIX_ENV=prod mix release
```

replacing the `COOKIE` value with a secret key. The text will be SHA-256 hashed and base16 encoded before being passed to the Erlang VM during application startup.

All of the files necessary to run the application can be found in `_build/prod/rel/compliments/releases/<version>/compliments.tar.gz`. Copying the files to the host, and unpack them where appropriate.

**Step four: Start the application**

The application can be manually started with `bin/compliments start`.

See [this page](https://hexdocs.pm/distillery/guides/systemd.html) and related pages for information about starting the application with `systemd` and other methods.


### Contributing

Please see the contribution guidelines for details about contributing to this application.

Original work on Compliments was completed by Katie Delfin, Drew Barontini, Olivier Lacan, Casey Faist, and Thomas Meeks of Code School.

The current application could not exist without the infectious compassion of Sarah Doss and Christine Wong of Pluralsight.
