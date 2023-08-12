# Cuelm

![latest tag](https://img.shields.io/github/v/tag/hofstadter-io/cuelm)

Experiments with CUE for Helm, Terraform, and more
in the quest to reimagine devops ops.


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

- Automatic chart conversions. In the future, may be able to do something with Helm render and anti-unification.
  Could at least import a bunch of values to avoid retyping. Logic is likely out of scope.


### Usage

- Setup your project as a Cue module (`hof mod init cue <module name>`)
- Add this repo to your `cue.mods` file and `hof mod vendor cue`
- Create Cue files using this ([external example](https://github.com/hofstadter-io/cuetorials.com/blob/main/ci/cuelm.cue))
- `cue export -e Install | kubectl apply -f -`

### Notes

- Probably want to develop own k8s schemas based on the `cue get go` output.
  The gen'd output has some issues, notable ports not mapping to what devs expect.



----



things to add

- Dagger to do `cue import k8s`
- fill in the gaps
- enrichments (apiVersion,kind) & defaults (show different scales of providing them, schema separate from defaults)


- Hof creator to setup using this project
- publish OCI modules to github for enriched k8s
  - (make these github.com/hofstadter-io/k8s.io/... explain the hof prefix will go away)
  - Dagger to publish

- example of a widely used chart side-by-side with the CUE version (especially show the templates) (also cloc)
- Hof flow to run gen / stacks / charts / helm

Stages to using CUE &| Helm

1. Schema
2. Values
3. Templates
4. Replacing

- dependencies (CUE)
- sequencing (flow)


---

Try to keep a few implementations, parity not required

- pure CUE
- hof
- binary

