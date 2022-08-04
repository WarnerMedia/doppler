package main

import (
	"os"
)

func getEnvironment() string {
	return os.Getenv("ENVIRONMENT")
}

func getLoggingLevel() string {
	return os.Getenv("LOG_LEVEL")
}

func getPort() string {
	result := os.Getenv("PORT")
	if result == "" {
		result = "8080"
	}
	return result
}

func getHealthcheck() string {
	return os.Getenv("HEALTHCHECK")
}

func getDLQ() string {
	return os.Getenv("DLQ_URL")
}

func getHost() string {
	//allow for local testing in docker
	if host := os.Getenv("HOST"); host != "" {
		return host
	}
	return "127.0.0.1"
}

func getSocketServerPort() string {
	return os.Getenv("SOCKET_SERVER_PORT")
}

func getErrHost() string {
	if host := os.Getenv("ERROR_SOCKET_HOST"); host != "" {
		return host
	}
	return "127.0.0.1"
}

func getErrPort() string {
	if host := os.Getenv("ERROR_SOCKET_PORT"); host != "" {
		return host
	}
	return "3001"
}

func getMetricPrefix() string {
	return os.Getenv("METRIC_PREFIX")
}
