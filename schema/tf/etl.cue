			// this comes from providers.json
provider_schemas: _Provider

_includeDocs: bool | *false @tag(docs,type=bool)

// schema for providers.json
_Provider: {
	provider: {
		version: int
		block:   _Block
	}
	resource_schemas: [string]: {
		block: _Block
	}
	data_schemas: [string]: {
		block: _Block
	}
}

_nestingMode: "single" | "list" | "set"

_Block: {
	attributes?: [name=string]: {
		_name:     name
		type:      _attrTypes
		required?: bool
		optional?: bool
	}
	block_types: [name=string]: {
		_name:        name
		nesting_mode: _nestingMode
		conditions?: {
			nesting_mode: _nestingMode
		}
	}
}

// this is our final result
out: {
	_v: [ for p in provider_schemas {p}][0]
	_p: _providerETL & {_in: _v}

	Provider: _p.provider
	Resource: {
		for k, v in _p.resources {
			(k): v
		}
	}
	Data: {
		for k, v in _p.data {
			(k): v
		}
	}
}

_providerETL: {
	_in: _Provider

	provider: {
		(_blockETL & {_block: _in.provider.block}).out
	}

	resources: {
		for k, v in _in.resource_schemas {
			(k): (_blockETL & {_block: v.block} ).out
		}
	}

	data: {
		for k, v in _in.data_source_schemas {
			(k): (_blockETL & {_block: v.block} ).out
		}
	}
}

_attrsETL: {
	_attrs: {}
	for a, attr in _attrs {
		(a)?: (_attrETL & {_attr: attr}).out
		if attr.required != _|_ {
			(a)!: _
		}
		if attr.computed != _|_ {
			(a)?: _ @calc()
		}
		if _includeDocs == true {
			if attr.description != _|_ {
				#help: (a): attr.description
			}
		}
	}
}

//real    1m36.094s
//user    3m22.133s
//sys     0m3.868s

_attrETL: {
	_attr: {}
	out: _

	if (_attr.type & "number") != _|_ {out: number}
	if (_attr.type & "string") != _|_ {out: string}
	if (_attr.type & "bool") != _|_ {out: bool}
	if (_attr.type & "list") != _|_ {out: [...]}
	if (_attr.type & "map") != _|_ {out: [string]: string}
	if (_attr.type & "set") != _|_ {out: [string]: string}
	if (_attr.type & "object") != _|_ {out: {...}}
	if (_attr.type & ["list", "number"]) != _|_ {out: [...number]}
	if (_attr.type & ["list", "string"]) != _|_ {out: [...string]}
	if (_attr.type & ["map", "string"]) != _|_ {out: [string]: string}
	if (_attr.type & ["set", "string"]) != _|_ {out: [string]: string}
	if (_attr.type & ["object", {}]) != _|_ {out: {...}}
	if (_attr.type & ["list", ["object", {}]]) != _|_ {out: [...]}
}

_attrTypes:
	"number" |
	"bool" |
	"string" |
	"list" |
	"map" |
	"set" |
	"object" |
	["list", "number"] |
	["list", "string"] |
	["map", "string"] |
	["set", "string"] |
	["object", {}] |
	["list", ["object", {}]]

