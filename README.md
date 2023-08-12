# Cuelm

![latest tag](https://img.shields.io/github/v/tag/hofstadter-io/cuelm)

Experiments with CUE for Helm, Terraform, and more
in the quest to reimagine devops ops.


### Goals

- single config language spanning from commit to desired state
- Real packages, imports, references, language constructs
- Native schemas, defaults, templates, and transformations via Cue
- consistent, singular source-of-truth (as much as possible anyway)
- start as glue, replace when appropriate


### Pains

[DevOps' Inferno - The Circles of YamHell](./docs/circles-of-yamhell.md)

- Helm: Yaml files with text/template, ... more ... talked about elsewhere
- HCL: Terraform, bad language constructs, leaky abstractions (most have this leak)

Generally,

- multiple, tool specific, languages or "enhancements"
- competing workflows, or tools viaing to be the most important

### Current work

- Dagger to do `cue import k8s`
- fill in the gaps
- enrichments (apiVersion,kind) & defaults (show different scales of providing them, schema separate from defaults)


- Hof creator to setup using this project
- publish OCI modules to github for enriched k8s
  - (make these github.com/hofstadter-io/k8s.io/... explain the hof prefix will go away)
  - Dagger to publish

- example of a widely used chart side-by-side with the CUE version (especially show the templates) (also cloc)
- Hof flow to run gen / stacks / charts / helm

---

Try to keep a few implementations, parity not required

- pure CUE
- hof
- binary


### Design

dimensions

1. leaky abstractions (charts & tf resources), just expose directly
2. state & reconciliation loop

(1) leaky abstractions and reconciliation


(2) state & reconciliation loop implementation

1. leverage underlying tools
1. cloud and k8s api calls (we should be able to consume any api long term)




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

