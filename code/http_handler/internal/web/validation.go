package web

import (
	"mime"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/pkg/errors"

	"doppler/pkg/log"
)

type statsdInterface interface {
	Increment(string)
}

func ValidateRequest(r *http.Request,
	logger *log.Logger,
	statsdClient statsdInterface,
	metricsPrefix string,
	traceID *uuid.UUID,
	startTime time.Time) error {
	mediaType, params, err := mime.ParseMediaType(r.Header.Get("Content-type"))
	if err != nil {
		incrementStatDCounter(statsdClient, metricsPrefix, "-MissingMediaType")
		logger.Error("error parsing media type", err)
		return errors.Wrap(err, "error parsing media type")
	}

	charset := params["charset"]
	if charset == "" {
		charset = "utf-8"
	}
	if (mediaType != "application/json" && mediaType != "text/plain") || strings.ToLower(charset) != "utf-8" {
		incrementStatDCounter(statsdClient, metricsPrefix, "-UnsupportedMediaType")
		logger.Warnf("unsupported media type: %s", mediaType)
		return errors.New("unsupported media type")
	}

	// interrogate user agent header
	userAgent := r.UserAgent()
	logger.With("traceID", traceID, "duration", time.Since(startTime).String(), "User Agent", userAgent).
		Debugw("parsed User-Agent")
	if userAgent == "" {
		logger.Warn("missing User Agent")
		incrementStatDCounter(statsdClient, metricsPrefix, "-MissingUserAgent")
	}

	return nil
}

func incrementStatDCounter(statsdClient statsdInterface, metricsPrefix, metric string) {
	if statsdClient != nil {
		statsdClient.Increment(metricsPrefix + metric)
	}
}
