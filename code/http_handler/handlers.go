package main

import (
	"doppler/internal/v2/receive"
	"doppler/internal/web"
	"doppler/pkg/log"

	"github.com/google/uuid"
	"go.uber.org/zap"

	"encoding/json"
	"io/ioutil"
	"net/http"
	"strings"
	"time"
)

type HandlerContext struct {
	traceID uuid.UUID
	logger  *log.Logger
	t       time.Time
}

func NewHandlerContext() HandlerContext {
	traceID := uuid.New()
	return HandlerContext{
		traceID: traceID,
		logger:  logger.With(zap.String("traceID", traceID.String())),
		t:       time.Now(),
	}
}

func (ctx HandlerContext) endTrace() {
	ctx.logger.With("duration", time.Since(ctx.t).String(), "evt", "request.end").Debug()

	endTime := time.Now()

	duration := int64(endTime.Sub(ctx.t) / time.Millisecond)
	statsdClient.Timing(metricsPrefix+"-Timer", duration)
}

func healthcheck(r *http.Request) *web.Response {
	if time.Since(kinesisDownTS).Minutes() >= 10 {
		return web.Empty(http.StatusOK)
	} else {
		return web.Empty(http.StatusServiceUnavailable)
	}
}

func processData(r *http.Request) *web.Response {
	ctx := NewHandlerContext()

	// Record an end time
	defer ctx.endTrace()

	// log the request.start
	ctx.logger.With("duration", time.Since(ctx.t).String(), "method", r.Method, "uri", r.RequestURI, "evt", "request.start").Debug()

	// Run standard validations, if there are any issues, return them to the client
	if err := web.ValidateRequest(r, ctx.logger, statsdClient, metricsPrefix, &ctx.traceID, ctx.t); err != nil {
		return web.DataJSON(http.StatusBadRequest, err.Error(), nil)
	}

	//parse/validate input
	defer r.Body.Close()
	bits, err := ioutil.ReadAll(r.Body)
	if err != nil {
		ctx.logger.Error("reading body", err)
		statsdClient.Increment(metricsPrefix + "-UnableToReadBody")
		return web.DataJSON(http.StatusBadRequest, "unable to read body", nil)
	}

	ctx.logger.With("duration", time.Since(ctx.t).String()).Debug("passed validations")

	ctx.logger.With("duration", time.Since(ctx.t).String(), "HTTP Data In", string(bits)).Debug()

	var httpIn receive.Event
	err = json.Unmarshal(bits, &httpIn)
	if err != nil {
		ctx.logger.Errorw("Could not decode request body", "duration", time.Since(ctx.t).String(), "error", err)
		statsdClient.Increment(metricsPrefix + "-UnableToDecodeBody")
		return web.DataJSON(http.StatusBadRequest, "unable to parse body", nil)
	}
	return sendV2(httpIn, receive.GetIP(r), ctx, true)
}

func sendV2(httpIn receive.Event, ipAddress string, ctx HandlerContext, validateOptional bool) *web.Response {
	env := strings.ToLower(getEnvironment())
	err := httpIn.Validate(env)
	if err != nil {
		ctx.logger.Warn(err)
		// don't expose internal errors
		statsdClient.Increment(metricsPrefix + "-MissingRequiredField")
		if !strings.Contains(env, "prod") {
			return web.DataJSON(http.StatusBadRequest, "Missing or invalid required field: WMUKID", nil)
		} else {
			return web.DataJSON(http.StatusBadRequest, "missing required field", nil)
		}
	}

	kinesisData, responseError := receive.PrepareKinesisRecord(httpIn, ipAddress, ctx.logger)
	if responseError != nil {
		return responseError
	}

	ctx.logger.With("duration", time.Since(ctx.t).String(), "Kinesis Data In", string(kinesisData)).Debug()

	//write to kpl to send to kinesis
	ctx.logger.Debugw("sending to kinesis", "duration", time.Since(ctx.t).String())

	err = kpl.PutRecord(string(kinesisData))
	if err != nil {
		ctx.logger.Warnf("kplClient.PutRecord %v", err)
	}

	//everything's ok
	if validateOptional && !strings.Contains(env, "prod") {
		//A slice of warning messages for missing/malformed optional elements. Is empty if no warnings arise.
		optionalElementWarningMessages := httpIn.ValidateOptionalFields()
		return web.DataJSON(http.StatusCreated, optionalElementWarningMessages, nil)
	} else {
		return web.Empty(http.StatusCreated)
	}
}