_blockETL: {
	_block: _
	out: {
		// top-level attributes for a resource
		if _block.attributes != _|_ {
			_attrsETL & {_attrs: _block.attributes}
		}

		// top-level block_types, "recurse"
		if _block.block_types != _|_ {
			for v1, value1 in _block.block_types {
				(v1): {
					// 1st-level attibutes
					if value1.block.attributes != _|_ {
						_attrsETL & {_attrs: value1.block.attributes}
					}

					// 1st-level block_types, "recurse"
					if value1.block.block_types != _|_ {
						for v2, value2 in value1.block.block_types {
							(v2): {

								// 2nd-level attibutes
								if value2.block.attributes != _|_ {
									_attrsETL & {_attrs: value2.block.attributes}
								}

								// 2st-level block_types, "recurse"
								if value2.block.block_types != _|_ {
									for v3, value3 in value2.block.block_types {
										(v3): {

											// 3nd-level attibutes
											if value3.block.attributes != _|_ {
												_attrsETL & {_attrs: value3.block.attributes}
											}
											if value3.block.block_types != _|_ {
												for v4, value4 in value3.block.block_types {
													(v4): {

														// 4nd-level attibutes
														if value4.block.attributes != _|_ {
															_attrsETL & {_attrs: value4.block.attributes}
														}
														if value4.block.block_types != _|_ {
															for v5, value5 in value4.block.block_types {
																(v5): {

																	// 5nd-level attibutes
																	if value5.block.attributes != _|_ {
																		_attrsETL & {_attrs: value5.block.attributes}
																	}
																	if value5.block.block_types != _|_ {
																		for v6, value6 in value5.block.block_types {
																			(v6): {

																				// 6nd-level attibutes
																				if value6.block.attributes != _|_ {
																					_attrsETL & {_attrs: value6.block.attributes}
																				}
																				if value6.block.block_types != _|_ {
																					for v7, value7 in value6.block.block_types {
																						(v7): {

																							// 7nd-level attibutes
																							if value7.block.attributes != _|_ {
																								_attrsETL & {_attrs: value7.block.attributes}
																							}
																							if value7.block.block_types != _|_ {
																								for v8, value8 in value7.block.block_types {
																									(v8): {

																										// 8nd-level attibutes
																										if value8.block.attributes != _|_ {
																											_attrsETL & {_attrs: value8.block.attributes}
																										}
																										if value8.block.block_types != _|_ {
																											for v9, value9 in value8.block.block_types {
																												(v9): {

																													// 9nd-level attibutes
																													if value9.block.attributes != _|_ {
																														_attrsETL & {_attrs: value9.block.attributes}
																													}
																													if value9.block.block_types != _|_ {
																														for vA, valueA in value9.block.block_types {
																															(vA): {

																																// And-level attibutes
																																if valueA.block.attributes != _|_ {
																																	_attrsETL & {_attrs: valueA.block.attributes}
																																}
																																if valueA.block.block_types != _|_ {
																																	for vB, valueB in valueA.block.block_types {
																																		(vB): {

																																			// Bnd-level attibutes
																																			if valueB.block.attributes != _|_ {
																																				_attrsETL & {_attrs: valueB.block.attributes}
																																			}
																																			if valueB.block.block_types != _|_ {
																																				for vC, valueC in valueB.block.block_types {
																																					(vC): {

																																						// Cnd-level attibutes
																																						if valueC.block.attributes != _|_ {
																																							_attrsETL & {_attrs: valueC.block.attributes}
																																						}
																																						if valueC.block.block_types != _|_ {
																																							for vD, valueD in valueC.block.block_types {
																																								(vD): {

																																									// Dnd-level attibutes
																																									if valueD.block.attributes != _|_ {
																																										_attrsETL & {_attrs: valueD.block.attributes}
																																									}
																																									if valueD.block.block_types != _|_ {
																																										for vE, valueE in valueD.block.block_types {
																																											(vE): {

																																												// End-level attibutes
																																												if valueE.block.attributes != _|_ {
																																													_attrsETL & {_attrs: valueE.block.attributes}
																																												}
																																												if valueE.block.block_types != _|_ {
																																													for vF, valueF in valueE.block.block_types {
																																														(vF): {

																																															// Fnd-level attibutes
																																															if valueF.block.attributes != _|_ {
																																																_attrsETL & {_attrs: valueF.block.attributes}
																																															}
																																															if valueF.block.block_types != _|_ {
																																																GOT_HERE: "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
																																															}
																																														}
																																													}
																																												}
																																											}
																																										}
																																									}
																																								}
																																							}
																																						}
																																					}
																																				}
																																			}
																																		}
																																	}
																																}
																															}
																														}
																													}
																												}
																											}
																										}
																									}
																								}
																							}
																						}
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
