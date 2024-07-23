<img src="./assets/logo/impostor.png" alt="An impostor is running to the nearest polling station" width="100px" style="float:left;margin-right:20px;margin-bottom:20px;">

# Impostor

Pollsters poll the public, Impostor polls the pollsters.

---

Impostor[^1] fetches the latest U.S. election polling data from [FiveThirtyEight](https://projects.fivethirtyeight.com/polls/), which aggregates the results of many different polls.
It can be run on a schedule to continuously update a local database with the latest polling data.

Only current data from FiveThirtyEight is pulled, since historical data does not need to be updated regularly. This script aims to faciliatate automatic downloads of polling data at regular intervals. Historical data can be downloaded manually instead. For more information about polling sources, see [below](#sources).

## Why this name?

This project was originally going to be called "pollster" or something similarly generic, but in reality it is an impostor among pollsters, since it doesn't actually conduct polls or aggregate them—it merely steals existing aggregated polls and compiles them into a local database. Also [this](http://www.parisglobalist.org/us-elections-among-us-vote-out-the-impostor/).

## Architecture

Impostor is Haskellian technology with built-in error handling for almost all possible IO failures. In most cases, it will relay errors back to the user and continue its job, if possible. In rare cases (i.e. unrecoverable errors like not providing the proper CLI arguments), it will error and refuse to perform any relevant operations.

Impostor is currently single-threaded and uses Cabal for dependency management. Future work should be concentrated on improving performance via multithreading, as well as switching to Stack and Nix for reproducible builds.

## Sources

Currently, the following polls can be automatically downloaded using this script:

- `favorability_polls.csv`
- `favorability_averages.csv`
- `generic_ballot_polls.csv`
- `president_approval_polls.csv`
- `vp_approval_polls.csv`
- `congress_approval.csv`
- `scotus_approval_polls.csv`
- `approval_averages.csv`
- `president_polls.csv`
- `presidential_general_averages.csv`
- `president_primary_polls.csv`
- `presidential_primary_averages.csv`
- `house_polls.csv`
- `senate_poll.csv`

These files will be spawned in the provided data directory, which is the only argument necessary to run the script. See [usage](#usage) for more information.

## Usage

### Build from source

To build from source with Cabal, run the following after cloning this repository:

```sh
cabal install
cabal build
```

You can also directly run the script from the command line with:

```sh
cabal run . -- path/to/data/dir
```

### Installing

You can pick up a pre-compiled executable from this repository's releases. Be sure to use the latest release to ensure you are downloading the correct data sources. Run the executable with the following arguments:

```sh
sudo chmod +x impostor
./impostor path/to/data/dir
```

Release artifacts can also be accessed after cloning the repository in the `/bin` directory. Look for a file named `impostor-a.b.c.d` where `a.b.c.d` is the version number of the release. Follow the [above steps](#installing) for making this file executable and running it.

[^1]: Logo from <https://among-us.fandom.com/wiki/Characters?file=Character_walk_%28base_template%29.png>. Licensed under CC BY-SA 3.0 by Caburum when accessed (2024).
