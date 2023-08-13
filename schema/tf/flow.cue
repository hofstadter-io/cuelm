package main

import (
	"encoding/json"
	"list"
	"text/template"
)

flows: providers: {
	@flow(providers)

	_offs: ["0", "100", "200"]

	get: {
		for off in _offs {
			(off): {
				@task(api.Call)
				req: {
					host: "https://registry.terraform.io"
					path: "/v1/providers?offset=\(off)&limit=100&tier=official,partner"
				}
				resp: body: _
			}
		}
	}

	out: {
		@task(os.WriteFile)
		$dep: [ for off in _offs {get[off].resp.body}]

		filename: "providers.json"
		contents: _calc.str
		mode:     0o644

		_calc: {
			data: providers: {
				for off in _offs for p in get[off].resp.body.providers {
					"\(p.namespace)/\(p.name)": p
				}
			}
			str: json.Indent(json.Marshal(data), "", "  ")
		}

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
		p:    string
		v:    string
		P:    providers[p]
		V:    string
		d:    string | *"providers/\(ns)/\(name)/\(ver)/"
		ns:   P.namespace
		name: P.name
		ver:  V

		if v == _|_ {
			V: P.version
			d: "providers/\(ns)/\(name)/\(ver)/"
		}

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
				pwd
				terraform providers lock
				terraform init -input=false -no-color
				terraform providers schema -json > schema.json
				"""
		}

		cue: {

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
