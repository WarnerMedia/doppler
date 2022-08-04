//Package web is a super minimalistic web framework
package web

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/go-kit/kit/log"
)

// Headers is a map of string to string where the key is the key for the header
// And the value is the value for the header
type Headers map[string]string

// Response is a generic response object for our handlers
type Response struct {
	// StatusCode
	Status int
	// Content Type to writer
	ContentType string
	// Content to be written to the response writer
	Content io.Reader
	// Headers to be written to the response writer
	Headers Headers
}

// Action represents a simplified http action
// implements http.Handler
type Action func(r *http.Request) *Response

// Hyperlink represents a hyperlink
type Hyperlink struct {
	Rel  string `json:"rel"`
	Href string `json:"href"`
}

func (a Action) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	if response := a(r); response != nil {
		if response.ContentType != "" {
			rw.Header().Set("Content-Type", response.ContentType)
		}
		for k, v := range response.Headers {
			rw.Header().Set(k, v)
		}
		rw.WriteHeader(response.Status)

		_, err := io.Copy(rw, response.Content)
		if err != nil {
			rw.WriteHeader(http.StatusInternalServerError)
		}
	} else {
		rw.WriteHeader(http.StatusOK)
	}
}

// Error returns an error response
func Error(status int, err error, headers Headers) *Response {
	return &Response{
		Status:  status,
		Content: bytes.NewBufferString(err.Error()),
		Headers: headers,
	}
}

type errorResponse struct {
	Error string `json:"error"`
}

//InternalServerError returns an internal server error response that wraps an error
func InternalServerError(message string, err error, logger log.Logger) *Response {
	e := fmt.Errorf(message+": %w", err)
	logger.Log("error", e)
	return ErrorJSON(http.StatusInternalServerError, e, nil)
}

//ErrorJSON returns an error in json format
func ErrorJSON(status int, err error, headers Headers) *Response {
	h := Headers{
		"Access-Control-Allow-Origin":  "*",
		"Access-Control-Max-Age":       "3600",
		"Access-Control-Allow-Methods": "POST,GET,OPTIONS",
		"cache-control":                "no-cache, must-revalidate",
	}
	for k, v := range headers {
		h[k] = v
	}

	errResp := errorResponse{
		Error: err.Error(),
	}

	b, err := json.Marshal(errResp)
	if err != nil {
		return Error(http.StatusInternalServerError, err, h)
	}

	return &Response{
		Status:      status,
		ContentType: "application/json",
		Content:     bytes.NewBuffer(b),
		Headers:     h,
	}
}

//Data returns a data response
func Data(status int, content []byte, headers Headers) *Response {
	h := Headers{
		"Access-Control-Allow-Origin":  "*",
		"Access-Control-Max-Age":       "3600",
		"Access-Control-Allow-Methods": "POST,GET,OPTIONS",
		"cache-control":                "no-cache, must-revalidate",
	}
	for k, v := range headers {
		h[k] = v
	}

	return &Response{
		Status:  status,
		Content: bytes.NewBuffer(content),
		Headers: h,
	}
}

//DataJSON returns a data response in json format
func DataJSON(status int, v interface{}, headers Headers) *Response {
	h := Headers{
		"Access-Control-Allow-Origin":  "*",
		"Access-Control-Max-Age":       "3600",
		"Access-Control-Allow-Methods": "POST,GET,OPTIONS",
		"cache-control":                "no-cache, must-revalidate",
	}
	for k, v := range headers {
		h[k] = v
	}

	b, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		return ErrorJSON(http.StatusInternalServerError, err, h)
	}

	return &Response{
		Status:      status,
		ContentType: "application/json",
		Content:     bytes.NewBuffer(b),
		Headers:     h,
	}
}

//Empty returns an empty http response
func Empty(status int) *Response {
	return Data(status, []byte(""), Headers{
		"Access-Control-Max-Age":       "3600",
		"Access-Control-Allow-Methods": "POST,GET,OPTIONS",
		"cache-control":                "no-cache, must-revalidate",
	})
}
