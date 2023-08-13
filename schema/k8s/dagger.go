package main

import (
	"context"
	"fmt"
	"os"

	"dagger.io/dagger"
	"github.com/spf13/pflag"
)

func check(err error) {
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

var K8S_VERSION string
var CUE_VERSION string
var HOF_VERSION string
var GO_VERSION string
var OUTDIR string

/* latest k8s versions
0.27.4
0.26.7
0.25.12
0.24.16
*/

func init() {
	pflag.StringVar(&K8S_VERSION, "k8s", "0.27.4", "k8s.io/api module version to use, see https://github.com/kubernetes/client-go/tags for available versions")
	pflag.StringVar(&CUE_VERSION, "cue", "0.6.0", "CUE/cue version to use, see https://github.com/cue-lang/cue/tags for available versions")
	pflag.StringVar(&HOF_VERSION, "hof", "0.6.8", "hof version to use, see https://github.com/hofstadter-io/hof/tags for available versions")
	pflag.StringVar(&GO_VERSION, "go", "1.20.7", "Go version to use, cannot be newer than CUE or k8s uses")
	pflag.StringVarP(&OUTDIR, "outdir", "o", "", "where to output files, defaults to the k8s version")
}

func main() {
	pflag.Parse()
	ctx := context.Background()

	// initialize Dagger client
	client, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stdout))
	check(err)
	defer client.Close()

	c, err := baseImage(client).
		With(printVersions).
		With(fetchDeps(K8S_VERSION)).
		With(fetchCode).
		Sync(ctx)
	check(err)

	// do things
	c, err = c.With(finalize).Sync(ctx)
	check(err)

	// output
	work := c.Directory("/work")
	if OUTDIR == "" {
		OUTDIR = "v" + K8S_VERSION
	}
	ok, err := work.Export(ctx, OUTDIR)
	check(err)
	if !ok {
		fmt.Println("writing !ok")
	}
}

func baseImage(client *dagger.Client) (*dagger.Container) {
	// our base image
	golang := client.Container().
		From("golang:"+GO_VERSION).
		WithWorkdir("/work")

	// the container we will build up
	c := golang.Pipeline("base")
		
	// go mod cache between runs
	modCache := client.CacheVolume("gomod-global")
	c = c.WithMountedCache("/go/pkg/mod", modCache)

	// extra packages
	c = c.WithExec([]string{
		"apt-get", "update", "-y",
	})
	c = c.WithExec([]string{
		"apt-get", "install", "-y", 
		"gcc",
		"git",
		"make",
		"python3",
		"tar",
		"tree",
		"wget",
	})

	// CUE binary, fetched in a different container (think of this like a multi-stage Dockerfile)
	url := fmt.Sprintf("https://github.com/cue-lang/cue/releases/download/v%s/cue_v%s_linux_amd64.tar.gz", CUE_VERSION, CUE_VERSION)
	tar := fmt.Sprintf("cue.tar.gz")
	cue := golang.Pipeline("cue").
		WithExec([]string{ "wget", url, "-O", tar}).
		WithExec([]string{ "tar", "-xf", tar}).
		WithExec([]string{ "chmod", "+x", "cue"}).
		File("/work/cue")

	// add CUE binary to our container
	c = c.WithFile("/usr/local/bin/cue", cue)

	// hof binary, fetched in a different container (think of this like a multi-stage Dockerfile)
	url = fmt.Sprintf("https://github.com/hofstadter-io/hof/releases/download/v%s/hof_v%s_Linux_x86_64", HOF_VERSION, HOF_VERSION)
	hof := golang.Pipeline("hof").
		WithExec([]string{ "wget", url, "-O", "hof"}).
		WithExec([]string{ "chmod", "+x", "hof"}).
		File("/work/hof")

	// add hof binary to our container
	c = c.WithFile("/usr/local/bin/hof", hof)

	return c
}

func fetchDeps(k8sVersion string) dagger.WithContainerFunc {
return func(c *dagger.Container) (*dagger.Container) {
	return c.Pipeline("deps").
		WithExec([]string{"go", "mod", "init", "hof.io/hack"}).
		WithExec([]string{"go", "get", "k8s.io/api@v" + k8sVersion}).
		WithExec([]string{"go", "get", "k8s.io/apimachinery@v" + k8sVersion})
	}
}

func fetchCode(c *dagger.Container) (*dagger.Container) {
	return c.Pipeline("import").
		WithExec([]string{"pwd"}).
		WithExec([]string{"ls"}).
		WithExec([]string{"cue", "mod", "init", "hof.io/hack"}).
		WithExec([]string{"cue", "get", "go", "k8s.io/api/..."}).
		WithExec([]string{"cue", "get", "go", "k8s.io/apimachinery/pkg/api/..."})
}

func printVersions(c *dagger.Container) (*dagger.Container) {
	return c.Pipeline("versions").
		WithExec([]string{"go", "version"}).
		WithExec([]string{"cue", "version"})
		// WithExec([]string{"hof", "version"})
}

func finalize(c *dagger.Container) (*dagger.Container) {
	return c.Pipeline("finalize").
		WithExec([]string{"tree"})
}

