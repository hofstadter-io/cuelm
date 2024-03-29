package main

import (
	"encoding/json"
	"list"
	"text/template"
)

flows: providers: {
	@flow(providers) // a named flow

	_offsets: list.Range(0, 400, 100) // list for looping and indexing

	get: {
		// make parallel request tasks
		for off in _offsets {
			// we are building up a value with offset keys to store the req/resp
			"\(off)": {
				@task(api.Call)
				req: {
					host: "https://registry.terraform.io"
					path: "/v1/providers?offset=\(off)&limit=100&tier=official,partner"
				}
				resp: body: _ // body becomes CUE
			}
		}
	}

	// not a task, CUE between them
	etl: {
		// the final data value
		data: providers: {
			// join responses, loop over offsets and providers together
			for off in _offsets for p in get["\(off)"].resp.body.providers {
				"\(p.namespace)/\(p.name)": p
			}
		}
		// turn into json
		out: json.Marshal(data)
	}

	// write to file
	out: {
		@task(os.WriteFile)

		// dependencies ensure this task waits
		$dep: [ for off in _offsets {get["\(off)"].resp.body}]

		filename: "providers.json"
		contents: etl.out
		mode:     0o644
	}
}

flows: cuetify: {
	@flow(cuetify)

	provider: string @tag(provider)
	version:  string @tag(version)

	// if provider is set, do just that one
	if provider != _|_ {
		(provider): _fn & {p: provider, v: version}
	}

	// if provider not set, do our short list
	if provider == _|_ {
		for keep in keepers {
			(keep): _fn & {p: keep, v: version}
		}
	}

	// processes a single provider @ version
	_fn: {
		// inputs
		p: string
		v: string

		// internal ins
		P: providers[p]
		V: string
		if v == _|_ {
			V: P.version
		}

		// internal vars
		ns:   P.namespace
		name: P.name
		ver:  V
		d:    "providers/\(ns)/\(name)/\(ver)/"

		// tasks
		// 1. mkdir
		// 2. provider.tf
		// 3. terraform init & schema
		// 4. cue eval > tf.cue

		mkdir: {
			@task(os.Mkdir)
			dir: d
		}

		tfrp: {
			@task(os.WriteFile)
			$dep: mkdir

			filename: d + "providers.tf"
			contents: template.Execute(_tpl, _in)
			mode:     0o644

			_in: {
				L: "\(ns)/\(name)"
				N: name
				V: ver
			}
			_tpl: """
				terraform {
					required_providers {
						{{ .N }} = {
							source  = "{{ .L }}"
							version = "{{ .V }}"
						}
					}
				}
				"""
		}

		get: {
			@task(os.Exec)
			$dep: tfrp

			dir: d
			cmd: ["bash", "-c", _script]
			_script: """
				set -euo pipefail
				terraform providers lock
				terraform init -input=false -no-color
				terraform providers schema -json > schema.json
				"""
		}

		cue: {
			@task(os.Exec)
			$dep: get

			dir: d
			cmd: ["bash", "-c", _script]
			_script: """
				set -euo pipefail
				cue eval --out cue schema.json ../../../../etl.cue -e out -aA > tf.cue
				"""
		}

	}

}

providers: _
info: {
	// flags
	tier:   string | *"" @tag(tier,short=official|partner)
	filter: string | *"" @tag(filter)

	// lists
	count: len(providers)
	_names: [ for p, v in providers {p}]
	names: list.SortStrings(_names)
	versions: {
		for p in names if (p & =~filter) != _|_ {
			let v = providers[p]
			if (v.tier & =~tier) != _|_ {
				(p): v.version
			}
		}
	}
	details: {
		for p in names if (p & =~filter) != _|_ {
			let v = providers[p]
			if (v.tier & =~tier) != _|_ {
				(p): v
			}
		}
	}
}

keepers: [
	// official
	"hashicorp/ad",
	"hashicorp/archive",
	"hashicorp/aws",
	"hashicorp/azuread",
	"hashicorp/azurerm",
	"hashicorp/google",
	"hashicorp/google-beta",
	"hashicorp/googleworkspace",
	"hashicorp/helm",
	"hashicorp/kubernetes",
	"hashicorp/local",
	"hashicorp/null",
	"hashicorp/random",
	"hashicorp/template",
	"hashicorp/time",
	"hashicorp/vault",

	// partner
	"cloudflare/cloudflare",
	"integrations/github",
]
