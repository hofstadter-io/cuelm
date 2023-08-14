# Cuelm

![latest tag](https://img.shields.io/github/v/tag/hofstadter-io/cuelm)

Experiments with CUE for Helm, Terraform, and more
in the quest to reimagine devops ops.
This repository has a collection of scripts and files to:

- generating CUE schemas for|from tools & apis
- enrichments and transformations, everything is a snowflake
- automation for creating e2e artifacts the CUE community can use

### Currently

you can...

kubernetes:

- schemas and enrichments  ([schema/k8s](./schema/k8s))
- validate yaml resources
- generate yaml from CUE

terraform:

- generate TF provider schemas as JSON (reshaping & cuetifying is WIP) ([schema/tf](./schema/tf))


You'll need
[cue](https://cuelang.org/docs),
[dagger](https://docs.dagger.io),
and/or [hof](https://docs.hofstadter.io)
depending on which parts you use.
We use these tools to automate
CUE schema generation for all the things.


### Goals

The inspirational idea is to build a CUE based experience
as we develop code and ship it from developer to user.
We want to leverage the various tools we already use,
but also explore where a CUE first approach might yield something better.

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

- [x] Dagger to do `cue import k8s`

- fill in the gaps
  - [x] add schema to ports (was _)
  - [x] add apiVersion & kind to all k8s objects
  - [ ] various fields are underspecified, (like ip / cidr)

- defaults (show different scales of providing them, schema separate from defaults)

- Hof creator to setup using this project
- publish OCI modules to github for enriched k8s
  - (make these github.com/hofstadter-io/k8s.io/... explain the hof prefix will go away)
  - Dagger to publish

- example of a widely used chart side-by-side with the CUE version (especially show the templates) (also cloc)
- Hof flow to run gen / stacks / charts / helm

### Usage

- Setup your project as a Cue module (`hof mod init cue <module name>`)
- Add this repo to your `cue.mods` file and `hof mod vendor cue`
- Create Cue files using this ([external example](https://github.com/hofstadter-io/cuetorials.com/blob/main/ci/cuelm.cue))
- `cue export -e Install | kubectl apply -f -`

