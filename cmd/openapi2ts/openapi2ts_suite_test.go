package main_test

import (
	"os"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"github.com/onsi/gomega/gexec"
)

var (
	binPath      string
	petstorePath string
)

func TestOpenapi2ts(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Openapi2ts Suite")
}

var _ = BeforeSuite(func() {
	var err error
	binPath, err = gexec.Build("./main.go")
	Expect(err).NotTo(HaveOccurred())

	petstorePath = os.Getenv("PETSTORE_PATH")
	Expect(petstorePath).NotTo(BeEmpty(), "PETSTORE_PATH must point to the petstore OpenAPI spec file")
})

var _ = AfterSuite(func() {
	gexec.CleanupBuildArtifacts()
})
