package web

import (
	"bytes"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

type Log func(r *http.Request) *Response

func (a Log) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	//clone request
	var r2 = r.Clone(r.Context())

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		rw.WriteHeader(http.StatusBadRequest)
		return
	}

	r.Body = ioutil.NopCloser(bytes.NewReader(body))
	r2.Body = ioutil.NopCloser(bytes.NewReader(body))

	startTime := time.Now()
	var buf bytes.Buffer
	response := a(r)

	if response != nil {
		if response.ContentType != "" {
			rw.Header().Set("Content-Type", response.ContentType)
		}
		for k, v := range response.Headers {
			rw.Header().Set(k, v)
		}
		tee := io.TeeReader(response.Content, &buf)

		rw.WriteHeader(response.Status)
		_, err := io.Copy(rw, tee)
		if err != nil {
			rw.WriteHeader(http.StatusInternalServerError)
		}
	} else {
		rw.WriteHeader(http.StatusOK)
		response = &Response{
			Status: http.StatusOK,
		}
	}

	timeTaken := time.Since(startTime).Milliseconds()

	response.Content = &buf

	go func(req *http.Request, response *Response, timeInMilliSecond int64) {
		if err := sendToReceive(r2, response, timeTaken); err != nil {
			log.Printf("Failed to send to receiver, %v", err)
		}
	}(r2, response, timeTaken)
}
