package web

import (
	"os"
)

func getRegion() string {
	region := os.Getenv("AWS_REGION")
	if region == "" {
		panic("AWS_REGION is not set")
	}
	return region
}

func getEnvironment() string {
	environ := os.Getenv("ENVIRONMENT")
	if environ == "" {
		panic("ENVIRONMENT is not set")
	}
	return environ
}
