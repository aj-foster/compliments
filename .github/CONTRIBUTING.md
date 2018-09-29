# Contributing to Compliments

Thank you for your interest in contributing to this application. Below are some guidelines to help make the process smooth and friendly for everyone.

### Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See `CODE_OF_CONDUCT.md` in the root of this project for more information.

### Development

Compliments is an application written in the Elixir language, which runs on the Erlang Virtual Machine (BEAM). We recommend using the [asdf verison manager](https://github.com/asdf-vm/asdf), along with the Elixir and Erlang plugins, to install the versions of Elixir and Erlang noted in the `.tool-versions` file.

Compliments is an umbrella application with several sets of dependencies. Install them by running

```
mix deps.get
```

in the root of the project. You can run tests for all parts of the project using:

```
mix test
```

While the tests should not require Slack application secrets, use of the application with a real Slack workspace will. Adding credentials, and the process of releasing / deploying the application, is outlined in this project's `README.md`.
