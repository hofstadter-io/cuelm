
### Design

Try to keep a few implementations, parity not required

- pure CUE
- hof
- binary

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


