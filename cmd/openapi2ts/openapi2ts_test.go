package main_test

import (
	"os/exec"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"github.com/onsi/gomega/gexec"
)

var _ = Describe("Openapi2ts", func() {
	It("should work", func() {
		cmd := exec.Command(binPath)
		cmd.Env = append(cmd.Environ(), "UX_INPUT_FILE="+petstorePath)

		ses, err := gexec.Start(cmd, GinkgoWriter, GinkgoWriter)

		Expect(err).NotTo(HaveOccurred())
		Eventually(ses).Should(gexec.Exit(0))
	})
})
