# Cuelm

A pure CUE implementation of Helm

(WIP)

### Goal

Create something like Helm with CUE.

- Stop writing Yaml files with text/template...
- Real packages and imports for charts
- Betters schemas via Cue
- Easier combinatorics for tenant / environment
- Better dependency and apply ordering

Maintain

- Releases concept
- Diff detection and application
- Current ordering of resources, with added dep topological sort
- Most CLI functionality
- Hooks, but could probably improve

Out of scope

- Automatic imports, may be able to do something with Helm render and anti-unification.
  Could at least import a bunch of values to avoid retyping. Logic is likely out of scope.


### Usage

- Setup your project as a Cue module (`hof mod init cue <module name>`)
- Add this repo to your `cue.mods` file and `hof mod vendor cue`
- Create Cue files using this ([external example](https://github.com/hofstadter-io/cuetorials.com/blob/main/ci/cuelm.cue))
- `cue export -e Install | kubectl apply -f -`

### Notes

- Probably want to develop own k8s schemas based on the `cue get go` output.
  The gen'd output has some issues, notable ports not mapping to what devs expect.


