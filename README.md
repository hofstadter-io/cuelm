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

I want to say
- deploy this app for me...
  - it needs a database table in my namespace, I may or may not have one running (dev/test/ci vs prod)
  - spin up required infra, but be lazy like dagger


- want a drop in upgrade for the vanilla cue import of k8s
  - publish a module, use as a dep eventually, import path domain, maybe need something else?
  - wrap `vendor/k8s/...` with `schema/k8s/...` rather than adding files into the generated content?
    - apiVersion & kind & other consts, port and other _ fields, perhaps we treat these differently?
  - hof create to add to current projects for now


// from https://stackoverflow.com/a/68568978
port regex: "^((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0][0-9]{1,4})|([0-9]{1,4}))$"

### Pains

[DevOps' Inferno - The Circles of YamHell](./docs/circles-of-yamhell.md)

- Helm: Yaml files with text/template, ... more ... talked about elsewhere
- HCL: Terraform, bad language constructs, leaky abstractions (most have this leak)
- Pulumi: Language SDK or "yaml" (extended and !!"interact with outside world")
- Crossplain: how does this fit in? Has some improvements, but need k8s just to do tf?!

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

(want to think about CI here too, GHA, Argo, Dagger)

Dagger is interesting because we specify what we want from this commit
and it works backwards through the DAG, running (or using cache) for
steps needed to produce our desired outcomes.

Expressing order is not always straight forward in CUE,
after all, it aims to be order independent.
The reason it is currently hard is

1. it has to be a list, it is the only construct that has a reliable ordering
2. there is currently no way to join lists from different places like you can with structs. This will change with associative lists.

There is also CUE's scripting layer, a dynamic DAG engine.
This is where things can get intersting

(???) How is cue/flow processing same/diff to Dagger

- dagger, you "sync" on a container to produce an output, it lazy evals backwards
- cue|hof/flow ... make some examples to show how it works
- topological sort, do we need this if we can find a way to map resource groups to tasks?
  - helm charts / k8s resources / tf data & resources
  - ci? argo workflow submission, smaller dagger rather than e2e cli, do the weaving above (but what about caching?)



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

