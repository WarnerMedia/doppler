package web

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
)

func getReceiveHost() string {
	return fmt.Sprintf("internal.%s.modules.%s.receive", getEnvironment(), getRegion())
}

func getReceiveUrl() string {
	return fmt.Sprintf("http://%s", getReceiveHost())
}

type receiverInput struct {
	//required
	WMUKID      string `json:"wmukid"`
	EventType   string `json:"eventType"`
	EventName   string `json:"eventName"`
	HHIDVersion int64  `json:"hhidVersion"`

	EventProperties map[string]interface{} `json:"eventProperties,omitempty"`
}

type resolverOutput struct {
	WMUKID string `json:"wmukid"`
}

type message struct {
	Request struct {
		URL     string      `json:"url"`
		Method  string      `json:"method"`
		Headers http.Header `json:"headers"`
		Payload interface{} `json:"payload"`
	} `json:"request"`
	Response struct {
		Headers           map[string]string `json:"headers"`
		Code              int               `json:"code"`
		TimeInMilliSecond int64             `json:"timeInMilliSecond"`
		Payload           interface{}       `json:"payload"`
	} `json:"response"`
}

func closeBody(body io.ReadCloser) {
	// Drain the body before closing to allow connection reuse
	io.Copy(ioutil.Discard, body)
	body.Close()
}

func sendToReceive(req *http.Request, response *Response, timeInMilliSecond int64) error {
	var msg message
	var input receiverInput

	body, err := ioutil.ReadAll(req.Body)
	if err != nil {
		return fmt.Errorf("could not read body: %w", err)
	}
	defer closeBody(req.Body)

	err = json.Unmarshal(body, &input)
	if err != nil {
		return fmt.Errorf("could not unmarshal request: %w", err)
	}

	//begin saving the details of the original resolve call to log to receive
	msg.Request.Payload = string(body)
	msg.Request.URL = req.RequestURI
	msg.Request.Method = req.Method
	msg.Request.Headers = req.Header

	//save the response details
	body, err = ioutil.ReadAll(response.Content)
	if err != nil {
		return fmt.Errorf("could not read response content: %w", err)
	}

	var output resolverOutput
	err = json.Unmarshal(body, &output)
	if err != nil {
		// Resolve's error responses are not json serialized
		// log.Printf("could not unmarshal resolver output %v", err)
	}

	msg.Response.Code = response.Status
	msg.Response.Headers = response.Headers
	msg.Response.Payload = string(body)
	msg.Response.TimeInMilliSecond = timeInMilliSecond

	//validate that it has a ukid in there somewhere

	//put these details into the event properties of the doppler message
	input.EventProperties = make(map[string]interface{})
	input.EventProperties["access_log"] = msg
	input.EventType = "doppler"
	input.EventName = "access-log"

	if input.WMUKID == "" && output.WMUKID == "" {
		return fmt.Errorf("could not find wmukid in req payload or response")
	}

	//convert to json
	data, err := json.Marshal(input)
	if err != nil {
		return fmt.Errorf("error in marshalling struct to json: %v", err)
	}

	client := &http.Client{}
	receiveReq, _ := http.NewRequest("POST", getReceiveUrl()+"/v1/reg", bytes.NewReader(data))
	receiveReq.Header.Add("Content-Type", "application/json")
	receiveReq.Header.Set("Host", getReceiveHost())
	res, err := client.Do(receiveReq)
	if err != nil {
		return fmt.Errorf("could not reach receiver %v", err)
	}

	defer closeBody(res.Body)

	if res.StatusCode != http.StatusCreated {
		data, _ = ioutil.ReadAll(res.Body)
		return fmt.Errorf("receive rejected the request. Code: %d, Response: %s", res.StatusCode, string(data))
	}

	return nil
}
