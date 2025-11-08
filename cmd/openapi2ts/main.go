package main

import (
	a2b "github.com/unstoppablemango/a2b/pkg"
	"github.com/unstoppablemango/ux/pkg/plugin/cli"
)

func main() {
	cli.PluginMain(a2b.OpenApiTypeScript)
}
