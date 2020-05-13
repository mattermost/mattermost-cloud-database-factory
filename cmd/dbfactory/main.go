// Package main is the entry point to the Mattermost Cloud provisioning server and CLI.
package main

import (
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "dbfactory",
	Short: "DB Factory is a tool to provision RDS Aurora Clusters",
	Run: func(cmd *cobra.Command, args []string) {
		serverCmd.RunE(cmd, args)
	},
	// SilenceErrors allows us to explicitly log the error returned from rootCmd below.
	SilenceErrors: true,
}

func init() {
	rootCmd.AddCommand(serverCmd)
	rootCmd.AddCommand(clusterCmd)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		logger.WithError(err).Error("command failed")
		os.Exit(1)
	}
}
