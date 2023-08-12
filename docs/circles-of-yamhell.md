# DevOps' Inferno - The Circles of YamHell


Opening
(side note about HCL? or make one of the rings

it's come to more than one of us calling ourself "yaml engineers"

CUE vision 


---

dimensions

1. leaky abstractions (charts & tf resources), just expose directly
2. state & reconciliation loop


implementation

1. leverage underlying tools
1. cloud and k8s api calls (we should be able to consume any api long term)




## First Circle (Limbo)

imports, we did this, put us into limbo, bad idea

went on a search, considered own, found CUE


## Second Circle (Lust)

lusting for real.dot.paths[]

- references as strings

## Third Circle (Gluttony)

- layering / overrides

## Fourth Circle (Greed)

- fn:: | interacting with the external world

## Fifth Circle (Anger)

- anchors, concat/prepend them for reuse

## Sixth Circle (Heresy)

- schemas

## Seventh Circle (Violence)

- alternatives to yaml?
- HCL

considerations for a config language
- codec available across programming languages
- machine & human readable
- concise, understandable, powerful

### Seventh Circle, First Ring (Violence against Neighbors)
### Seventh Circle, Second Ring (Violence against Self)
### Seventh Circle, Third Ring (Violence against God, Nature, and Art)



## Eighth Circle (Fraud)

fraudulant attempt at proper lanuage

- programming constructs as strings / ast
- conditionals / loop constructs
- vars / state
- sequenced operations

### Eighth Circle, First Bolgia (Panderers and Seducers)
### Eighth Circle, Second Bolgia (Flatterers)
### Eighth Circle, Third Bolgia (Simonists)
### Eighth Circle, Fourth Bolgia (Fortune Tellers and Diviners)
### Eighth Circle, Fifth Bolgia (Grafters)
### Eighth Circle, Sixth Bolgia (Hypocrites)
### Eighth Circle, Seventh Bolgia (Thieves)
### Eighth Circle, Eighth Bolgia (Deceivers)
### Eighth Circle, Ninth Bolgia (Sowers of Discord)
### Eighth Circle, Tenth Bolgia (Falsifiers)



## Ninth Circle (Treachery)

- text/template
- data interpolation

### Ninth Circle, First Ring (Traitors to Kindred)
### Ninth Circle, Second Ring (Traitors to Country)
### Ninth Circle

CUE as an alternative for Helm templates,
has own concept of template,
can use text/template where appropriate,
hof for even more.

---

YamHell contenders:

- imports (1: Limbo)
- references as strings (2: Lust)
- layering / overrides (3: Gluttony)

- fn:: | interacting with the external world (4: Greed)
- anchors, concat/prepend them for reuse (5: Anger)
- schemas (6: Heresy)


- alternatives to yaml (7: Violence)
- programming constructs as strings / ast (8: Fraud)
- text/template (9: Treachery)


