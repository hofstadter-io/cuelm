package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"dagger.io/dagger"
	"github.com/spf13/pflag"
)

func check(err error) {
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

var CUELM_VERSION string
var K8S_VERSION string
var CUE_VERSION string
var HOF_VERSION string
var GO_VERSION string
var TF_VERSION string
var OUTDIR string

/* latest k8s versions
0.27.4
0.26.7
0.25.12
0.24.16
*/

func init() {
	pflag.StringVar(&CUELM_VERSION, "cuelm", "0.2.0", "Cuelm tag to get schema enhancements from, will be added to cue.mod/usr/ or outdir when generating")
	pflag.StringVar(&K8S_VERSION, "k8s", "0.27.4", "k8s.io/api module version to use, see https://github.com/kubernetes/client-go/tags for available versions")
	pflag.StringVar(&CUE_VERSION, "cue", "0.6.0", "CUE/cue version to use, see https://github.com/cue-lang/cue/tags for available versions")
	pflag.StringVar(&HOF_VERSION, "hof", "0.6.8", "hof version to use, see https://github.com/hofstadter-io/hof/tags for available versions")
	pflag.StringVar(&GO_VERSION, "go", "1.20.7", "Go version to use, cannot be newer than CUE or k8s uses")
	pflag.StringVar(&TF_VERSION, "tf", "1.5.5", "TF version to use, no known conflicts with other versions")
	pflag.StringVarP(&OUTDIR, "outdir", "o", "", "where to output files, defaults to cue.mod/{gen,usr}")
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

	// dir work
	root, err := modroot(".")
	check(err)

	gdir := "gen/k8s.io"
	udir := "usr/k8s.io"

	ogdir := filepath.Join(root, "cue.mod", gdir)
	ugdir := filepath.Join(root, "cue.mod", udir)
	if OUTDIR != "" {
		ogdir = filepath.Join(OUTDIR, gdir)
		ugdir = filepath.Join(OUTDIR, udir)
	}

	// get generated schemas
	gk8s := c.Directory(filepath.Join("/work/cue.mod/", gdir))

	// get hof enrichments
	var usr *dagger.Directory
	if CUELM_VERSION == "local" {
		// assumes you are running this from within the repo
		usr = client.Host().
			Directory(filepath.Join(root, "schema/k8s", udir))
		
	} else {
		usr = client.
			Git("https://github.com/hofstadter-io/cuelm").
			Tag("v" + CUELM_VERSION).
			Tree().
			Directory(filepath.Join("schema/k8s", udir))
	}

	// write generated output
	ok, err := gk8s.Export(ctx, ogdir)
	check(err)
	if !ok {
		fmt.Println("writing !ok")
	}

	// write hof enrichments
	ok, err = usr.Export(ctx, ugdir)
	check(err)
	if !ok {
		fmt.Println("writing !ok")
	}

	fmt.Println("Done writing output to", ogdir, ugdir)
}

func baseImage(client *dagger.Client) (*dagger.Container) {
	// our base image
	golang := client.Container().
		From("golang:"+GO_VERSION).
		WithExec([]string{
			"apt-get", "update", "-y",
		}).
		WithExec([]string{
			"apt-get", "install", "-y", 
			"gcc",
			"git",
			"make",
			"python3",
			"tar",
			"tree",
			"unzip",
			"wget",
		}).
		// WithEnvVariable("CACHEBUST", "manual").
		WithWorkdir("/work")

	c := golang
		
	// go mod cache between runs
	modCache := client.CacheVolume("gomod-global")
	c = c.WithMountedCache("/go/pkg/mod", modCache)

	// the container we will build up
	c = c.Pipeline("base")

	// extra packages

	// CUE binary, fetched in a different container (think of this like a multi-stage Dockerfile)
	url := fmt.Sprintf("https://github.com/cue-lang/cue/releases/download/v%s/cue_v%s_linux_amd64.tar.gz", CUE_VERSION, CUE_VERSION)
	cue := golang.Pipeline("cue").
		WithExec([]string{ "wget", url, "-O", "cue.tar.gz"}).
		WithExec([]string{ "tar", "-xf", "cue.tar.gz"}).
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

	// Terraform binary
	url = fmt.Sprintf("https://releases.hashicorp.com/terraform/%s/terraform_%s_linux_amd64.zip", TF_VERSION, TF_VERSION)
	tf := golang.Pipeline("tf").
		WithExec([]string{ "wget", url, "-O", "tf.zip"}).
		WithExec([]string{ "unzip", "tf.zip"}).
		WithExec([]string{ "chmod", "+x", "terraform"}).
		File("/work/terraform")
	c = c.WithFile("/usr/local/bin/terraform", tf)

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

func modroot(dir string) (string, error) {
	var err error
	if dir == "" {
		dir, err = os.Getwd()
		if err != nil {
			return "", err
		}
	}

	dir, err = filepath.Abs(dir)
	if err != nil {
		return "", err
	}

	found := false

	for !found && dir != "/" {
		try := filepath.Join(dir, "cue.mod")
		info, err := os.Stat(try)
		if err == nil && info.IsDir() {
			found = true
			break
		}

		next := filepath.Clean(filepath.Join(dir, ".."))
		dir = next
	}

	if !found {
		return "", nil
		// return "", fmt.Errorf("unable to find CUE module root")
	}

	return dir, nil
}
