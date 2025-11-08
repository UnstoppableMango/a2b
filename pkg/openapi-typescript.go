package a2b

import (
	"github.com/unstoppablemango/ux/pkg/plugin"
	"github.com/unstoppablemango/ux/pkg/plugin/decl"
)

func OpenApiTypeScript(ux plugin.Ux) decl.Plugin {
	return plugin.Cli{
		Name: "npx",
		Args: []string{
			"openapi-typescript",
			ux.InputFile(),
			"--output",
			ux.OutputPath(),
		},
	}
}
